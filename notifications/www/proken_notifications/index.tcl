# /packages/notifications/www/proken_notifications/index.tcl
# Copyright (C) 1998 - 2012 various parties
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



# ad_page_contract {
# 	@param Page to display Tasks in dashboard
# 	@author Vijetha M (vijetha.m@venkatmangudi.com)
# } {
# 	{out_table1 ""}
# 	{out_table2 ""}
# 	{out_table3 ""}
# 	{out_table4 ""}
# 	{out_table7 ""}
# 	{out_table8 ""}
# 	{out_table9 ""}
# 	{out_table10 ""}
# 	{comp ""}
# }

# ---------------------------------------------------------------
# Project Menu
# ---------------------------------------------------------------

set out_table1 ""
set out_table2 ""
set out_table3 ""
set out_table4 ""
set out_table7 ""
set out_table8 ""
set out_table9 ""
set out_table10 ""

if {![info exists comp] || "" == $comp} { set comp "my_tasks" }

#----------------------------------------------------------------------------------------------------------------
# Default & security
#---------------------------------------------------------------------------------------------------------------
	set user_id [ad_maybe_redirect_for_registration]
	set page_title "The Work"
	set bg_color(0) "class=rowodd"
	set bg_color(1) "class=roweven"
	set bg_color(2) "class=rowtitle"

set current_date [db_string dt "select to_char(current_date,'yyyy-mm-dd') from dual"]
set closed_stati_select "select * from im_sub_categories([im_project_status_closed])"
set closed_stati [db_list closed_stati $closed_stati_select]
set closed_stati_list [join $closed_stati ","]
#----------------------------------------------------------------------------------------------------------------
# My Tasks 
#----------------------------------------------------------------------------------------------------------------
if {$comp=="my_tasks"} {


	#-----------------------------------------------------------------------------------------------------------
	# List of tasks Assigned to Me
	#-----------------------------------------------------------------------------------------------------------
		set my_tasks "SELECT object_id_one as task_id from acs_rels,users,im_biz_object_members where object_id_two=user_id and acs_rels.rel_id=im_biz_object_members.rel_id and object_id_two=$user_id"
		#-------------------------------------------------------------------------------------------------------------
		# Due Today
		#-------------------------------------------------------------------------------------------------------------


			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#----------------------------------------------------------------------------------------------------------
			set out_table7_qry "
					SELECT 
						p.project_id as task_id,
						substring(p.project_name,1,25) as task_name, 
						substring(im_project_name_from_id(parent_id),1,25) as project_name,
						parent_id as project_id,
						to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
						to_char(p.end_date,'dd-Mon-yyyy') as end_date
					from 
						im_projects p, 
						im_timesheet_tasks t
					where 
						p.project_id=t.task_id
						 and p.project_id in ($my_tasks)
						and to_char(p.end_date,'yyyy-mm-dd')='$current_date'
						and p.project_status_id not in ($closed_stati_list)
					order by end_date desc
					LIMIT 5

				"

			#--------------------------------------------------------------------------------------------------------
			# Html to display My tasks Due Today
			#-------------------------------------------------------------------------------------------------------
			set out_table7 "
			<table cellpadding=0 width=100%>
				<tr $bg_color(2)>
					<td $bg_color(2)>Task Name</td>
					<td $bg_color(2)>Project name</td>
					<td $bg_color(2)>Start Date</td>
					<td $bg_color(2)>End Date</td>
				</tr>
			"
			set ctr 0
			db_foreach x $out_table7_qry {
				append out_table7 "
						<tr $bg_color([expr $ctr % 2])>
							<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
							<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
							<td $bg_color([expr $ctr % 2])>$start_date</td>
							<td $bg_color([expr $ctr % 2])>$end_date</td>
						</tr>"

				incr ctr
			}

			append out_table7 "</table>"

		#-------------------------------------------------------------------------------------------------------------
		# Over Due
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Over Due (Top 5)
			#----------------------------------------------------------------------------------------------------------
				set out_table7_qry "
						SELECT 
							p.project_id as task_id,
							substring(p.project_name,1,25) as task_name, 
							substring(im_project_name_from_id(parent_id),1,25) as project_name,
							parent_id as project_id,
							to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
							to_char(p.end_date,'dd-Mon-yyyy') as end_date 
						from 
							im_projects p, 
							im_timesheet_tasks t
						where 
							p.project_id=t.task_id
							and p.project_id in ($my_tasks)
							and p.end_date < to_timestamp(:current_date, 'YYYY-MM-DD')
							-- and to_char(p.end_date,'yyyy-mm-dd')<'$current_date'::date
							and p.project_status_id not in ($closed_stati_list)
						order by end_date desc
						LIMIT 5

					"

			#--------------------------------------------------------------------------------------------------------
			# Html to display List of My tasks Over Due (Top 5)
			#-------------------------------------------------------------------------------------------------------
				set out_table8 "
				<table cellpadding=0 width=100%>
					<tr $bg_color(2)>
						<td $bg_color(2)>Task Name</td>
						<td $bg_color(2)>Project name</td>
						<td $bg_color(2)>Start Date</td>
						<td $bg_color(2)>End Date</td>
					</tr>
				"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table8 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}

				append out_table8 "</table>"

		#-------------------------------------------------------------------------------------------------------------
		# ForthComing
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My ForthComing Tasks (Top 5)
			#----------------------------------------------------------------------------------------------------------
				set out_table7_qry "
						SELECT 
							p.project_id as task_id,
							substring(p.project_name,1,25) as task_name, 
							substring(im_project_name_from_id(parent_id),1,25) as project_name,
							parent_id as project_id,
							to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
							to_char(p.end_date,'dd-Mon-yyyy') as end_date 
						from 
							im_projects p, 
							im_timesheet_tasks t
						where 
							p.project_id=t.task_id
							and p.project_id in ($my_tasks)
							and p.start_date > to_timestamp(:current_date, 'YYYY-MM-DD')
							-- and to_char(p.start_date,'yyyy-mm-dd')>'$current_date'::date
							and p.project_status_id not in ($closed_stati_list)
						order by end_date desc
						LIMIT 5

					"

			#--------------------------------------------------------------------------------------------------------
			# Html to display  List of My ForthComing Tasks (Top 5)
			#-------------------------------------------------------------------------------------------------------
				set out_table9 "
				<table cellpadding=0 width=100%>
					<tr $bg_color(2)>
						<td $bg_color(2)>Task Name</td>
						<td $bg_color(2)>Project name</td>
						<td $bg_color(2)>Start Date</td>
						<td $bg_color(2)>End Date</td>
					</tr>
				"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table9 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}

				append out_table9 "</table>"

		#-------------------------------------------------------------------------------------------------------------
		# All Tasks
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#----------------------------------------------------------------------------------------------------------
				set out_table7_qry "
						SELECT 
							p.project_id as task_id,
							substring(p.project_name,1,25) as task_name, 
							substring(im_project_name_from_id(parent_id),1,25) as project_name,
							parent_id as project_id,
							to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
							to_char(p.end_date,'dd-Mon-yyyy') as end_date 
						from 
							im_projects p, 
							im_timesheet_tasks t
						where 
							p.project_id=t.task_id
							and p.project_id in ($my_tasks)
							and p.project_status_id not in ($closed_stati_list)
						order by end_date desc
						LIMIT 5
						

					"

			#--------------------------------------------------------------------------------------------------------
			# Html to display All My Tasks (Top5)
			#-------------------------------------------------------------------------------------------------------
				set out_table10 "
					<table cellpadding=0 width=100%>
						<tr $bg_color(2)>
							<td $bg_color(2)>Task Name</td>
							<td $bg_color(2)>Project name</td><td $bg_color(2)>Start Date</td>
							<td $bg_color(2)>End Date</td>
						</tr>
					"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table10 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}

				append out_table10 "</table>"

}


#---------------------------- End of My Tasks --------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
# Tasks Assigned By Me
#----------------------------------------------------------------------------------------------------------------

if {$comp=="tasks_by_me"} {
	#-----------------------------------------------------------------------------------------------------------
	# List of tasks Assigned to Me
	#-----------------------------------------------------------------------------------------------------------
		
		# set my_tasks "SELECT object_id_one as task_id from acs_rels,users,im_biz_object_members where object_id_two=user_id and acs_rels.rel_id=im_biz_object_members.rel_id and object_id_two=$user_id"
		set assigned_be_me "select distinct task_id from im_timesheet_tasks where assigned_by=$user_id"
		#-------------------------------------------------------------------------------------------------------------
		# Due Today
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#---------------------------------------------------------------------------------------------------------

				set out_table7_qry "
					SELECT 
						p.project_id as task_id,
						substring(p.project_name,1,25) as task_name, 
						substring(im_project_name_from_id(parent_id),1,25) as project_name,
						parent_id as project_id,
						to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
						to_char(p.end_date,'dd-Mon-yyyy') as end_date 
					from 
						im_projects p, 
						im_timesheet_tasks t
					where 
						p.project_id=t.task_id
						and p.project_id in ($assigned_be_me)
					    --and to_char(p.end_date,'yyyy-mm-dd')='$current_date'
					    and p.end_date = to_timestamp(:current_date, 'YYYY-MM-DD')
					    and p.project_status_id not in ($closed_stati_list)
					order by end_date desc
					LIMIT 5

					"

			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#----------------------------------------------------------------------------------------------------------
				set out_table1 "
				<table cellpadding=0 width=100%>
					<tr $bg_color(2)>
						<td $bg_color(2)>Task Name</td>
						<td $bg_color(2)>Project name</td>
						<td $bg_color(2)>Start Date</td>
						<td $bg_color(2)>End Date</td>
					</tr>
				"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table1 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}

				append out_table1 "</table>"


		#-------------------------------------------------------------------------------------------------------------
		# Over Due 
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#---------------------------------------------------------------------------------------------------------

				set out_table7_qry "
					SELECT 
						p.project_id as task_id,
						substring(p.project_name,1,25) as task_name, 
						substring(im_project_name_from_id(parent_id),1,25) as project_name,
						parent_id as project_id,
						to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
						to_char(p.end_date,'dd-Mon-yyyy') as end_date 
					from 
						im_projects p, 
						im_timesheet_tasks t
					where 
						p.project_id=t.task_id
						and p.project_id in ($assigned_be_me)
						and p.end_date < to_timestamp(:current_date, 'YYYY-MM-DD')
						--and to_char(p.end_date,'yyyy-mm-dd')<'$current_date'::date
						and p.project_status_id not in ($closed_stati_list)
					order by end_date desc
					LIMIT 5

					"

			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#----------------------------------------------------------------------------------------------------------
				set out_table2 "
				<table cellpadding=0 width=100%>
					<tr $bg_color(2)>
						<td $bg_color(2)>Task Name</td>
						<td $bg_color(2)>Project name</td>
						<td $bg_color(2)>Start Date</td>
						<td $bg_color(2)>End Date</td>
					</tr>
				"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table2 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}
				append out_table2 "</table>"

		#-------------------------------------------------------------------------------------------------------------
		# ForthComing
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#---------------------------------------------------------------------------------------------------------

				set out_table7_qry "
					SELECT 
						p.project_id as task_id,
						substring(p.project_name,1,25) as task_name, 
						substring(im_project_name_from_id(parent_id),1,25) as project_name,
						parent_id as project_id,
						to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
						to_char(p.end_date,'dd-Mon-yyyy') as end_date 
					from 
						im_projects p, 
						im_timesheet_tasks t
					where 
						p.project_id=t.task_id
						and p.project_id in ($assigned_be_me)
						and p.start_date > to_timestamp(:current_date, 'YYYY-MM-DD')
						and p.project_status_id not in ($closed_stati_list)
					order by end_date desc
					LIMIT 5

					"

			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#----------------------------------------------------------------------------------------------------------	
				set out_table3 "
				<table cellpadding=0 width=100%>
					<tr $bg_color(2)>
						<td $bg_color(2)>Task Name</td>
						<td $bg_color(2)>Project name</td>
						<td $bg_color(2)>Start Date</td>
						<td $bg_color(2)>End Date</td>
					</tr>
				"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table3 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}
				append out_table3 "</table>"

		#-------------------------------------------------------------------------------------------------------------
		# All Tasks
		#-------------------------------------------------------------------------------------------------------------
			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#---------------------------------------------------------------------------------------------------------

				set out_table7_qry "
					SELECT 
						p.project_id as task_id,
						substring(p.project_name,1,25) as task_name, 
						substring(im_project_name_from_id(parent_id),1,25) as project_name,
						parent_id as project_id,
						to_char(p.start_date,'dd-Mon-yyyy') as start_date, 
						to_char(p.end_date,'dd-Mon-yyyy') as end_date 
					from 
						im_projects p, 
						im_timesheet_tasks t
					where 
						p.project_id=t.task_id
						and p.project_id in ($assigned_be_me)
						and p.project_status_id not in ($closed_stati_list)
					order by end_date desc
					LIMIT 5

					"

			#----------------------------------------------------------------------------------------------------------
			# List of My tasks Due Today (Top 5)
			#----------------------------------------------------------------------------------------------------------
				set out_table4 "
				<table><tr><td>Task Name</td><td>Create By</td></tr>
				"
				set out_table4 "
				<table cellpadding=0 width=100%>
					<tr $bg_color(2)>
						<td $bg_color(2)>Task Name</td>
						<td $bg_color(2)>Project name</td>
						<td $bg_color(2)>Start Date</td>
						<td $bg_color(2)>End Date</td>
					</tr>
				"
				set ctr 0
				db_foreach x $out_table7_qry {
					append out_table4 "
							<tr $bg_color([expr $ctr % 2])>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$task_id>$task_name</a></td>
								<td $bg_color([expr $ctr % 2])><a href=/intranet/projects/view?project_id=$project_id>$project_name</a></td>
								<td $bg_color([expr $ctr % 2])>$start_date</td>
								<td $bg_color([expr $ctr % 2])>$end_date</td>
							</tr>"

					incr ctr
				}
				append out_table4 "</table>"

}


# ------------------------------------ End of Tasks Assigned By Me -----------------------------------------------