set current_url [ns_conn url]

    set current_user_id [ad_get_user_id]
    set super_project_id [im_project_super_project_id $project_id]
    im_project_permissions $current_user_id $project_id view read write admin
    if {!$read} { return "" }

    # How to sort the list of subprojects
    set list_sort_order [parameter::get_from_package_key -package_key "intranet-timesheet2" -parameter TimesheetAddHoursSortOrder -default "order"]

    set project_url "/intranet/projects/view"
    set space "&nbsp; &nbsp; &nbsp; "
    set view_id [util_memoize [list db_string get_view_id "select view_id from im_views where view_name = '$view_name'" -default 0]]

    set subproject_filtering_enabled_p [ad_parameter -package_id [im_package_core_id] SubprojectStatusFilteringEnabledP "" 0]
    if {$subproject_filtering_enabled_p} {
	set subproject_filtering_default_status_id [ad_parameter -package_id [im_package_core_id] SubprojectStatusFilteringDefaultStatus "" ""]
	if {0 == $subproject_status_id || "none" == $subproject_status_id} {
	    set subproject_status_id $subproject_filtering_default_status_id
	}
    }

    # ---------------------------------------------------------------
    # Columns to show:

    set column_headers [list]
    set column_vars [list]
    set extra_selects [list]
    set extra_froms [list]
    set extra_wheres [list]

    set column_sql "
	select	*
	from	im_view_columns
	where	view_id = :view_id
	order by sort_order
    "
    db_foreach column_list_sql $column_sql {
	if {"" == $visible_for || [eval $visible_for]} {
	    lappend column_headers "$column_name"
	    lappend column_vars "$column_render_tcl"
	}
	if {"" != $extra_select} { lappend extra_selects $extra_select }
	if {"" != $extra_from} { lappend extra_froms $extra_from }
	if {"" != $extra_where} { lappend extra_wheres $extra_where }
    }
    set extra_select [join $extra_selects ",\n\t\t"]
    if {[llength $extra_selects]} { set extra_select ",\n\t\t$extra_select" }

    # ---------------------------------------------------------------
    # Generate SQL Query

    # Check permissions for showing subprojects
    set perm_sql "
	(select p.*
	from	im_projects p,
		acs_rels r
        where	r.object_id_one = p.project_id and
		r.object_id_two = :current_user_id and
		p.project_type_id not in ([im_project_type_task], [im_project_type_ticket])
        )
    "
    if {[im_permission $current_user_id "view_projects_all"]} { 
	set perm_sql "
		(select	p.*
		from	im_projects p
		where	p.project_type_id not in ([im_project_type_task], [im_project_type_ticket])
		)
	" 
    }

    set subproject_status_sql ""
    if {$subproject_filtering_enabled_p && "" != $subproject_status_id && 0 != $subproject_status_id} {
	set subproject_status_sql "
	and (
		children.project_status_id in ([join [im_sub_categories $subproject_status_id] ","])
	    OR
		children.project_id = :project_id
	)
        "
    }

    switch $list_sort_order {
	name { set sort_order_sql "lower(children.project_name)" }
	order { set sort_order_sql "children.sort_order" }
	legacy { set sort_order_sql "children.tree_sortkey"	}
	default { set sort_order_sql "lower(children.project_nr)" }
    }

    set sql "
	select
		children.project_id as subproject_id,
		trim(children.project_nr) as subproject_nr,
		trim(children.project_name) as subproject_name,
		children.project_status_id as subproject_status_id,
		children.parent_id as subproject_parent_id,
		im_category_from_id(children.project_status_id) as subproject_status,
		im_category_from_id(children.project_type_id) as subproject_type,
		tree_level(children.tree_sortkey) -
		tree_level(parent.tree_sortkey) as subproject_level,
                $sort_order_sql as sort_order
		$extra_select
	from
		im_projects parent,
		$perm_sql children
	where
		children.project_type_id not in ([im_project_type_task])
		$subproject_status_sql
		and children.tree_sortkey between parent.tree_sortkey and tree_right(parent.tree_sortkey)
		and parent.project_id = :super_project_id
	order by children.tree_sortkey
    "

    # ---------------------------------------------------------------
    # Format the List Table Header

    # Set up colspan to be the number of headers + 1 for the # column
    set colspan [expr [llength $column_headers] + 1]

    set table_header_html "<tr>\n"
    foreach col $column_headers {
	regsub -all " " $col "_" col_txt
	set col_txt [lang::message::lookup "" intranet-core.$col_txt $col]
	append table_header_html "  <td class=rowtitle>$col_txt</td>\n"
    }
    append table_header_html "</tr>\n"


    # ---------------------------------------------------------------
    # Format the Result Data

    set table_body_html ""
    set bgcolor(0) " class=roweven "
    set bgcolor(1) " class=rowodd "
    set ctr 0

    # Create a "multirow" from the SQL - read the results into memory
    # Sort the tree according to the specified sort order
    # Loop through the multirow instead of SQL
    db_multirow multirow subproject_query $sql
    multirow_sort_tree multirow subproject_id subproject_parent_id sort_order
    template::multirow foreach multirow {

	set subproject_url [export_vars -base $project_url {{project_id $subproject_id}}]
	set subproject_indent ""
	for {set i 0} {$i < $subproject_level} {incr i} { append subproject_indent $space }
	set subproject_bold_p [expr $project_id == $subproject_id]
	set arrow_left_html ""
	set arrow_right_html ""
	if {$subproject_bold_p} { set arrow_left_html [im_gif arrow_left]}
	if {$subproject_bold_p} { set arrow_right_html [im_gif arrow_right]}

	if {[expr $ctr % 2]} {
	    set bgcolo " class=rowodd "
	} else {
	    set bgcolo " class=roweven "
	}
	set row_html "<tr$bgcolor([expr $ctr % 2])>\n"
	foreach column_var $column_vars {
	    append row_html "\t<td valign=top><nobr>"
	    if {$subproject_bold_p} { append row_html "<b>" }
	    set cmd "append row_html $column_var"
	    eval "$cmd"
	    if {$subproject_bold_p} { append row_html "</b>" }
	    append row_html "</nobr></td>\n"
	}
	append row_html "</tr>\n"
	append table_body_html $row_html
	incr ctr
    }
    

set category_select [im_category_select -include_empty_p 1 "Intranet Project Status" subproject_status_id $subproject_status_id]

    
    set html [im_box_header [lang::message::lookup "" intranet-core.Sub_Projects "Sub-Projects"]]
    
    append html "
	<if @subproject_filtering_enabled_p@>
	  <table class=\"table_component_clean\">
	    <form action=\"@current_url;noquote@\" method=GET>
	      [export_form_vars project_id] 
	      <tr>
	        <td class=form-label>
	          [lang::message::lookup "" intranet-core.Filter_Status "Filter Status"]
	        </td>
	        <td class=form-widget>
	          [im_category_select -include_empty_p 1 "Intranet Project Status" subproject_status_id $subproject_status_id]
	          <input type=submit value=\"Go\">
	        </td>
	      </tr>
	    </form>
	  </table>
	</if>
         <table cellpadding=2 cellspacing=2 border=0>
	  $table_header_html
	  $table_body_html
         </table>
	[im_box_footer]"
    
