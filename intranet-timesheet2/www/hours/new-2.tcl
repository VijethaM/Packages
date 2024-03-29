# /www/intranet-timesheet2/hours/new-2.tcl
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
    Writes hours to db. <br>
    The page acutally works like a "synchronizer" that compares the 
    hours already in the DB with the hours entered, determines the
    necessary action (delete, update, insert) and executes that action.

    @param hours0 Hash array (project_id -> hours) with the hours
                  for the given day and user.
    @param julian_date Julian date of the first day in the hours array
                       With single-day logging, this is the day for logging.
                       With weekly logging, this is the start of the week (Sunday!)
    @param show_week_p Set to "1" if we are storing hours for an entire week,
                       "0" for logging hours on a single day.

    @author dvr@arsdigita.com
    @author mbryzek@arsdigita.com
    @author frank.bergmann@project-open.com
} {
    hours0:array,optional
    hours1:array,optional
    hours2:array,optional
    hours3:array,optional
    hours4:array,optional
    hours5:array,optional
    hours6:array,optional
    notes0:array,optional
    internal_notes0:array,optional
    materials0:array,optional
    julian_date:integer
    { return_url "" }
    { show_week_p 0}
    { user_id_from_search "" }
    {project_id1:integer 0}
    {task_name1 ""}
    {desc1 ""}
    {save ""}
    {submit ""}
    {is_submited 0}
    {location_id 75242}
}

# ----------------------------------------------------------
# Default & Security
# ----------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set current_user_id [ad_maybe_redirect_for_registration]
if {"" == $user_id_from_search || ![im_permission $user_id "add_hours_all"]} { set user_id_from_search $user_id }
set date_format "YYYY-MM-DD"
set default_currency [ad_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]
set wf_installed_p [util_memoize "db_string timesheet_wf \"select count(*) from apm_enabled_package_versions where package_key = 'intranet-timesheet2-workflow'\""]
#ad_return_complaint 1 "Nikhil     $wf_installed_p     $export_form_vars"
set materials_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter HourLoggingWithMaterialsP -default 0]
set material_name ""
set material_id ""

# should we limit the max number of hours logged per day?
set max_hours_per_day [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetMaxHoursPerDay -default 24]

# Is employee at least member of an office  
# in which employees have no restrictions in regards to 
# maximum hours logged per day 

set sql "
	select 
		count(*)
	from 
		acs_rels r,
		acs_objects o,
		im_offices of
	where 
		o.object_id = r.object_id_one and
		of.office_id = r.object_id_one and
		o.object_type = 'im_office' and
		rel_type = 'im_biz_object_member' and 
		object_id_two = :user_id_from_search and 
		of.ignore_max_hours_per_day_p = 't'
"

set count_ignore_max_hours_per_day [db_string get_data $sql -default 0]
set err_msg_html ""
if { $count_ignore_max_hours_per_day > 0  } {
	set max_hours_per_day 999 
}

# Conversion factor to calculate days from hours. Make sure it's a float number.
set hours_per_day [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetHoursPerDay -default 10]
set hours_per_day [expr $hours_per_day * 1.0]

set limit_to_one_day_per_main_project_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetLimitToOneDayPerUserAndMainProjectP -default 1]

set sync_cost_item_p [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter "SyncHoursImmediatelyAfterEntryP" -default 1]

set check_all_hours_with_comment [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter "ForceAllTimesheetEntriesWithCommentP" -default 1]


if {![im_column_exists im_hours internal_note]} {
    ad_return_complaint 1 "Internal error in intranet-timesheet2:<br>
	The field im_hours.internal_note is missing.<br>
	Please notify your system administrator to upgrade
	your system to the latest version.<br>
    "
    ad_script_abort
}

# ----------------------------------------------------------
# Check that the comment has been specified for all hours
# if necessary
# ----------------------------------------------------------

if {!$show_week_p && $check_all_hours_with_comment} {
    foreach key [array names hours0] {
	set h $hours0($key)
	set c $notes0($key)
	if {"" == $h} { continue }

	if {"" == $c} {
	    ad_return_complaint 1 "
		<b>You hav to enter Comment for hours</b>:
	    "
	    ad_script_abort
	}
    }
}


# ----------------------------------------------------------
# Billing Rate & Currency
# ----------------------------------------------------------

set billing_rate 0
set billing_currency ""

db_0or1row get_billing_rate "
	select	hourly_cost as billing_rate,
		currency as billing_currency
	from	im_employees
	where	employee_id = :user_id_from_search
"

if {"" == $billing_currency} { set billing_currency $default_currency }


# ----------------------------------------------------------
# Start with synchronization
# ----------------------------------------------------------

# Add 0 to the days for logging, as this is used for single-day entry
set weekly_logging_days [parameter::get_from_package_key -package_key intranet-timesheet2 -parameter TimesheetWeeklyLoggingDays -default "0 1 2 3 4 5 6"]
# Add a "0" to refer to the current day for single-day logging.
set weekly_logging_days [set_union $weekly_logging_days [list 0]]
# Logging hours for a single day?
if {!$show_week_p} { set weekly_logging_days [list 0]}


# Go through all days of the week (or just a single one in case of single-day logging
set i 0 
foreach j $weekly_logging_days {

    set day_julian [expr $julian_date+$i]
    ns_log Notice "hours/new2: day=$i: ----------- day_julian=$day_julian -----------"

    array unset database_hours_hash
    array unset database_notes_hash
    array unset database_internal_notes_hash
    array unset database_materials_hash
    array unset hours_cost_id
    array unset action_hash

    set material_sql "
			,h.material_id,
			(select material_name from im_materials m where m.material_id = h.material_id) as material_name
    "
    if {!$materials_p} { set material_sql "" }


    # ----------------------------------------------------------
    # Get the list of the hours of the current user today,
    # together with the main project (needed for ConfirmationObject).
    set database_hours_logged_sql "
		select	
			h.*,
			p.project_id as hour_project_id,
			h.cost_id as hour_cost_id
		from
			im_hours h,
			im_projects p
		where
			h.user_id = :user_id_from_search and
			h.day = to_date(:day_julian, 'J') and
			h.project_id = p.project_id
    "
    db_foreach hours $database_hours_logged_sql {

        set key "$hour_project_id"
	if {"" == $hours} { set hours 0 }

	# Store logged hours into Hash arrays.
    	set database_hours_hash($key) $hours
    	set database_notes_hash($key) $note
    	set database_internal_notes_hash($key) [value_if_exists internal_note]
    	set database_materials_hash($key) $material_name

	# Setup (project x day) => cost_id relationship
	if {"" != $hour_cost_id} {
	    set hours_cost_id($key) $hour_cost_id
	}
    }
    
    # ----------------------------------------------------------
    # Extract the information from "screen" into hash array with
    # same structure as the one from the database
   
    array unset screen_hours_hash
    set screen_hours_elements [array get hours$i]
    array set screen_hours_hash $screen_hours_elements

    array unset screen_notes_hash
    set screen_notes_elements [array get notes$i]
    array set screen_notes_hash $screen_notes_elements

    array unset screen_internal_notes_hash
    set screen_internal_notes_elements [array get internal_notes$i]
    array set screen_internal_notes_hash $screen_internal_notes_elements

    array unset screen_materials_hash
    set screen_materials_elements [array get materials$i]
    array set screen_materials_hash $screen_materials_elements

    # Get the list of the union of key in both array
    set all_project_ids [set_union [array names screen_hours_hash] [array names database_hours_hash]]
    
    # Create the "action_hash" with a mapping (pid) => action for all lines where we
    # have to take an action. We construct this hash by iterating through all entries 
    # (both db and screen) and comparing their content.


    set total_screen_hours 0 
    foreach pid $all_project_ids {
	# Extract the hours and notes from the database hashes
	set db_hours ""
	set db_notes ""
	set db_internal_notes ""
	set db_materials ""
	if {[info exists database_hours_hash($pid)]} { set db_hours $database_hours_hash($pid) }
	if {[info exists database_notes_hash($pid)]} { set db_notes [string trim $database_notes_hash($pid)] }
	if {[info exists database_internal_notes_hash($pid)]} { set db_int_notes [string trim $database_internal_notes_hash($pid)] }
	if {[info exists database_materials_hash($pid)]} { set db_materials [string trim $database_materials_hash($pid)] }

	# Extract the hours and notes from the screen hashes
	set screen_hours ""
	set screen_notes ""
	set screen_internal_notes ""
	set screen_materials ""
	if {[info exists screen_hours_hash($pid)]} { set screen_hours $screen_hours_hash($pid) }
	if {[info exists screen_notes_hash($pid)]} { set screen_notes [string trim $screen_notes_hash($pid)] }
	if {[info exists screen_internal_notes_hash($pid)]} { set screen_internal_notes [string trim $screen_internal_notes_hash($pid)] }
	if {[info exists screen_materials_hash($pid)]} { set screen_materials [string trim $screen_materials_hash($pid)] }
	# set screen_hours [expr {round($screen_hours)}]
	if {"" != $screen_hours} {
	    if {![string is double $screen_hours] || $screen_hours < 0} {
		ad_return_complaint 1 "<b>[lang::message::lookup "" intranet-timesheet2.Only_positive_numbers_allowed "Only positive numbers allowed"]</b>:<br>
	         [lang::message::lookup "" intranet-timesheet2.Only_positive_numbers_allowed_help "
	   		The number '$screen_hours' contains invalid characters for a numeric value.<br>
			Please use the characters '0'-'9' and the '.' as a decimal separator. 
	         "]"
		ad_script_abort
		
	    }
	    set total_screen_hours [expr $total_screen_hours + $screen_hours]

	}

	
	set is_submited1 [db_string as "select is_submited from im_hours where project_id=$pid and user_id=$user_id_from_search and to_char(day,'J')::integer=$day_julian" -default 0]
	# Determine the action to take on the database items from comparing database vs. screen
	set action error
	if {$db_hours == "" && $screen_hours != ""} { set action insert }
	if {$db_hours != "" && $screen_hours == ""} { set action delete }
	if {$db_hours != "" && $screen_hours != ""} { set action update }

	if {$db_hours == $screen_hours} { set action update }

	# Deal with the case that the user has only changed the comment (in the single-day view)
	if {"skip" == $action && !$show_week_p && $db_notes != $screen_notes} { set action update }
	if {"skip" == $action && !$show_week_p && $db_internal_notes != $screen_internal_notes} { set action update }
	if {"skip" == $action && !$show_week_p && $db_materials != $screen_materials} { set action update }

	ns_log Notice "hours/new-2: pid=$pid, day=$day_julian, db:'$db_hours', screen:'$screen_hours' => action=$action => $save === $submit =>is_submitted=$is_submited"
	set current_date1 [db_string as "select to_char(sysdate,'J') from dual"]
	set present_date1 [db_string as "select to_char(to_date('$day_julian', 'J'), 'YYYY-MM-DD') "]
    if {$present_date1 >$current_date1} {set action skip}
	if {"skip" != $action} { set action_hash($pid) $action }
    }
    #Code to check wheater enter day is holiday or weekend or saved to validate hours
    set closed_date1 ""
    set current_date1 [db_string as "select to_char(sysdate,'J') from dual"]
	set present_date1 [db_string as "select to_char(to_date('$day_julian', 'J'), 'YYYY-MM-DD') "]
    # if {$present_date1 >$current_date1} {set action skip}
    # set header_date [util_memoize [list db_string header ""]]
    set closed_date1 [db_string as "select to_char(closed_date,'YYYY-MM-DD')::date+2 from im_projects where project_id=$pid" -default ""]
    set is_submited_no [db_string as "select count(*) from im_hours where user_id=$user_id_from_search and to_char(day,'J')::integer=$day_julian and is_submited='t'" -default 0]
    if {$is_submited_no>0} {
    	set is_submited 1
    } else {
    	set is_submited 0
    }
    # ns_log Notice "nikhil456::is_submited======== $is_submited  $julian_day_offset "
    set today_date [db_string sd "select  to_char(to_date(:day_julian, 'J'), 'YYYY-MM-DD') from dual"]
    set today_date1 [db_string sd "select  to_char(to_date(:day_julian, 'J'), 'DD-Mon-yyyy') from dual"]
	set closed_p1 0
    if {$closed_date1!=""} {
        if {$closed_date1<$present_date1} { 
            set closed_p1 1
         	# ad_return_complaint 1 "$closed_p1"
        }
    }
	set err_msg_html ""
	if {$total_screen_hours<8 || $total_screen_hours>24} {
		if {$save!=""} {
			if {$total_screen_hours==0} {
				set is_entered 0
			} else {
				set is_entered 1
			}
		} else {
			set is_entered 0
		}
		set is_day [db_string as "select extract('dow' from '$today_date'::date) from dual"]
		if {$is_day==0 ||$is_day==6} {
			set is_weekend 1
		} else {
			set is_weekend 0
		}
		set is_holiday [db_string s "select count(*) from im_vmc_holiday_list where to_char(date,'YYYY-MM-DD')='$today_date' and location_id=$location_id"]        
 		if {$is_holiday>=1} {
 			set is_holiday 1
 		} else {
 			set is_holiday 0
 		}
 		# ad_return_complaint 1 "$is_entered"
 		if {$closed_p1|| $day_julian>=$current_date1 || $is_submited || $is_entered || $is_weekend || $is_holiday} {
			set flag3 0
		} else {
			
			set x [ad_get_logout_url]
#			ad_returnredirect "/$x"
			ad_return_complaint 1 "
                                          You have to log hours between 8 to 24, for the day $today_date1. Please go back and correct the entry. </b>"
# 			set ab "You have to log hours between 8 to 24, for the day . Please go back and correct the entry. "
#                        error "You have to log hours between 8 to 24, for the day . Please go back and correct the entry. "
			
			ad_script_abort
			
		}
	}
#	ad_return_complaint 1 "$user_id_from_search $current_user_id"
	if {$submit!=""} {
		set prev_not_submit [db_string as "select count(*) from im_hours where user_id=$user_id_from_search and to_char(day,'YYYY-MM-DD')<='$today_date' and is_submited='f'" -default 0]
		if {$prev_not_submit>0} {
			set is_not_submit_for_prev 1
		} else {
			set is_not_submit_for_prev 0
		}
		if {$is_not_submit_for_prev && $user_id_from_search==$current_user_id} {
			ad_return_complaint 1 "Please Go back and submit for previous days"
			ad_script_abort
		}

	}
    if {$total_screen_hours > $max_hours_per_day} {
	ad_return_complaint 1 "<b>[lang::message::lookup "" intranet-timesheet2.Number_too_big_for_param "Number is larger then allowed"]</b>:<br>
            [lang::message::lookup "" intranet-timesheet2.Number_too_big_help "
                   You have logged more hours (%total_screen_hours%) then allowed.<br>
                   Please log no more than '%max_hours_per_day%' hours for one day.
	    "]"
            ad_script_abort
    }

    ns_log Notice "hours/new2: day=$i, database_hours_hash=[array get database_hours_hash] ===== is_submitted=$is_submited"
    ns_log Notice "hours/new2: day=$i, screen_hours_hash=[array get screen_hours_hash] ===== $is_submited"
    ns_log Notice "hours/new2: day=$i, action_hash=[array get action_hash] ===== $is_submited"

    # Execute the actions
    foreach project_id [array names action_hash] {

	ns_log Notice "hours/new-2: project_id=$project_id"

	# For all actions: We modify the hours that the person has logged that week, 
	# so we need to reset/delete the TimesheetConfObject.
	ns_log Notice "hours/new-2: im_timesheet_conf_object_delete -project_id $project_id -user_id $user_id -day_julian $day_julian"

	if {$wf_installed_p} {
	    im_timesheet_conf_object_delete \
		-project_id $project_id \
		-user_id $user_id_from_search \
		-day_julian $day_julian
	}

	# Delete any cost elements related to the hour.
	# This time project_id refers to the specific (sub-) project.
	ns_log Notice "hours/new-2: im_timesheet_costs_delete -project_id $project_id -user_id $user_id -day_julian $day_julian"
	im_timesheet_costs_delete \
	    -project_id $project_id \
	    -user_id $user_id_from_search \
	    -day_julian $day_julian


	# Prepare hours_worked and hours_notes for insert & update actions
	set hours_worked 0
	if {[info exists screen_hours_hash($project_id)]} { set hours_worked $screen_hours_hash($project_id) }
	set note ""
	if {[info exists screen_notes_hash($project_id)]} { set note $screen_notes_hash($project_id) }
	set internal_note ""
	if {[info exists screen_internal_notes_hash($project_id)]} { set internal_note $screen_internal_notes_hash($project_id) }
	set material ""
	if {[info exists screen_materials_hash($project_id)]} { set material $screen_materials_hash($project_id) }

	if { [regexp {([0-9]+)(\,([0-9]+))?} $hours_worked] } {
	    regsub "," $hours_worked "." hours_worked
	    regsub "'" $hours_worked "." hours_worked
	} elseif { [regexp {([0-9]+)(\'([0-9]+))?} $hours_worked] } {
	    regsub "'" $hours_worked "." hours_worked
	    regsub "," $hours_worked "." hours_worked
	}

	# Calculate worked days based on worked hours
	set days_worked ""
	if {"" != $hours_worked} {
	    set days_worked [expr $hours_worked / $hours_per_day]
	}
	ns_log Notice "nikhil123333::is submitted  ==== $is_submited save= $save  submit= $submit"
	set action $action_hash($project_id)
	# ns_log Notice "hours/new-2: action=$action, project_id=$project_id"
	set is_submited1 [db_string as "select is_submited from im_hours where project_id=$project_id and user_id=$user_id_from_search and to_char(day,'J')::integer=$day_julian" -default 0]
	if {$save!=""} {
		# ad_return_complaint 1 "You have save"
		set is_submited 0
		if {$is_submited1=="t"} {
			set is_submited 1
		}
	} else {
		# ad_return_complaint 1 "You have submit"
		set is_submited 1
	}

	switch $action {

	    insert {
	    	# ad_return_complaint 1 "$is_submited"
	    	###################################################################
	    	#Inserts into db only if u enter else it skips
	    	###################################################################
		    if {$hours_worked!=0} {
				db_dml hours_insert "
				    insert into im_hours (
					user_id, project_id,
					day, hours, days,
					billing_rate, billing_currency,
					material_id,
					note,
					internal_note,
					is_submited
				     ) values (
					:user_id_from_search, :project_id, 
					to_date(:day_julian,'J'), :hours_worked, :days_worked,
					:billing_rate, :billing_currency, 
					:material,
					:note,
					:internal_note,
					:is_submited
				     )"
			    
				# Update the reported hours on the timesheet task
				db_dml update_timesheet_task ""
				# ToDo: Propagate change through hierarchy?
			}
	    }

	    delete {

		db_dml hours_delete "
			delete	from im_hours
			where	project_id = :project_id
				and user_id = :user_id_from_search
				and day = to_date(:day_julian, 'J')
	        "

		# Update the project's accummulated hours cache
		if { [db_resultrows] != 0 } {
		    db_dml update_timesheet_task {}
		}
	    }

	    update {

		db_dml hours_update "
		update im_hours
		set 
			hours = :hours_worked, 
			days = :days_worked,
			note = :note,
			internal_note = :internal_note,
			cost_id = null,
			material_id = :material,
			is_submited =:is_submited
		where
			project_id = :project_id
			and user_id = :user_id_from_search
			and day = to_date(:day_julian, 'J')
	        "
	    }

	}
    }
    # end of looping through days


    if {$limit_to_one_day_per_main_project_p} {
	# Timesheet Correction Function:
	# Limit the number of days logged per project and day to 1.0
	# (the customer would be surprised to see one guy charging 
	# more then one day...
	# This query determines the logged hours per main project.
	set ts_correction_sql "
	select
		project_id as correction_project_id,
		sum(hours) as correction_hours
	from
		(select	h.hours,
			parent.project_id,
			parent.project_name,
			h.day::date,
			h.user_id
		from	im_projects parent,
			im_projects children,
			im_hours h
		where	
			parent.parent_id is null and
			h.user_id = :user_id and
			h.day::date = to_date(:day_julian,'J') and
			children.tree_sortkey between 
				parent.tree_sortkey and 
				tree_right(parent.tree_sortkey) and
			h.project_id = children.project_id
		) h
	group by project_id
	having sum(hours) > :hours_per_day
        "

	db_foreach ts_correction $ts_correction_sql {

	    # We have found a project with with more then $hours_per_day
	    # hours logged on it by a single user and a single days.
	    # We now need to cut all logged _days_ (not hours...) by
	    # the factor sum(hour)/$hours_per_day so that at the end we
	    # will get exactly one day logged to the main project.
	    set correction_factor [expr $hours_per_day/$correction_hours]

	    db_dml appy_correction_factor "
		update im_hours set days = days * :correction_factor,
							is_submited =$is_submited
		where
			day = to_date(:day_julian,'J') and
			user_id = :user_id and
			project_id in (
				select	children.project_id
				from	im_projects parent,
					im_projects children
				where	parent.parent_id = :correction_project_id and
					children.tree_sortkey between 
						parent.tree_sortkey and 
						tree_right(parent.tree_sortkey)
			)
	    "

	}
    }
incr i
}


# Update the affected project's cost_hours_cache and cost_days_cache fields,
# so that the numbers will appear correctly in the TaskListPage
foreach project_id $all_project_ids {
    im_timesheet_update_timesheet_cache -project_id $project_id
}

# Create cost items for every logged hours?
# This may take up to a second per user, so we may want to avoid this
# in very busy Swisss systems where everybody logs hours between 16:00 and 16:30...
if {$sync_cost_item_p} {
    im_timesheet2_sync_timesheet_costs -project_id $project_id
}



# ----------------------------------------------------------
# Where to go from here?
# ----------------------------------------------------------

if { ![empty_string_p $return_url] } {
    ns_log Notice "ad_returnredirect $return_url"
    ad_returnredirect $return_url
} else {
    ns_log Notice "ad_returnredirect index?[export_url_vars julian_date]"
    ad_returnredirect index?[export_url_vars julian_date]
}
