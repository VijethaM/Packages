# /packages/intranet-timesheet2/www/hours/new.tcl
#
# Copyright (C) 1998-2004 various parties
# The code is based on ArsDigita ACS 3.4
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

ad_page_contract {
    Displays form to let user enter hours
    In weekly view, week would start with julian_date which is usually a Sunday or Monday   

    @param project_id
    @param julian_date 
    @param return_url 

    @author mbryzek@arsdigita.com
    @author frank.bergmann@project-open.com
    @creation-date Jan 2006
} {
    { project_id 0 }
    { julian_date "" }
    { gregorian_date "" }
    { return_url "" }
    { show_week_p 1 }
    { user_id_from_search "" }
    { search_task ""}
    {project_id1 0}
    {task_name1 ""}
    {desc1 ""}
    {flag 0}
    {is_from_home_page 1}
    {location_id 75242}
    {err_msg ""}
}

# ---------------------------------------------------------
# Default & Security
# ---------------------------------------------------------
# set user_id $user_id_from_search
set show_context_help_p 1

# Should we show debugging information for each project?
set debug 0
# ad_return_complaint 1 "$is_from_home_page" 
set user_id [ad_maybe_redirect_for_registration]
if {"" == $user_id_from_search || ![im_permission $user_id "add_hours_all"]} { set user_id_from_search $user_id }
set user_name_from_search [db_string uname "select im_name_from_user_id(:user_id_from_search)"]
set current_date [db_string as "select to_char(sysdate,'YYYY-MM-DD') from dual"]
set current_date1 [db_string as "select to_char(sysdate,'J') from dual"]
# ToDo: What if the user_id_from_search is already set???

set bgcolor(0) " class=roweven "
set bgcolor(1) " class=rowodd "

if {"" == $show_week_p} { set show_week_p 0 }
if {"" == $project_id} { set project_id 0 }
im_security_alert_check_integer -location "/intranet-timesheet2/www/hours/new" -value $project_id

# Get the date. Accept a gregorian or julian format. Use today as default.
if {![empty_string_p $gregorian_date]} { set julian_date [db_string sysdate_as_julian "select to_char(:gregorian_date::date, 'J')"] }
if {[empty_string_p $julian_date]} { set julian_date [db_string sysdate_as_julian "select to_char(sysdate,'J') from dual"] }

if {"" == $return_url} { set return_url [export_vars -base "/intranet-timesheet2/hours/index" {julian_date user_id_from_search}] }

# Check if user is allowed to log hours for this day
set weekly_logging_days [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetWeeklyLoggingDays -default "0 1 2 3 4 5 6"]

# PG to_start starts with Sunday - index (1)
if { !$show_week_p && [string first [expr [db_string dow "select to_char(to_date(:julian_date, 'J'), 'D')"] -1] $weekly_logging_days] == -1} {
    ad_return_complaint 1  [lang::message::lookup "" intranet-timesheet2.Not_Allowed "You are not allowed to log hours for this day due to configuration restrictions. (Parameter: 'TimesheetWeeklyLoggingDays') "]
}
######################################################################################################
#Nikhil@vmcpl added code to add adhoc task
######################################################################################################
if {$flag==1} {
    # ad_return_complaint 1 "hiiiiiiiiiiiiii $flag"
    set task_id ""
    # set task_nr1 [string tolower $task_name1]
    set task_nr1 [string tolower $task_name1]
    set task_nr1 [string map -nocase {" " "_" "\"" "" "'" "" "/" "_" "-" "_"} $task_nr1]
    set task_type_id [im_project_type_task]
    set material_id [db_string x "select material_id from im_materials where material_name='Default'" -default 0]
    set uom_id [db_string x "select category_id from im_categories where category_type='Intranet UoM' and category='Hour' " -default 0]    
    set cost_center_id [db_string xx "select cost_center_id from im_cost_centers where cost_center_name='Project Execution'" -default 0]
    set task_status_id [db_string s "select category_id from im_categories where category_type='Intranet Project Status' and category='Yet To Start'" -default 0]
    set billable_units 0
    set planned_units 0
    set percent_completed 0
    set pr_id $project_id1
    set note $desc1
    db_string task_insert {}
    set task_id1 [db_string c "select project_id from im_projects where project_name='$task_name1' " -default 0]
    ns_log Notice "nikhil: task_name==== $task_name1 task_id=== $task_id1"
    db_dml task_update {}
    db_dml project_update {}
    # Write Audit Trail
    im_project_audit -project_id $task_id1 -action create
    im_biz_object_add_role $user_id $task_id1 [im_biz_object_role_full_member]
}
# ---------------------------------------------------------
# Calculate the start and end of the week.
# ---------------------------------------------------------
set julian_week_start $julian_date
set julian_week_end $julian_date
set h_day_in_dayweek "h.day::date = to_date(:julian_date, 'J')"
if {$show_week_p} {
    # Find Sunday (=American week start) and Saturday (=American week end)
    # for the current week by adding or subtracting days depending on the weekday (to_char(.., 'D'))
    ## set day_of_week [db_string dow "select to_char(to_date(:julian_date, 'J'), 'D')"]
    # set julian_week_start [expr $julian_date + 1 - $day_of_week]
    # set julian_week_end [expr $julian_date + (7-$day_of_week)]
    ## Reset the day to the start of the week.
    # set julian_date $julian_week_start
    # 1st day shown should be julian_date passed to this page
    set julian_week_start $julian_date
    set julian_week_end [expr $julian_date + [expr [llength $weekly_logging_days]-1]]
    # Condition to check for hours this week:
    set h_day_in_dayweek "h.day between to_date(:julian_week_start, 'J') and to_date(:julian_week_end, 'J')"
}
# set current_url [im_url_with_query]
# set return_url1 "$current_url"
# Materials
set materials_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter HourLoggingWithMaterialsP -default 0]
set material_options [im_material_options -include_empty 1 -restrict_to_uom_id [im_uom_hour]]
set default_material_id [im_material_default_material_id]
# Project_ID and list of project IDs
set project_id_for_default [lindex $project_id 0]
if {0 == $project_id} { set project_id_for_default ""}
# "Log hours for a different day"
set different_date_url [export_vars -base "index" {user_id_from_search julian_date show_week_p project_id}]
# Should we show an "internal" text comment
# in addition to the normal "external" comment?
set internal_note_exists_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter HourLoggingInternalCommentP -default 0]
if {![im_column_exists im_hours internal_note]} {
    ad_return_complaint 1 "Internal error in intranet-timesheet2:<br>
	The field im_hours.internal_note is missing.<br>
	Please notify your system administrator to upgrade
	your system to the latest version.<br>
    "
    ad_script_abort
}
set external_comment_size 40
set internal_comment_size 0
if {$internal_note_exists_p} { 
    set external_comment_size 20
    set internal_comment_size 20
}
# Append user-defined menus
set bind_vars [list user_id $user_id user_id_from_search $user_id_from_search julian_date $julian_date return_url $return_url show_week_p $show_week_p]
set menu_links_html [im_menu_ul_list -no_uls 1 "timesheet_hours_new_admin" $bind_vars]
set different_project_url "other-projects?[export_url_vars julian_date user_id_from_search]"
# Log Absences
set add_absences_p [im_permission $user_id add_absences]
set absences_url [export_vars -base "/intranet-timesheet2/absences/new" {return_url user_id_from_search}]
set absences_link_text [lang::message::lookup "" intranet-timesheet2.Log_Absences "Log Absences"]
db_1row user_name_and_date "
select 
	im_name_from_user_id(user_id) as user_name,
	to_char(to_date(:julian_date, 'J'), 'fmDay fmMonth fmDD, YYYY') as pretty_date
from	users
where	user_id = :user_id_from_search" 
# ---------------------------------------------------------
# Calculate the <- -> buttons at the top of the timesheet page.
# ---------------------------------------------------------
set left_gif [im_gif arrow_comp_left]
set right_gif [im_gif arrow_comp_right]
# What is a closed status?
set log_hours_on_potential_project_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetLogHoursOnPotentialProjectsP -default 1]
set closed_stati_select "select * from im_sub_categories([im_project_status_closed])"
if {!$log_hours_on_potential_project_p} {
    append closed_stati_select " UNION select * from im_sub_categories([im_project_status_potential])"
}
if {$show_week_p} {
    set page_title [lang::message::lookup "" intranet-timesheet2.The_week_for_user "The week for %user_name_from_search%"]
    set from_date [db_string as "select to_char(to_date(:julian_date, 'J'),'DD-Mon-YYYY') from dual"]
    set julian_date1  [expr $julian_date + 6]
    set to_date [db_string sd "select  to_char(to_date(:julian_date1, 'J'), 'DD-Mon-YYYY') from dual"]
    set prev_week_julian_date [expr $julian_date - 7]
    set prev_week_url [export_vars -base "new" {{julian_date $prev_week_julian_date} user_id_from_search return_url project_id show_week_p is_from_home_page}]
    set prev_week_link "<a href=$prev_week_url>$left_gif</a>"
    set next_week_julian_date [expr $julian_date + 7]
    set next_week_url [export_vars -base "new" {{julian_date $next_week_julian_date} user_id_from_search return_url project_id show_week_p is_from_home_page}]
    set next_week_link "<a href=$next_week_url>$right_gif</a>"
    set forward_backward_buttons "
	<tr>
	<td align=left>$prev_week_link</td>
	<td colspan=6><h2> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $from_date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $to_date</h2></td>
	<td align=right>$next_week_link</td>
	</tr>
    "
    #Nikhil added code to get closed tasks for two days after closing tasks 
    set from_date [db_string as "select to_char(to_date(:julian_date, 'J'),'YYYY-MM-DD') from dual"]
    set to_date [db_string sd "select  to_char(to_date(:julian_date1, 'J'), 'YYYY-MM-DD') from dual"]
    # Determine all the members of the "closed" super-status
    set closed_stati [db_list closed_stati $closed_stati_select]
    set closed_stati_list [join $closed_stati ","]
    ###########################################################
    set closed_project_list  " 
                UNION select project_id 
                    from 
                        im_projects 
                    where 
                        to_char(closed_date,'YYYY-MM-DD')::date+2>'$to_date' 
                        and to_char(closed_date,'YYYY-MM-DD')::date+2<'$from_date'"
    ###########################################################
    set pesent_date_julian [db_string as "select to_char(sysdate,'J') from dual"]
    if {$pesent_date_julian > $next_week_julian_date} {
        set return_url [export_vars -base "new" {{julian_date $next_week_julian_date} user_id_from_search project_id show_week_p is_from_home_page}]
    } else {
        set return_url "$return_url"
    }
    ############################################################
} else {
    set page_title "[lang::message::lookup "" intranet-timesheet2.Date_for_user "%pretty_date% for %user_name_from_search%"]"
    set prev_day_julian_date [expr $julian_date - 1]
    set prev_day_url [export_vars -base "new" {{julian_date $prev_day_julian_date} user_id_from_search project_id show_week_p is_from_home_page}]
    set prev_day_link "<a href=$prev_day_url>$left_gif</a>"
    set today_date [db_string as "select to_char(to_date(:julian_date, 'J'), 'DD-Mon-YYYY') from dual"]
    set next_day_julian_date [expr $julian_date + 1]
    set next_day_url [export_vars -base "new" {{julian_date $next_day_julian_date} user_id_from_search project_id show_week_p is_from_home_page}]
    set next_day_link "<a href=$next_day_url>$right_gif</a>"
    set pesent_date_julian [db_string as "select to_char(sysdate,'J') from dual"]
    #
    if {$pesent_date_julian > $next_day_julian_date && $is_from_home_page==0} {
	   # set is_from_home_page 0
        set return_url [export_vars -base "new" {{julian_date $next_day_julian_date} user_id_from_search project_id show_week_p is_from_home_page}]
    } else {
        set return_url "$return_url"
    }
    set forward_backward_buttons "
	<tr>
	<td align=left>$prev_day_link</td>
	<td colspan=[expr 1+$internal_note_exists_p]><h2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$pretty_date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</h2></td>
	<td align=right>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$next_day_link</td>
	</tr>
    "
    set present_date12 [db_string as "select to_char('$today_date'::date,'YYYY-MM-DD') from dual"]
    # Determine all the members of the "closed" super-status
    set closed_stati [db_list closed_stati $closed_stati_select]
    set closed_stati_list [join $closed_stati ","]
    ###########################################################
    set closed_project_list "UNION select project_id from im_projects where to_char(closed_date,'YYYY-MM-DD')::date+2>=:present_date12::date"
    ###########################################################

}

set context_bar [im_context_bar [list index "[_ intranet-timesheet2.Hours]"] "[_ intranet-timesheet2.Add_hours]"]

set permissive_logging [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter PermissiveHourLogging -default "permissive"]

set log_hours_on_potential_project_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetLogHoursOnPotentialProjectsP -default 1]

set list_sort_order [parameter::get_from_package_key -package_key "intranet-timesheet2" -parameter TimesheetAddHoursSortOrder -default "order"]

set show_project_nr_p [parameter::get_from_package_key -package_key "intranet-core" -parameter ShowProjectNrAndProjectNameP -default 0]

# Should we allow users to log hours on a parent project, even though it has children?
set log_hours_on_parent_with_children_p [parameter::get_from_package_key -package_key "intranet-timesheet2" -parameter LogHoursOnParentWithChildrenP -default 1]

# "Solitary" projects are main projects without children.
# Some companies want to avoid logging on such projects.
set log_hours_on_solitary_projects_p [parameter::get_from_package_key -package_key "intranet-timesheet2" -parameter LogHoursOnSolitaryProjectsP -default 1]
# set log_hours_on_solitary_projects_p 0


# Determine how to show the tasks of projects. There are several options:
#	- main_project: The main project determines the subproject/task visibility space
#	- sub_project: Each (sub-) project determines the visibility of its tasks
#	- task: Each task has its own space - the user needs to be member of all tasks to log hours.
# Fix #1835325 from Koen van Winckel
set task_visibility_scope [parameter::get_from_package_key -package_key "intranet-timesheet2" -parameter TimesheetTaskVisibilityScope -default "sub_project"]

# Can the current user log hours for other users?
set add_hours_all_p [im_permission $user_id "add_hours_all"]

# What is a closed status?
set closed_stati_select "select * from im_sub_categories([im_project_status_closed])"
if {!$log_hours_on_potential_project_p} {
    append closed_stati_select " UNION select * from im_sub_categories([im_project_status_potential])"
}

# Determine all the members of the "closed" super-status
set closed_stati [db_list closed_stati $closed_stati_select]
set closed_stati_list [join $closed_stati ","]
###########################################################
# set closed_project_list [db_list closed "select project_id from im_projects where project_status_id not ($closed_stati_list) in and to_char(closed_date,'YYYY-MM-DD')::date+2<"]
###########################################################
# ad_return_complaint 1 "$closed_stati_list"
# ---------------------------------------------------------
# Select the list of days for the weekly view
# ---------------------------------------------------------

# Only show day '0' if we log for a single day
if {!$show_week_p} { set weekly_logging_days [list 0] }

# This check is necessary anymore: 

# if {$show_week_p} {
    # Bug from Genedata: Hours logged on Sa or Su could get deleted by the weekly
    # view if the parameter is set to "1 2 3 4 5". So we need to make sure all
    # days with logged hours are included in the list

    # Take the list of days in this week where the user has already logged hours...
    # set day_sql "
    #	select  distinct 
    #		to_char(h.day,'J')::integer - :julian_week_start::integer
    #	from    im_hours h
    #	where   h.user_id = :user_id_from_search and
    #		h.day between to_date(:julian_week_start,'J') and to_date(:julian_week_end,'J')
    # "
    # ... and append the days specified in the parameter
    # foreach d $weekly_logging_days {
    #	append day_sql "\tUNION select $d\n"
    # }
    # Retreive the list and make sure it's sorted
    # set weekly_logging_days [lsort [db_list extended_weeky_days $day_sql]] 
# }

# ---------------------------------------------------------
# Logic to check if the user is allowed to log hours
# ---------------------------------------------------------

set edit_hours_p "t"

# When should we consider the last month to be closed?
set last_month_closing_day [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetLastMonthClosingDay -default 0]

if {0 != $last_month_closing_day && "" != $last_month_closing_day && !$add_hours_all_p} {

    # Check that $julian_date is before the Nth of the next month:
    # Select the 1st day of the last month:
    set first_of_last_month [db_string last_month "
	select to_char(now()::date - :last_month_closing_day::integer + '0 Month'::interval, 'YYYY-MM-01')
    "]
    set edit_hours_p [db_string e "select to_date(:julian_date, 'J') >= :first_of_last_month::date"]

}

set edit_hours_closed_message [lang::message::lookup "" intranet-timesheet2.Logging_hours_has_been_closed "Logging hours for this date has already been closed. <br>Please contact your supervisor or the HR department."]


# ---------------------------------------------------------
# Build the SQL Subquery, determining the (parent)
# projects to be displayed 
# ---------------------------------------------------------

set main_project_id_list [list 0]
set main_project_id 0

if {[string is integer $project_id] && 0 != $project_id} {

    set main_project_id [db_string main_p "
	select	main_p.project_id
	from	im_projects p,
		im_projects main_p
	where	p.project_id = :project_id and
		tree_ancestor_key(p.tree_sortkey, 1) = main_p.tree_sortkey
    " -default 0]

    set parent_project_sql "
			select	:main_project_id::integer
    \t\t"

    # Project specified => only one project
    set one_project_only_p 1

    # Make sure the user can see everything below the single main project
    set task_visibility_scope "specified"

} elseif {[llength $project_id] > 1} {

    set main_project_id_list [db_list main_ps "
	select distinct
		main_p.project_id
	from	im_projects p,
		im_projects main_p
	where	p.project_id in ([join $project_id ","]) and
		tree_ancestor_key(p.tree_sortkey, 1) = main_p.tree_sortkey
    "]

    set parent_project_sql "
			select	p.project_id
			from	im_projects p
			where	p.project_id in ([join $main_project_id_list ","])
    \t\t"

    # An entire list of project has been selected
    set one_project_only_p 0

    # Make sure the user can see everything below the single main project
    set task_visibility_scope "specified"

} else {

    # Project_id unknown => select all projects
    set one_project_only_p 0

    set parent_project_sql "
	select	p.project_id
	from	im_projects p
	where 
		p.parent_id is null
		and p.project_id in (
				select	r.object_id_one
				from	acs_rels r
				where	r.object_id_two = :user_id_from_search
			    UNION
				select	project_id
				from	im_hours h
				where	h.user_id = :user_id_from_search
					and $h_day_in_dayweek
		)
		and p.project_status_id not in ($closed_stati_list)
		and p.project_type_id not in ([im_project_type_task], [im_project_type_ticket])
    "
}
# We need to show the hours of already logged projects.
# So we need to add the parents of these sub-projects to parent_project_sql.
append parent_project_sql "
    UNION
	-- Always show the main-projects of projects with logged hours
	select	main_p.project_id
	from	im_hours h,
		im_projects p,
		im_projects main_p
	where	h.user_id = :user_id_from_search
		and $h_day_in_dayweek
		and h.project_id = p.project_id
		and tree_ancestor_key(p.tree_sortkey, 1) = main_p.tree_sortkey
"
append parent_project_sql "
    $closed_project_list
"
# Determine how to show the tasks of projects.
switch $task_visibility_scope {
    "main_project" {
	# main_project: The main project determines the subproject/task visibility space
	set children_sql "
				select	sub.project_id
				from	acs_rels r,
					im_projects main,
					im_projects sub
				where	r.object_id_two = :user_id_from_search
					and r.object_id_one = main.project_id
					and main.tree_sortkey = tree_ancestor_key(sub.tree_sortkey, 1)
					and main.project_status_id not in ($closed_stati_list)
					and sub.project_status_id not in ($closed_stati_list)
	"
    }
    "specified" {
	# specified: We've got an explicit "project_id"
	# Show everything that's below, even if the user isn't a member.
	set children_sql "
				select	sub.project_id
				from	im_projects main,
					im_projects sub
				where	(	main.project_id = :main_project_id 
						OR main.project_id in ([join $main_project_id_list ","])
					)
					and main.project_status_id not in ($closed_stati_list)
					and sub.tree_sortkey between
						main.tree_sortkey and
						tree_right(main.tree_sortkey)
	"
	
        if { "restrictive" == $permissive_logging && $one_project_only_p } {
            set children_sql "$children_sql
                                and sub.project_id in (
                                        select  r.object_id_one
                                        from    acs_rels r
                                        where   r.object_id_two = :user_id_from_search
                                )
            "
        }

    }
    "sub_project" {
	# sub_project: Each (sub-) project determines the visibility of its tasks.
	# So we are looking for the "lowest" in the project hierarchy subproject
	# that's just above its tasks and controls the visibility of the tasks.
	# There are four conditions to determine the list of the "controlling" projects efficiently:
	#	- the controlling_project is a project
	#	- the task directly below the ctrl_project is a task.
	#	- the current user is member of the controlling project
	#	- the controlling_project is below the visible main projects 
	#	  (optional, may speedup query, but does not in general when all projects are selected)
	#
	# This query is slightly too permissive, because a single task associated with a main project
	# would make the main project the "controlling" project and show _all_ tasks in all subprojects,
	# even if the user doesn't have permissions for those. However, this can be fixed on the TCL level.
	set ctrl_projects_sql "
		select	distinct ctrl.project_id
		from	im_projects ctrl,
			im_projects task,
			acs_rels r
		where	
			task.parent_id = ctrl.project_id
			and ctrl.project_type_id not in ( [im_project_type_task], [im_project_type_ticket])
			and task.project_type_id in ( [im_project_type_task], [im_project_type_ticket] )
			and ctrl.project_status_id not in ($closed_stati_list)
			and task.project_status_id not in ($closed_stati_list)
			and r.object_id_one = ctrl.project_id
			and r.object_id_two = :user_id_from_search
	"

	set children_sql "
				-- Select any subprojects of control projects
				select	sub.project_id
				from	im_projects main,
					($ctrl_projects_sql) ctrl,
					im_projects sub
				where	ctrl.project_id = main.project_id
					and main.project_status_id not in ($closed_stati_list)
					and sub.project_status_id not in ($closed_stati_list)
					and sub.tree_sortkey between
						main.tree_sortkey and
						tree_right(main.tree_sortkey)
                    and sub.project_id in (select  r.object_id_one
                            from    acs_rels r
                            where   r.object_id_two = :user_id_from_search)
			UNION
				-- Select any project or task with explicit membership
				select  r.object_id_one
				from    acs_rels r
				where   r.object_id_two = :user_id_from_search
	"

    }
    "task" {
	# task: Each task has its own space - the user needs to be member of all tasks to log hours.
	set children_sql "
				-- Show sub-project/tasks only with direct membership
				select	r.object_id_one
				from	acs_rels r
				where	r.object_id_two = :user_id_from_search
	"
    }
}


set child_project_sql "
				$children_sql
			    UNION
				-- Always show projects and tasks where user has logged hours
				select	project_id
				from	im_hours h
				where	h.user_id = :user_id_from_search
					and $h_day_in_dayweek
			    UNION
			        -- Project with hours on it plus any of its superiors
				select	main_p.project_id
				from	im_hours h,
					im_projects p,
					im_projects main_p
				where	h.user_id = :user_id_from_search
					and $h_day_in_dayweek
					and h.project_id = p.project_id
					and p.tree_sortkey between
						main_p.tree_sortkey and
						tree_right(main_p.tree_sortkey)
			    UNION
				-- Always show the main project itself (it showing a single project, 0 otherwise)
				select	project_id from im_projects where project_id in ([join $project_id ","])
"

# ---------------------------------------------------------
# Build the main hierarchical SQL
# ---------------------------------------------------------

# The SQL is composed of the following elements:
#
# - The "parent" project, which contains the tree_sortkey information
#   that is necessary to determine its children.
#
# - The "children" project, which represents sub-projects
#   of "parent" of any depth.
#

set sort_integer 0
set sort_legacy  0
switch $list_sort_order {
    name { 
	set sort_order "lower(children.project_name)"
    }
    order { 
	set sort_order "children.sort_order"
	set sort_integer 1
    }
    legacy {
	set sort_order "children.tree_sortkey"
	set sort_legacy 1
    }
    default { 
	set sort_order "lower(children.project_nr)"
    }
}

set sql "
	select
		parent.project_id as top_project_id,
		parent.parent_id as top_parent_id,
		parent.project_name as top_parent_project_name,
		children.parent_id as parent_id,
		children.project_id as project_id,
		children.project_nr as project_nr,
		children.project_name as project_name,
		children.project_status_id as project_status_id,
		children.project_type_id as project_type_id,
		im_category_from_id(children.project_status_id) as project_status,
		parent.project_id as parent_project_id,
		parent.project_nr as parent_project_nr,
		parent.project_name as parent_project_name,
		tree_level(children.tree_sortkey) -1 as subproject_level,
		substring(parent.tree_sortkey from 17) as parent_tree_sortkey,
		substring(children.tree_sortkey from 17) as child_tree_sortkey,
		$sort_order as sort_order
	from
		im_projects parent,
		im_projects children
	where
		parent.parent_id is null
		and children.tree_sortkey between 
			parent.tree_sortkey and 
			tree_right(parent.tree_sortkey)
		and parent.project_id in ($parent_project_sql)
		and children.project_id in ($child_project_sql)
		-- exclude closed tickets
		and coalesce(
			(select ticket_status_id from im_tickets t where t.ticket_id = children.project_id),
			0
		) not in (
			select * from im_sub_categories([im_ticket_status_closed])
		)
	order by
		lower(parent.project_name),
		children.tree_sortkey
"
# ---------------------------------------------------------
# Select out the hours for the different projects and dates
#
# Effectively, we are replacing here an SQL join with a join
# over a TCL hash array. This simplifies the SQL and the TCL
# logic later.
# Also, there is a "LEFT OUTER" join logic, because we need
# to show the projects even if there are no hours available
# for them at that moment.
# ---------------------------------------------------------
set material_sql "
		,coalesce(h.material_id, :default_material_id) as material_id,
		(select material_name from im_materials m where m.material_id = h.material_id) as material
"
if {!$materials_p} { set material_sql "" }
# ---------------------------------------------------------
# Check if the specified hours are already included in a
# timesheet invoices. In such a case we can't modify them
# anymore.
# ---------------------------------------------------------

set hours_sql "
	select
		h.*,
		to_char(h.day, 'J') as julian_day,
		p.project_id
		$material_sql
	from
		im_hours h,
		im_projects p
	where
		h.project_id = p.project_id and
		h.user_id = :user_id_from_search and
		$h_day_in_dayweek
"
db_foreach hours_hash $hours_sql {
    set key "$project_id-$julian_day"
    set hours_hours($key) $hours
    set hours_note($key) $note
    set hours_internal_note($key) $internal_note
    if {"" != $invoice_id} {
        set hours_invoice_hash($key) $invoice_id
    }
    if {$materials_p} {
	set hours_material_id($key) $material_id
	set hours_material($key) $material
    }
}

# ad_return_complaint 1 [array get hours_invoice_hash]

# ---------------------------------------------------------
# Get the list of open projects with direct membership
# Task are all considered open
# ---------------------------------------------------------

array set member_projects_hash {}

set open_projects_sql "
	-- all open projects with direct membership
	select	p.project_id as open_project_id
	from	im_projects p,
		acs_rels r
	where	r.object_id_two = :user_id_from_search
		and r.object_id_one = p.project_id
    UNION
	-- all open projects and super-project where the user has logged hours.
	select	main_p.project_id as open_project_id
	from	im_hours h,
		im_projects p,
		im_projects main_p
	where	h.user_id = :user_id_from_search
		and $h_day_in_dayweek
		and h.project_id = p.project_id
		and tree_ancestor_key(p.tree_sortkey, 1) = main_p.tree_sortkey
"
array set member_projects_hash {}
db_foreach open_projects $open_projects_sql {
    set member_projects_hash($open_project_id) 1
}


# ---------------------------------------------------------
# Has-Children? This is used to disable super-projects with children
# ---------------------------------------------------------

set has_children_sql "
        select  parent_p.project_id as parent_id,
		child_p.project_id as child_id
        from
		im_projects main_p,
		im_projects parent_p,
		im_projects child_p
        where
		main_p.project_id in ($parent_project_sql) and
		tree_ancestor_key(parent_p.tree_sortkey, 1) = main_p.tree_sortkey and
		child_p.parent_id = parent_p.project_id and
		child_p.project_status_id not in ($closed_stati_list)
"

array set has_children_hash {}
array set has_parent_hash {}
db_foreach has_children $has_children_sql {
    set has_children_hash($parent_id) 1
    set has_parent_hash($child_id) 1
}

# ---------------------------------------------------------
# Execute query and format results
# ---------------------------------------------------------

db_multirow hours_multirow hours_timesheet $sql

# Sort the tree according to the specified sort order
multirow_sort_tree hours_multirow project_id parent_id sort_order


# ---------------------------------------------------------
# Format the output
# ---------------------------------------------------------

# Don't show closed and deleted projects:
# The tree algorithm maintains a "closed_level"
# that determines the sub_level of the last closed
# intermediate project.

set results ""
set ctr 0
set nbsps "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
set old_project_id 0
set closed_level 0
set closed_status [im_project_status_open]
set old_parent_project_nr ""

set showing_child_elements_p 0
set top_project_id_saved -1
set last_level_shown -1
set level_entered_in_showing_child_elements -1

set surpress_output_p 0

template::multirow foreach hours_multirow {

   if { "" != $search_task } {
       set search_task [string trim $search_task]
       # ns_log NOTICE "/intranet-timesheet2/www/hours/new::project_name: $project_name, search_task: $search_task, top_project_id: $top_project_id"
       if { !$showing_child_elements_p || $ctr==0 } {
	   if { [string first [string tolower $search_task] [string tolower $project_name]] == -1 } {
	       # ns_log NOTICE "/intranet-timesheet2/www/hours/new::String not found continuing ... "
	       set surpress_output_p 1
	   } else {
	       # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: ------- String found -------"
	       # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: Setting showing_child_elements_p = 1, setting top_project_id_saved: $top_project_id"
	       # Set mode
	       set showing_child_elements_p 1
	       # Save vars
	       set last_level_shown $subproject_level
	       set level_entered_in_showing_child_elements $subproject_level
	       set top_project_id_saved $top_project_id
	   }
	} else {
	    # We are in mode "Show child elements"
            ## ns_log NOTICE "/intranet-timesheet2/www/hours/new::In showing_child_elements_p"
            if { $top_project_id_saved != $top_project_id } {
                # We are in a new top parent project
                # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: top_project_id_saved: $top_project_id_saved != top_project_id:$top_project_id"
                # Reset
                set showing_child_elements_p 0
                # Save vars
                set top_project_id_saved $top_project_id

                if { [string first [string tolower $search_task] [string tolower $project_name]] == -1 } {
                    # ns_log NOTICE "/intranet-timesheet2/www/hours/new::String not found continuing ... "
		    set surpress_output_p 1
                } else {
                    # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: ------- String found -------"
                    # Set mode & last_level_shown
                    set showing_child_elements_p 1
		    set level_entered_in_showing_child_elements $subproject_level
                    set last_level_shown $subproject_level
                }
            } else {
		# ns_log NOTICE "/intranet-timesheet2/www/hours/new::Same Top Parent Project  ... "
                if { $subproject_level == $last_level_shown } {
		    # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: Current level is equal to the level the last item to show had: resetting"
		    if { $level_entered_in_showing_child_elements >= $subproject_level} {
			# reset last_level_shown
			# ns_log NOTICE "/intranet-timesheet2/www/hours/new:: level_entered_in_showing_child_elements: $level_entered_in_showing_child_elements >= subproject_level:$subproject_level -> resetting, check for searchstring"
			# Check for searchstring
			if { [string first [string tolower $search_task] [string tolower $project_name]] == -1 } {
                            # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: String not found continuing ... "
			    set surpress_output_p 1
			} else {
                            # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: ------- String found -------"
                            set last_level_shown $subproject_level
			}			
		    } else {
			set last_level_shown $subproject_level
		    }
                } elseif { $subproject_level > $last_level_shown } {
                        # show in all cases
                        # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: subproject_level > last_level_shown -> show item"
			set last_level_shown $subproject_level
                } else {
		    # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: subproject_level < last_level_shown"
		    if { $level_entered_in_showing_child_elements >= $subproject_level} {
			# ns_log NOTICE "/intranet-timesheet2/www/hours/new:: Check for searchstring"
			if { [string first [string tolower $search_task] [string tolower $project_name]] == -1 } {
			    # ns_log NOTICE "/intranet-timesheet2/www/hours/new::String not found, continuing ... "
			    set showing_child_elements_p 0
			    set surpress_output_p 1
			} else {
			    # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: ------- String found -------"
			    set last_level_shown $subproject_level
			}
		    } else {
			set last_level_shown $subproject_level
		    }
		}
	    }
	}
        # ns_log NOTICE "/intranet-timesheet2/www/hours/new:: ----------------------------------------------------------------------------"
        # set vars
        set top_project_id_saved $top_project_id
    }

    # --------------------------------------------- 
    # Deal with the open and closed subprojects
    # A closed project will prevent all sub-projects from being displayed. 
    # So it "leaves a trace" by setting the "closed_level" to its's current level.
    # The "closed_status" will be reset to "open", as soon as the next project 
    # reaches the same "closed_level".

    # Check for log_p - if the project is in one of the closed states
    switch $task_visibility_scope {
	"main_project" - "specified" {
	    # Membership is this specific project not necessary - just check status
	    set log_p 1
	    if {[lsearch -exact $closed_stati $project_status_id] > -1} { set log_p 0 }
	}
	"sub_project" {
	    # Control is with subprojects, tasks are always considered open.
	    set log_p [info exists member_projects_hash($project_id)]
	    if {$project_type_id == [im_project_type_task]} { set log_p 1 }
	    if {$project_type_id == [im_project_type_ticket]} { set log_p 1 }
	}
	"task" {
	    # Control is with each task individually
	     set log_p [info exists member_projects_hash($project_id)]
	}
    }


    # --------------------------------------------- 
    # Pull out information about the project. Variables:
    #
    #	closed_status		Controls the tree open/close logic (see below)
    #	closed_level		Controls the tree open/close logic (see below)
    #
    #	log_on_parent_p		Can we log hours on a parent project? We might just log on the children...
    #	user_is_project_member_p The user is a direct member of the project.	
    #	project_is_task_p	Project is a task. Tasks are considered "open".
    #	solitary_main_project_p	Marks single main projects without children. Some costomers don't allow logging on them.
    #	project_has_children_p	Does the project have children?
    #	project_has_parents_p	Does the project have a parent?
    #	
    #	
    #	log_p			Variable that controls closed_status
    #	closed_p		Final conclusion: Can we log hour or not?

    # Can we log hours on a parent?
    set log_on_parent_p 1
    if {!$log_hours_on_parent_with_children_p && [info exists has_children_hash($project_id)]} { set log_on_parent_p 0 }
  # Are we dealing with a task?
    set project_is_task_p [expr $project_type_id == [im_project_type_task] || $project_type_id == [im_project_type_ticket]]
    #mukesh@vmcpl 24-apr-2012 added code to disable log hours to tasks having child
	#Nikhil@vmcpl 30-jul-2012 edited code, so that we can display text box for logging hours for the task which have the child milestones 
		set pr_tsk [db_string sel "select distinct parent_id from im_projects p, im_timesheet_tasks t where p.parent_id = $project_id and t.planned_units not in (0) and p.project_id=t.task_id" -default 0]
		if {$pr_tsk!=0} {set log_on_parent_p 0}
    # Check if the user is a member of the project
    set user_is_project_member_p [info exists member_projects_hash($project_id)]
    # Are we dealing with a task?
    set project_is_task_p [expr $project_type_id == [im_project_type_task] || $project_type_id == [im_project_type_ticket]]

    # Check if this project is a "solitary" main-project
    # There are some companies that want to avoid logging hours
    # on such solitary projects.
    set solitary_main_project_p 1
    if {[info exists has_children_hash($project_id)]} { set solitary_main_project_p 0 }
    if {[info exists has_parent_hash($project_id)]} { set solitary_main_project_p 0 }
    if {$log_hours_on_solitary_projects_p} { set solitary_main_project_p 0 }
    if {$closed_status == [im_project_status_closed]} { set solitary_main_project_p 0 }

    # "family" relationships
    set project_has_children_p [info exists has_children_hash($project_id)]
    set project_has_parents_p [info exists has_parent_hash($project_id)]


    # ---------------------------------------------
    # Tree open/close logic

    # Change back from a closed branch to an open branch
    set pnam [string range $project_name 0 10]
    if {$subproject_level <= $closed_level} {
	ns_log Notice "new: $pnam: action: reset to open"
	set closed_status [im_project_status_open]
	set closed_level 0
    }

    ns_log Notice "new: $pnam: p=$project_id, depth=$subproject_level, closed_level=$closed_level, status=$project_status"

    set closed_p 0
    # We've just discovered a status change from open to closed:
    # Remember at what level this has happened to undo the change
    # once we're at the same level again:
    if {!$log_p && $closed_status == [im_project_status_open]} {
	ns_log Notice "new: $pnam: action: set to closed: log_p=$log_p, vis=$task_visibility_scope"
	set closed_status [im_project_status_closed]
	set closed_level $subproject_level
    }


    # ---------------------------------------------
    # Final decision: Should we log or not?
    # Check if the current tree-branch-status is "closed"
 #    set closed_p1 0
 #    # set present_date1 [expr $julian_date + 2]
 #    set present_date1 [db_string as "select to_char(to_date('$julian_date', 'J'), 'YYYY-MM-DD') "]
 # # set header_date [util_memoize [list db_string header ""]]
 #    set closed_date [db_string as "select to_char(closed_date,'YYYY-MM-DD')::date+2 from im_projects where project_id=$project_id" -default ""]
 #    
    # ---------------------------------------------
    # Indent the project line
    #
    set indent ""
    set level $subproject_level
    set dots_for_filter ""
    while {$level > 0} {
	set indent "$nbsps$indent"
	set level [expr $level-1]
	append dots_for_filter "."
    }

    if { "" != $dots_for_filter } {
	set dots_for_filter "<strong><a href='/intranet/projects/view?project_id=$top_project_id' style='text-decoration: none'><span style='color:#A9D0F5'>$top_parent_project_name $dots_for_filter</span></a></strong>"
    }

    # ---------------------------------------------
    # Insert intermediate header for every top-project
    if {$parent_project_nr != $old_parent_project_nr } { 
	set project_name "<b>$project_name</b>"
	set project_nr "<b>$project_nr</b>"

	# Add an empty line after every main project
	if {"" != $old_parent_project_nr || (0 == $ctr && "" != $search_task) } {
	    if { "" != $search_task } {	    
		append results "<tr class=rowplain><td colspan=99>$dots_for_filter</td></tr>\n"
	    } else {
		if { !$surpress_output_p } { append results "<tr class=rowplain><td colspan=99>&nbsp;</td></tr>\n" }
	    }	
	}
	set old_parent_project_nr $parent_project_nr
    }

    # ---------------------------------------------
    # Start the HTML column
    set project_url [export_vars -base "/intranet/projects/view?" {project_id return_url}]
    if { !$surpress_output_p } { append results "<tr $bgcolor([expr $ctr % 2])>\n" }

    # ---------------------------------------------
    # Write out the project title
    
    if {$show_project_nr_p} { set ptitle "$project_nr - $project_name" } else { set ptitle $project_name }
    # ad_return_complaint 1 "$julian_date"
    # Write out the name of the project nicely indented
    if { !$surpress_output_p } { 
        # if {$show_week_p} {
        #     set week_start $julian_date
        #     set week_end [expr $julian_date + 6]
        #     set closed_date1 ""
        #     set closed_date1 [db_string as "select to_char(closed_date,'YYYY-MM-DD')::date+2 from im_projects where project_id=$project_id" -default ""]
        #     if {$closed_date1==""} {
        #        set  is_closed_for_display 1
        #     } else {
        #         if {$closed_date1>=$week_start && $closed_date1<=$week_end} {
        #            set is_closed_for_display 1
        #         } else {
        #         set is_closed_for_display 0
        #         }
        #     }   
        # } else {
        #     set closed_date1 ""
        #     set is_closed_for_display 1
        #     set present_date1 [db_string as "select to_char(to_date('$julian_date', 'J'), 'YYYY-MM-DD') "]
        #     # set header_date [util_memoize [list db_string header ""]]
        #     set closed_date1 [db_string as "select to_char(closed_date,'YYYY-MM-DD')::date+2 from im_projects where project_id=$project_id" -default ""]
        #     if {$closed_date1<$present_date1} {
        #       set is_closed_for_display 0
        #     }
        #     if {$closed_date1==""} {
        #        set is_closed_for_display 1 
        #     }
        # }
        # if {$is_closed_for_display} {
        #     append results "<td><nobr>$indent <A href=\"$project_url\">$ptitle</A></nobr></td>\n" 
        # }
        append results "<td><nobr>$indent <A href=\"$project_url\">$ptitle</A></nobr></td>\n" 
    }

    # -----------------------------------------------
    # Create help texts to explain the user why certain projects aren't shown

    set help_text ""
    if {$closed_p && (!$user_is_project_member_p && $project_is_task_p)} { append help_text [lang::message::lookup "" intranet-timesheet2.Nolog_closed_p "The project or one of its parents has been closed or requires membership. "] }
    if {![string eq "t" $edit_hours_p]} { append help_text [lang::message::lookup "" intranet-timesheet2.Nolog_edit_hours_p "The time period has been closed for editing. "] }
    if {!$log_on_parent_p} { append help_text [lang::message::lookup "" intranet-timesheet2.Nolog_log_on_parent_p "This project has sub-projects or tasks. "] }
    if {$solitary_main_project_p} { append help_text [lang::message::lookup "" intranet-timesheet2.Nolog_solitary_main_project_p "This is a 'solitary' main project. Your system is configured in such a way, that you can't log hours on it. "] }

    # Not a member: This isn't relevant in all modes:
    switch $task_visibility_scope {
        "main_project" - "specified" {
	    # user_is_project_member_p not relevant at all.
	    set show_member_p 0
        }
        "sub_project" {
	    # user_is_project_member_p only relevant for projects, not for tasks,
	    # because it is the "controlling" (sub-) project that determines.
	    set show_member_p [expr !$project_is_task_p]
        }
        "task" {
	    # user_is_project_member_p relevant everywhere
	    set show_member_p 1
        }
	default { 
	    set show_member_p 0
	}
    }

    if {$show_member_p && !$user_is_project_member_p} { append help_text [lang::message::lookup "" intranet-timesheet2.Not_member_of_project "You are not a member of this project. "] }


    # -----------------------------------------------
    # Write out help and debug information
    set help_gif ""
    if {"" != $help_text} { set help_gif [im_gif help $help_text] }

    set debug_html ""
    if {$debug} {
	set debug_html "
	<nobr>
	sol=$solitary_main_project_p,
	mem=$user_is_project_member_p,
	log=$log_p,
	clo=$closed_p,
	</nobr>
	"
    }

    if { !$surpress_output_p } { append results "<td>$help_gif $debug_html</td>\n" }

    set ttt {
	chi=$project_has_children_p,
	par=$project_has_parents_p,
    }

    # -----------------------------------------------
    # Write out logging INPUT fields - either for Daily View (1 field) or Weekly View (7 fields)

    set i 0 
    set count 0
    set grand_tot_function ""
    foreach j $weekly_logging_days {
    	set julian_day_offset [expr $julian_date + $i]
    	set hours ""
    	set note ""
    	set internal_note ""
    	set material_id $default_material_id
    	set material "Default"
    	set key "$project_id-$julian_day_offset"
        # set present_date1 [expr $julian_date + 2]
        set closed_date1 ""
        set present_date1 [db_string as "select to_char(to_date('$julian_day_offset', 'J'), 'YYYY-MM-DD') "]
        # set header_date [util_memoize [list db_string header ""]]
        set closed_date1 [db_string as "select to_char(closed_date,'YYYY-MM-DD')::date+2 from im_projects where project_id=$project_id" -default ""]
        set is_submited_on [db_string as "select count(*) from im_hours where user_id=$user_id_from_search and to_char(day,'J')::integer=$julian_day_offset and is_submited='t'" -default 0]
        if {$is_submited_on>0} {
            set is_submited 1
        } else {
            set is_submited 0
        }
        ns_log Notice "nikhil456::is_submited======== $is_submited  $julian_day_offset "
        set closed_p1 0
        if {$closed_date1!=""} {
            if {$closed_date1<$present_date1} { 
                set closed_p1 1
             # ad_return_complaint 1 "$closed_p1"
            }
        }
    	if {[info exists hours_hours($key)]} { set hours $hours_hours($key) }
    	if {[info exists hours_note($key)]} { set note $hours_note($key) }
    	if {[info exists hours_internal_note($key)]} { set internal_note $hours_internal_note($key) }

    	if {[info exists hours_material_id($key)]} { set material_id $hours_material_id($key) }
    	if {[info exists hours_material($key)]} { set material $hours_material($key) }

    	# Determine whether the hours have already been included in a timesheet invoice
    	set invoice_id 0
    	set invoice_key "$project_id-$julian_day_offset"
    	if {[info exists hours_invoice_hash($invoice_key)]} { set invoice_id $hours_invoice_hash($invoice_key) }
        if {$hours==""} {
            set hours 0
        } else {
            set hours $hours
        }
    	if { "t" == $edit_hours_p && $log_on_parent_p && !$invoice_id && !$solitary_main_project_p && !$closed_p && !$surpress_output_p } {
    	    # Write editable entries.
#            if {$is_closed_for_display} {
            #--------------------------------------------------------------------------------------------------------------
            #Nikhil@vmcpl added code for disable text box for closed,and submited tasks
            #--------------------------------------------------------------------------------------------------------------
            set readonly12 ""
            if {$closed_p1|| $julian_day_offset>=$current_date1 || $is_submited} {
                # ad_return_complaint 1 "$project_name "
    	        set readonly12 "readonly=\"readonly\""
            }
            set user_id_for_edit [ad_get_user_id]
            set is_skip_timesheet_p [im_permission $user_id_for_edit skip_timesheet]
            # ad_return_complaint 1 "$user_id  [im_permission $user_id 'skip_timesheet']"
            # ad_return_complaint 1 "$user_id_for_edit [im_permission $user_id_for_edit skip_timesheet]"
            #If login user is a head authority he can edit timesheet for others also
            if {$is_skip_timesheet_p} {
                # ad_return_complaint 1 "$user_id"
                set readonly12 ""
            }
            if {$hours==""} {
                set hours 0
            } else {
                set hours [expr {round($hours)}]
            }
            ns_log Notice "nikhil123:::: $user_id readonly===$readonly12 $closed_p1 $project_name  $julian_day_offset $current_date $julian_day_offset>$current_date"
            append results "<td><INPUT ID=hours${i}.$project_id NAME=hours${i}.$project_id size=8 MAXLENGTH=8 value=\"$hours\" $readonly12></td>\n"
            if {!$show_week_p} {
        		append results "<td><INPUT ID=notes0.$project_id  NAME=notes0.$project_id size=$external_comment_size value=\"[ns_quotehtml [value_if_exists note]]\" $readonly12></td>\n"
        		if {$internal_note_exists_p} { append results "<td><INPUT NAME=internal_notes0.$project_id ID=internal_notes0.$project_id size=$internal_comment_size value=\"[ns_quotehtml [value_if_exists internal_note]]\" $readonly12></td>\n" }
        		if {$materials_p} { append results "<td>[im_select -translate_p 0 -ad_form_option_list_style_p 1 materials0.$project_id $material_options $material_id]</td>\n" }
        	    }
#            }    
        } else {
#            if {$is_closed_for_display} {
    	    if { $surpress_output_p } {    
        		# Filter in use - write only hidden fields
               
             
        		append results "<INPUT type=hidden NAME=hours${i}.$project_id ID=hours${i}.$project_id value=\"$hours\">\n"

              
        		if {!$show_week_p} {
        		    append results "<INPUT type=hidden NAME=notes0.$project_id ID=notes0.$project_id value=\"[ns_quotehtml [value_if_exists note]]\">\n"
        		    if {$internal_note_exists_p} { 
        			 append results "<INPUT TYPE=HIDDEN NAME=internal_notes0.$project_id value=\"[ns_quotehtml [value_if_exists internal_note]]\">\n" 
        		    }
        		    if {$materials_p} { append results "<input type=hidden name=materials0.$project_id value=$material_id>\n" }
        		}   
	        } else {
        		# Write Disabled because we can't log hours on this one
        		append results "<td>$hours <INPUT type=hidden NAME=hours${i}.$project_id value=\"$hours\"></td>\n"
        		if {!$show_week_p} {
    		        append results "<td>[ns_quotehtml [value_if_exists note]] <INPUT type=hidden NAME=notes0.$project_id value=\"[ns_quotehtml [value_if_exists note]]\"></td>\n"
        		    if {$internal_note_exists_p} { 
        			     append results "<td>[ns_quotehtml [value_if_exists internal_note]] <INPUT TYPE=HIDDEN NAME=internal_notes0.$project_id value=\"[ns_quotehtml [value_if_exists internal_note]]\"></td>\n" 
        		    }
        		    if {$materials_p} { append results "<td>$material <input type=hidden name=materials0.$project_id value=$material_id></td>\n" }
    	        }   
	        }
#        }
    	}
    	incr i
    }; # For each weekday
    if { !$surpress_output_p } { append results "</tr>\n" }
    incr ctr
    set surpress_output_p 0
}

if { [empty_string_p results] } {
    append results "
<tr>
  <td align=center><b>
    [_ intranet-timesheet2.lt_There_are_currently_n_1]<br>
    [_ intranet-timesheet2.lt_Please_notify_your_ma]
  </b></td>
</tr>\n"
}
append results "
    <tr> <td text-align=buttom><h3>Grand Total</h3></td><td></td>
    "
 foreach i $weekly_logging_days {
    # template::multirow foreach hours_multirow {
   append results "
       <td><input type=text name=$i id=$i value=0 maxlength=8 size=8 style=\"text-align: left;\" readonly=readonly onkeypress= \"return isNumericKey(event)\" onfocus=\"add(this.id)\"/></td>
"
# }
}
append results "
    </tr>
    "
set export_form_vars ""
set export_form_vars [export_form_vars return_url julian_date user_id_from_search show_week_p]
#ad_return_complaint 1 "$export_form_vars"
#Code to add grand total in timesheet page
append grand_tot_function "
            <script>
                function isNumericKey(e)
                    {
                        if (window.event) { var charCode = window.event.keyCode; }
                        else if (e) { var charCode = e.which; }
                        else { return true; }
                        if (charCode > 31 && (charCode < 48 || charCode > 57)) { return false; }
                        return true;
                    }
                   function add(e)
                    {
                        document.getElementById(e).value=0;
                     "
                    set a 0
                    template::multirow foreach hours_multirow { 
                             
                       append grand_tot_function " 
                            var b=e;  
                             var x ='hours';
                             var b=e;
                             var x=x+b;
                             var y='\.$project_id';
                             var x1=x+y;
                          
                            var k$a=document.getElementById(x1).value;
                              
                         "
                        incr a
                    }
                        

                        for {set m 0} {$m < $a} {incr m} {
                            append grand_tot_function "
                                var y =document.getElementById(e).value;
                                document.getElementById(e).value =parseInt(y)+parseInt(k$m);
                            "
                        } 
                      append grand_tot_function "  
                    }
                    </script>
            "

# ---------------------------------------------------------
# Format the weekly column headers
# ---------------------------------------------------------

# Date format for formatting
set weekly_column_date_format ""
set week_header_html ""


set i 0 
foreach j $weekly_logging_days {
    set julian_day_offset [expr $julian_week_start + $i]
    im_security_alert_check_integer -location "intranet-timesheet2/hours/new.tcl" -value $julian_day_offset
    set header_day_of_week [util_memoize [list db_string day_of_week "select to_char(to_date('$julian_day_offset', 'J'), 'Dy')"]]
    set header_day_of_week_l10n [lang::message::lookup "" intranet-timesheet2.Day_of_week_$header_day_of_week $header_day_of_week]
     set header_date [util_memoize [list db_string header "select to_char(to_date('$julian_day_offset', 'J'), 'Mon-dd')"]]
    # ad_return_complaint 1 "$header_date"
    if {$show_week_p} {
        append week_header_html "<td align=center class=rowtitle><h3>$header_day_of_week_l10n<br>$header_date<h3></td>\n"
    }
    incr i
}
#code to popup for adhoc task  
set project_options [db_list_of_lists opt "SELECT 
    
     im_project_name_from_id(r.object_id_one) as projectname,
      r.object_id_one as project_id
 from 
     acs_rels r,im_projects p,im_biz_object_members 
 where 
     r.object_id_one=p.project_id and r.object_id_two=$user_id
     and r.rel_id=im_biz_object_members.rel_id and p.parent_id is null "]
set project_options [linsert $project_options 0 {"" "" }]
#ad_return_complaint 1 "Nikhil"
append add_adhoc_html "
        <head>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"/intranet/www/style/style.saltnpepper.css\" media=\"screen\" />   
        <link rel=\"stylesheet\" type=\"text/css\" href=\"/intranet/www/style/style.common.css\" media=\"screen\" />  
        </head>
        <style type=\"text/css\">
       .parentDisable1{    
            -webkit-box-align: center;
            -webkit-box-orient: vertical;
            -webkit-box-pack: center;
           -webkit-transition: 200ms opacity;
            background-color: rgba(255, 255, 255, 0.75);
            bottom: 0;
            display: webkit-box;
            left: 0;
            overflow: auto;
            padding: 20px;
            position: fixed;
            right: 0;
            top: 0;
        }
        .rowtitle1 {
            background: url(\"/bg_portlet_heading.gif\") repeat-x scroll 0 0 transparent;
            height: 25px;
        }
        #popup1{    
           webkit-border-radius: 0px;
            webkit-box-orient: vertical;
            webkit-transition: 200ms webkit-transform;
            background: white;
            box-shadow: 0 4px 23px 5px rgba(0, 0, 0, 0.2), 0 2px 6px rgba(0, 0, 0, 0.15);
            color: #333;
             display: webkit-box;
            top: 40%; left: 40%;
             z-index: 9999;
            min-width: 400px;
            padding: 0;
            position: relevant;
         }

</style>
        <script type=\"text/javascript\">  
            function pop2(div)
            {    
            document.getElementById(div).style.display='block';
            return false
            }
            function hide2(div)
            {
            document.getElementById(div).style.display='none';
            return false
            }  
            function Checkfiles(f){
             f = f.elements;
              if(!document.forms\[\"myProfile\"\]\[\"uploadedFile\"]\.value)
             {
                alert('Please select the file and then click on upload button');
                 f\[\'uploadedFile\'\].focus();
                 return false
             }
            };
        </script>
    "
append add_adhoc_html "<a href onClick=\"return pop2('pop1')\">Create Adhoc Task</a>"
append add_adhoc_html "
<div id=\"pop1\" class=\"parentDisable1\">
   
    <table border=\"0\" id=\"popup1\" height=\"250\" width=\"425\">
     
    <form id=\"myProfile\" method=\"get\" action=\"new\" onsubmit=\"return Checkfiles(this);\">
        <tr class=\"rowtitle1\">
            <td align=\"top\" colspan=2 algin=\"right\" class=\"rowtitle1\">
                <div class=\"rowtitle1\"><h3>Add Adhoc Task</h3></div>
            </td>
            
            <td valign=\"top\">
                <div class=\"rowtitle1\"\"><a onClick=\"return hide2('pop1')\"><img src=\"/close_portlet.gif\" alt=\"X\"/></a></div>                     
            </td>
        </tr>
        <tr> 
            <td align=\"center\"  height=\"2px\"><b>Task Name<b/></td>         
            <td align=\"left\"  height=\"2px\">
                <input type=text name=task_name1 size=30/>
                    
            </td>
        </tr><tr>
            <td align=\"center\" height=\"2px\" ><b>Project Name<b/></td>         
            <td align=\"left\"height=\"2px\" >
                [im_select -ad_form_option_list_style_p 1 -translate_p 0 project_id1 $project_options $project_id1]
                
                
                    
            </td>
         </tr><tr  >

            <td align=\"center\" height=\"2px\"><b>Description<b/></td>         
            <td align=\"left\"  height=\"2px\">
                <textarea name=desc1 rows=\"4\" cols=\"33\"/></textarea>
                    
            </td>
        </tr>
        <tr><td/>
            <td colspan=\"1\" align=\"center\" font=\"50\"> <b><input type=\"submit\" value=\"Create Adhoc \" /></td></b>
            <input type=hidden name=flag value=1 />
            <input type=hidden name=return_url value=$return_url />
            <input type=hidden name=user_id_from_search value=$user_id_from_search />
            <input type=hidden name=show_week_p value=$show_week_p />
            <input type=hidden name=is_from_home_page value=$is_from_home_page />
            <input type=hidden name=julian_date value=$julian_date />
        </tr>                       
    </form>
    </table>
   
    </div>

"
# ---------------------------------------------------------
# Navbars
# ---------------------------------------------------------

set left_navbar_html "
      <div class='filter-block'>
        <div class='filter-title'>
	    Timesheet Filters
        </div>

	<form action=new method=GET>
	<!-- don't include return_url in the export_form_vars, as it includes the old user -->
	[export_form_vars julian_date show_week_p] 
	<table border=0 cellpadding=1 cellspacing=1>
	<tr>
	    <td>[lang::message::lookup "" intranet-timesheet2.Project_br_Name "Project<br>Name"]</td>
	    <td>[im_project_select -include_empty_p 1 -include_empty_name "" -project_status_id [im_project_status_open] -exclude_subprojects_p 1 project_id $project_id_for_default "open"]</td>
	</tr>
"
if {$add_hours_all_p} {
    append left_navbar_html "
	<tr>
	    <td>[lang::message::lookup "" intranet-timesheet2.Log_hours_for_user "Log Hours<br>for User"]</td>
	    <td>[im_user_select -include_empty_p 1 -include_empty_name "" user_id_from_search $user_id_from_search]</td>
	</tr>
    "
}

append left_navbar_html "
	<tr>
		<td>[lang::message::lookup "" intranet-timesheet2.SearchTask "Search<br>by Name"]:</td>
		<td><input type='text' size='17' maxlength='30' name='search_task' value='$search_task'></td>
	</tr>
"

append left_navbar_html "
	<tr><td></td><td><input type=submit value='Go'></td></tr>
	</table>
	</form>
      </div>
"

append left_navbar_html "
      <div class='filter-block'>
         <div class='filter-title'>
            #intranet-timesheet2.Other_Options#
         </div>
	 <ul>
	    <li>
	      <a href='$different_date_url'>
	        #intranet-timesheet2.lt_Log_hours_for_a_diffe#
	      </a>
            </li>
"

if {$user_id == $user_id_from_search && $add_absences_p} {
    append left_navbar_html "
	    <li><a href='$absences_url'>$absences_link_text</a></li>
    "
}

if {[im_permission $user_id_from_search view_projects_all]} {
    append left_navbar_html "
	    <li><a href='$different_project_url'>#intranet-timesheet2.lt_Add_hours_on_other_pr#</A></li>
    "
}
if {![empty_string_p $return_url]} {
    append left_navbar_html "
	    <li><a href='$return_url'>#intranet-timesheet2.lt_Return_to_previous_pa#</a></li>
    "
}
#ad_return_complaint 1 "$export_form_vars"
append left_navbar_html "
	    <!-- Dynamically added menu links -->
	    $menu_links_html

         </ul>
      </div>
"
