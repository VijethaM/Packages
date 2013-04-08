# /packages/intranet-timesheet2-task/www/new.tcl
#
# Copyright (c) 2003-2008 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    @param form_mode edit or display
    @author frank.bergmann@project-open.com
} {
    task_id:integer,optional
    { project_id:integer 0 }
    { return_url "" }
    { edit_p "" }
    { message "" }
    { form_mode "display" }
    { task_status_id:integer 76 }
    { assignee ""}
    { closed_date ""}
}

# ------------------------------------------------------------------
# Default & Security
# ------------------------------------------------------------------

# if {[info exists task_id]} {
#     callback im_timesheet_task_new_redirect -object_id [ad_conn object_id] -status_id "" -type_id "" -task_id $task_id -project_id $project_id \
# 	-edit_p $edit_p -message $message -form_mode $form_mode -task_status_id $task_status_id  -return_url $return_url
# } else {
#     callback im_timesheet_task_new_redirect -object_id [ad_conn object_id] -status_id "" -type_id "" -task_id "" -project_id $project_id -edit_p $edit_p \
# 	-message $message -form_mode $form_mode -task_status_id $task_status_id  -return_url $return_url
# }


set user_id [ad_maybe_redirect_for_registration]
set action_url "/intranet-timesheet2-tasks/new"
set focus "task.var_name"
set page_title [_ intranet-timesheet2-tasks.New_Timesheet_Task]
set base_component_title [_ intranet-timesheet2-tasks.Timesheet_Task]
set context [list $page_title]
if {"" == $return_url} { set return_url [im_url_with_query] }
set current_user_id $user_id

set normalize_project_nr_p [parameter::get_from_package_key -package_key "intranet-core" -parameter "NormalizeProjectNrP" -default 1]

# Check if this is really a task.
if {[info exists task_id]} {
    set object_type_id [db_string otype "select p.project_type_id from im_projects p where p.project_id = :task_id" -default ""]
    switch $object_type_id {
	"" {
	    # New timesheet task: Just continue 
	}
	100 {
	    # This is a timesheet task: Just continue
	}
	101 { 
	    # A ticket: Redirect
	    ad_returnredirect [export_vars -base "/intranet-helpdesk/new" {{form_mode DISPLAY} {ticket_id $task_id}}]
	    ad_script_abort
	}
	default {
	    ad_returnredirect [export_vars -base "/intranet/projects/view" {{project_id $task_id}}]
	    ad_script_abort
	}
    }
}


# Check the case if there is no project specified. 
# This is only OK if there is a task_id specified (new task for project).
if {0 == $project_id} {

    if {[info exists task_id]} {
	set project_id [db_string project_from_task "select project_id from im_timesheet_tasks_view where task_id = :task_id" -default 0]
	set return_url [export_vars -base "/intranet/projects/view" {project_id}]
    } else {
	ad_return_complaint 1 "You need to specify atleast a task or a project"
	return
    }
}



set project_name [db_string project_name "select project_name from im_projects where project_id=:project_id" -default "Unknown"]
append page_title " for '$project_name'"
if {![info exists task_id]} { set form_mode "edit" }
im_project_permissions $user_id $project_id project_view project_read project_write project_admin

# user_admin_p controls the "add members" link of the member components
set user_admin_p $project_admin

# Is the current user allowed to edit the timesheet task hours?
set edit_task_estimates_p [im_permission $user_id edit_timesheet_task_estimates]

switch $form_mode {
    display {
	if {!$project_read && ![im_permission $user_id view_timesheet_tasks_all]} {
	    ad_return_complaint 1 "You have insufficient privileges to see timesheet tasks for this project"
	    return
	}
    }
    edit {
	if {!$project_write} {
	    ad_return_complaint 1 "You have insufficient privileges to add/modify timesheet tasks for this project"
	    return
	}
    }
    default {
	ad_return_complaint 1 "Invalid form mode: '$form_mode'"
	return

    }
}



# most used material...
set default_material_id [db_string default_cost_center "
	select material_id
	from im_timesheet_tasks_view
	group by material_id
	order by count(*) DESC
	limit 1
" -default ""]

# Catch the case that there is no materials yet.
if {"" == $default_material_id} { set default_material_id [im_material_default_material_id] }

# Deal with no default material
if {"" == $default_material_id || 0 == $default_material_id} {
     ad_return_complaint 1 "
      <b>No default 'Material'</b>:<br>
      It seems somebody has deleted all materials in the system.<br>
      Please tell your System Administrator to go to Home - Admin -
      Materials and create at least one Material.
    "
}


set button_pressed [template::form get_action task]
if {"delete" == $button_pressed} {

    if {!$project_write} {
	ad_return_complaint 1 [lang::message::lookup "" intranet-timesheet2-tasks.No_permission_to_delete_a_task "You don't have the permission to delete a task"]
	ad_script_abort
    }
    db_exec_plsql task_delete {}
    ad_returnredirect $return_url

}


# ------------------------------------------------------------------
# Check if converted from a project
# ------------------------------------------------------------------

# ... then no entry in im_timesheet_tasks will be available and
# the select_query below will fail

if {[info exists task_id]} {

    set project_exists_p [db_string project_exists "
	select	count(*)
	from	im_projects
	where	project_id = :task_id
		and not exists (
			select	task_id
			from	im_timesheet_tasks
			where	task_id = :task_id
		)
    "]

    if {$project_exists_p} {


	# Create a new task entry
	db_dml insert_task "
		insert into im_timesheet_tasks (
			task_id, material_id, uom_id
		) values (
			:task_id, :default_material_id, [im_uom_hour]
		)
	"

    }

}

# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------

set type_options [im_timesheet_task_type_options -include_empty 0]
set material_options [im_material_options -include_empty 0]
set employee_options [db_list_of_lists opt "SELECT 
                       im_name_from_user_id(user_id) as name, user_id
            
        from 
            acs_rels,users,im_biz_object_members 
        where 
            object_id_two=user_id and object_id_one=$project_id   
            and acs_rels.rel_id=im_biz_object_members.rel_id"]
set employee_options [linsert $employee_options 0 {"" "" }]


set include_empty 1
set department_only_p 0
set cost_center_options [im_cost_center_options -include_empty $include_empty -department_only_p $department_only_p -cost_type_id [im_cost_type_timesheet]]
set uom_options [im_cost_uom_options 0]

set company_id ""
if {[info exists project_id]} { set company_id [db_string cid "select company_id from im_projects where project_id = :project_id" -default ""] }
set parent_project_options [im_project_options \
				-include_empty 0 \
				-exclude_subprojects_p 0 \
				-exclude_tasks_p 0 \
				-company_id $company_id \
]

set actions [list]
if {$project_write} {
    set actions [list [list [lang::message::lookup "" intranet-core.Action_Edit "Edit"] edit] ]
}

if {[im_permission $user_id add_tasks] && $project_write} {
    lappend actions {"Delete" delete}
}

set full_name_help [lang::message::lookup "" intranet-timesheet2-tasks.form_full_name_help "Full name for this task, indexed by the full-text search engine."]
set short_name_help [lang::message::lookup "" intranet-timesheet2-tasks.form_short_name_help "Short name or abbreviation for this task."]
set project_help [lang::message::lookup "" intranet-timesheet2-tasks.form_project_help "To which project does this task belong?"]
set material_help [lang::message::lookup "" intranet-timesheet2-tasks.form_material_help "The material determines how much you will charge your customer per unit."]
set cost_center_help [lang::message::lookup "" intranet-timesheet2-tasks.form_cost_center_help "Can you assign the costs for this task to a specific cost center? Use your best guess."]

set planned_help [lang::message::lookup "" intranet-timesheet2-tasks.form_planned_units_help "How many hours do you plan for this task (best guess)?"]
set billable_help [lang::message::lookup "" intranet-timesheet2-tasks.form_billable_units_help "How many hours will you be able to bill to your customer?"]
set percentage_completed_help [lang::message::lookup "" intranet-timesheet2-tasks.form_percentage_completed_help "How much of this task has already been done? Default is '0'."]
set emp_help [lang::message::lookup "" intranet-timesheet2-tasks.form_emp_help "Who has to complete this task?"]


ad_form \
    -name task \
    -cancel_url $return_url \
    -action $action_url \
    -actions $actions \
    -has_edit 1 \
    -mode $form_mode \
    -export {next_url user_id return_url} \
    -form {
	task_id:key
	{task_name:text(text) {label "[_ intranet-timesheet2-tasks.Name]"} {html {size 50}} {help_text $full_name_help}}
	{task_nr:text(hidden) {label "[_ intranet-timesheet2-tasks.Short_Name]"} {html {size 30}} {help_text $short_name_help}}
	{project_id:text(select) {label "[_ intranet-core.Project]"} {options $parent_project_options} {help_text $project_help}}
	{material_id:text(hidden) {label "[_ intranet-timesheet2-tasks.Material]"} {options $material_options} {help_text $material_help}}
	{cost_center_id:text(hidden),optional {label "[_ intranet-timesheet2-tasks.Cost_Center]"} {options $cost_center_options} {help_text $cost_center_help}}
	{task_type_id:text(hidden) {label "[_ intranet-timesheet2-tasks.Type]"} {options $type_options} }
	{task_status_id:text(im_category_tree) {label "[_ intranet-timesheet2-tasks.Status]"} {custom {category_type "Intranet Project Status"}}}
	{uom_id:text(hidden) {label "[_ intranet-timesheet2-tasks.UoM]<br>([_ intranet-timesheet2-tasks.Unit_of_Measure])"} {options $uom_options}}
	{assignee:text(select) {label "[_ intranet-timesheet2-tasks.Assignee]"} {options $employee_options} {help_text $emp_help } }
    }

if {$edit_task_estimates_p} {
    ad_form -extend -name task -form {
	{planned_units:float(hidden),optional {label "[_ intranet-timesheet2-tasks.Planned_Units]"} {html {size 10}} {help_text $planned_help} }
	{billable_units:float(hidden),optional {label "[_ intranet-timesheet2-tasks.Billable_Units]"} {html {size 10}} {help_text $billable_help}}
    }
} else {
    ad_form -extend -name task -form {
	{planned_units:float(hidden),optional}
	{billable_units:float(hidden),optional}
    }
}

if {1} {
    ad_form -extend -name task -form {
	{percent_completed:float(hidden),optional {label "[_ intranet-timesheet2-tasks.Percentage_completed]"} {html {size 10}} {help_text $percentage_completed_help}}
	{note:text(textarea),optional {label "[_ intranet-timesheet2-tasks.Note]"} {html {cols 40}}}
	{start_date:date(date),optional {label "[_ intranet-timesheet2.Start_Date]"} {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('start_date', 'y-m-d');" >}} }
	{end_date:date(date),optional {label "[_ intranet-timesheet2.End_Date]"} {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('end_date', 'y-m-d');" >}} }
    }
}

# Fix for problem changing to "edit" form_mode
set form_action [template::form::get_action "task"]
if {"" != $form_action} { set form_mode "edit" }


# Add DynFields to the form
set my_task_id 0
if {[info exists task_id]} { set my_task_id $task_id }
im_dynfield::append_attributes_to_form \
    -object_type "im_timesheet_task" \
    -object_subtype_id 100 \
    -form_id task \
    -object_id $my_task_id \
    -form_display_mode $form_mode


# Set default type to "Task"
set task_type_id [im_project_type_task]


ad_form -extend -name task -on_request {

    # Populate elements from local variables
    # ToDo: Check if these queries get too slow if the
    # system is in use during a lot of time...

    # Set default UoM to Hour
    set uom_id [im_uom_hour]

    # Set default CostCenter to the user's department, or otherwise the most used CostCenter

    set cost_center_id [db_string default_cost_center "select department_id from im_employees where employee_id = :user_id" -default ""]
    if {"" == $cost_center_id} {
    set cost_center_id [db_string default_cost_center "
	select cost_center_id 
	from im_timesheet_tasks_view 
	group by cost_center_id 
	order by count(*) DESC 
	limit 1
    " -default ""]
    }

    # Set default Material to most used Material
    set material_id $default_material_id

} -select_query {

	select	t.*,
	        p.parent_id as project_id,
	        p.project_name as task_name,
	        p.project_nr as task_nr,
	        p.percent_completed,
	        p.project_type_id as task_type_id,
	        p.project_status_id as task_status_id,
		to_char(p.start_date,'YYYY-MM-DD') as start_date,
		to_char(p.end_date,'YYYY-MM-DD') as end_date,
		p.reported_hours_cache,
		p.reported_hours_cache as reported_units_cache,
	        p.note,
	       
	       t.active_assignee as assignee
	from
	        im_projects p,
	        im_timesheet_tasks t,
	        acs_rels,
	        users u,
	        im_biz_object_members 
	where
	        t.task_id = :task_id and
		p.project_id = :task_id and
		object_id_two=user_id and object_id_one=:task_id   
            and acs_rels.rel_id=im_biz_object_members.rel_id
            LIMIT 1


	

} -new_data {

    if {!$project_write} {
	ad_return_complaint 1 "You have insufficient privileges to add/modify timesheet tasks for this project"
	ad_script_abort
    }
    # Issue from Anke@opus5: project_path is unique
    # ToDo: Make path unique, or distinguish between
    # task_nr and project_path

    set task_nr [string tolower $task_nr]
    set start_date_sql [template::util::date get_property sql_date $start_date]
    set end_date_sql [template::util::date get_property sql_timestamp $end_date]

    if {[catch {

	db_string task_insert {}
	db_dml task_update {}
	db_dml project_update {}

        im_dynfield::attribute_store \
            -object_type "im_timesheet_task" \
            -object_id $task_id \
            -form_id task

         
	# Add the users of the parent_project to the ts-task
	set pm_role_id [im_biz_object_role_project_manager]
	im_biz_object_add_role $current_user_id $task_id $pm_role_id
	set member_sql "
		select	object_id_two as user_id,
			bom.object_role_id as role_id
		from	acs_rels r,
			im_biz_object_members bom
		where	r.rel_id = bom.rel_id and
			object_id_one = :project_id
	"
	# db_foreach members $member_sql {
	#     im_biz_object_add_role $user_id $task_id $role_id
	# }

	# Write Audit Trail
	im_project_audit -project_id $task_id -action after_create

    } err_msg]} {
	ad_return_complaint 1 "<b>Error inserting new task</b>:
	<pre>$err_msg</pre>"
    }

    # Update percent_completed
    im_timesheet_project_advance $task_id


} -edit_data {

    if {!$project_write} {
	ad_return_complaint 1 "You have insufficient privileges to add/modify timesheet tasks for this project"
	ad_script_abort
    }

    set task_nr [string tolower $task_nr]
    set start_date_sql [template::util::date get_property sql_date $start_date]
    set end_date_sql [template::util::date get_property sql_timestamp $end_date]

    set task_position [db_string s "select task_position from im_projects where project_id=$task_id" -default 0]
   
    set project_status [db_string d "select im_category_from_id(project_status_id) from im_projects where project_id=$project_id" -default ""]
    set current_task_status [db_string dd "select im_category_from_id($task_status_id) from dual " -default ""]
  	if {$current_task_status!="Yet To Start" && $project_status=="Yet To Start"} {
  		ad_return_complaint 1 "please Start the Project"
  	}

    if {$task_position>1} {
    	set previous_task_status [db_string s  "select im_category_from_id(project_status_id) 
    										from  im_projects 
    										where task_position =($task_position-1) 
    									    and parent_id=(select parent_id from im_projects where project_id=$task_id)" -default ""]
    	
    	if {(($current_task_status=="Work In Progress" || $current_task_status=="Closed") && $previous_task_status!="Closed")} {
    		ad_return_complaint 1 "Please Close Previous Task "
    		ad_script_abort
    	} elseif {$current_task_status=="Closed"} {
    		set folder_id [util_memoize [list intranet_fs::get_project_folder_id_not_cached -project_id $task_id]]
    	
    		set num_docs_config [db_string s "select num_docs 
    											from im_vmc_config_tasks 
    											where im_category_from_id(project_type_id)=(select im_category_from_id(project_type_id) 
    																		from im_projects 
    																		where project_id=$project_id)
														and im_category_from_id(task_name_id)='$task_name'" -default 0]

			set uploaded_doc_count [db_string d "select count(*) from cr_items where parent_id=$folder_id" -default 0]
			if {$num_docs_config > $uploaded_doc_count} {
				ad_return_complaint 1 "Please Upload all documents and then close the task."
				ad_script_abort
			}
			set doc_type_id1_mand [db_string ds "select doc_type_id1 from im_vmc_config_tasks where im_category_from_id(project_type_id)=
																			(select im_category_from_id(project_type_id) 
    																		from im_projects 
    																		where project_id=$project_id)
														and im_category_from_id(task_name_id)='$task_name'
														and doc_mandatory1='t'" -default 0]
			set is_exist_doc1 ""
			set is_exist_doc2 ""
			set is_exist_doc3 ""
			if {$doc_type_id1_mand!=0} {
				set is_exist_doc1 [db_string s "select count(*) from fs_files where parent_id=$folder_id and doc_type=$doc_type_id1_mand" -default 0]
			}

			if {$is_exist_doc1 == 0} {
				ad_return_complaint 1 "Please Upload all mandatory Documnets1"
				ad_script_abort
			} else {

				set doc_type_id2_mand [db_string ds "select doc_type_id2 from im_vmc_config_tasks where im_category_from_id(project_type_id)=
																			(select im_category_from_id(project_type_id) 
    																		from im_projects 
    																		where project_id=$project_id)
														and im_category_from_id(task_name_id)='$task_name'
														and doc_mandatory2='t'" -default 0]

				if {$doc_type_id2_mand!=0} {
					set is_exist_doc2 [db_string s "select count(*) from fs_files where parent_id=$folder_id and doc_type=$doc_type_id2_mand" -default 0]
				}

				if {$is_exist_doc2 == 0} {
					ad_return_complaint 1 "Please Upload all mandatory Documnets2"
					ad_script_abort
				} else {
					set doc_type_id3_mand [db_string ds "select doc_type_id3 from im_vmc_config_tasks where im_category_from_id(project_type_id)=
																			(select im_category_from_id(project_type_id) 
    																		from im_projects 
    																		where project_id=$project_id)
														and im_category_from_id(task_name_id)='$task_name'
														and doc_mandatory3='t'" -default 0]

					if {$doc_type_id3_mand!=0} {
						set is_exist_doc3 [db_string s "select count(*) from fs_files where parent_id=$folder_id and doc_type=$doc_type_id3_mand" -default 0]
					}

					if {$is_exist_doc3 == 0} {
						ad_return_complaint 1 "Please Upload all mandatory Documnets3"
						ad_script_abort
					} 



					
				}


			}

			set closed_date ", closed_date=(select current_date from dual)::date"
			db_dml update_next_task "
							update im_projects 
								set project_status_id=(select category_id from im_categories where category_type='Intranet Project Status' and category='Work In Progress')
								where project_id=(select project_id from im_projects where parent_id=$project_id and task_position > $task_position order by task_position LIMIT 1)
			"

			set last_task_position [db_string xx "select max(task_position) from im_projects where parent_id=$project_id" -default ""]
			if {$last_task_position==$task_position} {
				db_dml update_project "update im_projects 
										set project_status_id=(select category_id from im_categories where category_type='Intranet Project Status' and category='Closed')
										$closed_date
										where project_id=$project_id"
			}

		
		}


    }
    #-------------------------------------------------------------------------------
    #Nikhil added code to deal with the Assignee
    #-------------------------------------------------------------------------------
    set is_assignee_change [db_string as "select count(*) from im_timesheet_tasks where task_id=$task_id and active_assignee=$assignee" -default 0]
    if {!$is_assignee_change} {
    	db_dml update_Assignee "
    		update
    			im_timesheet_tasks
    		set 
    			active_assignee=$assignee,
    			 assigned_by=$current_user_id
    		where 
    			task_id=$task_id

    	"
    }



    db_dml task_update {}
    db_dml project_update {}

    im_dynfield::attribute_store \
	-object_type "im_timesheet_task" \
	-object_id $task_id \
	-form_id task

    # Update percent_completed
    im_timesheet_project_advance $task_id

    # Reset the time_phase date for this relationship
    im_biz_object_delete_timephased_data -task_id $task_id

    # Write Audit Trail
    im_project_audit -project_id $task_id -action after_update

    


} -on_submit {
	ns_log Notice "new: on_submit"

} -after_submit {
	# set res_id "SELECT 
 #            user_id as re_id
 #        from 
 #            acs_rels,users,im_biz_object_members 
 #        where 
 #            object_id_two=user_id and object_id_one=:task_id
 #            and acs_rels.rel_id=im_biz_object_members.rel_id" 

	# db_foreach x $res_id {
	# 	 db_string delete_resource "select im_biz_object_member__delete (:task_id, :re_id);"
	# }

	ad_returnredirect "/intranet/member-add-2?object_id=$task_id&return_url=/intranet/projects/view?project_id=$project_id&user_id_from_search=$assignee&role_id=1300&notify_asignee=0"
	# ad_returnredirect $return_url
	ad_script_abort

} -validate {
    {task_nr
	{ [string length $task_nr] < 30 }
	"[lang::message::lookup {} intranet-timesheet2-tasks.Short_Name_too_long {Short Name too long (max 30 characters).}]" 
    }
    {task_nr
	{ [regexp {^[a-zA-Z0-9_]+$} $task_nr match] }
	"Short Name contains non-alphanum characters." 
    }
}


# ---------------------------------------------------------------
# Project Menu
# ---------------------------------------------------------------

# Setup the subnavbar
set bind_vars [ns_set create]
ns_set put $bind_vars project_id $project_id
set project_menu_id [db_string parent_menu "select menu_id from im_menus where label='project'" -default 0]
set sub_navbar [im_sub_navbar \
    -components \
    -base_url "/intranet/projects/view?project_id=$project_id" \
    $project_menu_id \
    $bind_vars "" "pagedesriptionbar" "project_timesheet_task"] 

