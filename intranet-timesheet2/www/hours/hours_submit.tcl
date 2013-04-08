# /packages/intranet-timesheet2-workflow/www/new-workflow.tcl
#
# Copyright (C) 2003-2008 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Creates a new workflow for the associated hours
    @author frank.bergmann@project-open.com
} {
    user_id
    { return_url "/intranet-timesheet2/hours/index" }
    { start_date_julian "" }
    { end_date_julian "" }
    
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------
set wf_user_id $user_id
set user_id [ad_maybe_redirect_for_registration]
set page_title "[lang::message::lookup "" intranet-timesheet2-workflow.Create_New_Timesheet_Workflow "Submit Log Hours"]"
set context_bar [im_context_bar $page_title]
set page_focus "im_header_form.keywords"
set date_format_pretty "YYYY-MM-DD"
# if { "" == $workflow_key } {
#     set workflow_key [parameter::get -package_id [apm_package_id_from_key intranet-timesheet2-workflow] -parameter "DefaultWorkflowKey" -default "timesheet_approval_wf"]
# }
set start_date [db_string start_date "select to_date(:start_date_julian, 'J')"]
set end_date [db_string start_date "select to_date(:end_date_julian, 'J')"]
set hours_sql "
	select 
		to_char(day, 'J') as julian_date, 
		sum(hours) as hours
	from
		im_hours
	where
		user_id = :wf_user_id
		and day between to_date(:start_date_julian, 'J') and to_date(:end_date_julian, 'J')
		and is_submited='f' 
		
	group by 
		to_char(day, 'J')
"
db_foreach hour $hours_sql {
	if {$hours<8 || $hours>24} {
		set this_date [db_string start_date "select to_char(to_date(:julian_date, 'J'),'DD') from dual"]
		ad_return_complaint 1 "<b>You have to log hours between 8 to 24, for the day $this_date. Please go back and correct the entry. </b>"
	}


}

# ad_return_complaint 1 "$wf_user_id   $start_date  $end_date"
db_dml update "
	update
		im_hours 
	set 
		is_submited='t'
	where 
		user_id = :wf_user_id and
		day >= :start_date and
		day <= :end_date
"
ad_returnredirect $return_url
