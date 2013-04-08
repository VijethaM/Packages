# /packages/intranet-core/www/admin/project_questions.tcl
# Copyright (C) 1998-2004 various parties
# The code is based on ArsDigita ACS 3.4
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
    Lets users add/modify information about our brands.
    Contact details are not stored with the company itself,
    but with a "main_office" that is a required property
    (not null).

    @param company_id if specified, we edit the company with this company_id
    @param return_url Return URL
    @author nikhil.arpally@venkatmangudi.com
} {
    {project_id 0}
    {save1 ""}
    { taskset:multiple "" }
    {ans:array "" }
   
}
#-----------------------------------------------------------------------------------------------------------
#Defaults and security
#-----------------------------------------------------------------------------------------------------------
set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}
set page_body ""
#---------------------------------------------------------------------------------------------------------
#Column Background colrs
#----------------------------------------------------------------------------------------------------------
set bgcolor(0) "  class=roweven"
set bgcolor(1) " class=rowodd"
set bgcolor(2) " class=rowtitle"

set count 1
#---------------------------------------------------------------------------------------------------------
#Geting Project Type And Related Questions
#---------------------------------------------------------------------------------------------------------
set project_type_id [db_string ad "select project_type_id from im_projects where project_id=$project_id" -default 0]
#ad_return_complaint 1 "$project_type_id $project_id"
set questions_sql "
	select 
		question,
		question_no
	from
		im_vmc_project_questions
	where
		project_type_id=$project_type_id
"
if {$save1=="Apply"} {
#ad_return_complaint 1 "Hi ur in save block"
#ad_return_complaint 1 "$taskset"
foreach question_no $taskset {
	set is_answerd [db_string as "select count(*) from im_vmc_project_answers where project_id=$project_id and question_no=$question_no" -default 0]
	set answer_by $user_id
	 set answer "$ans($question_no)"
	if {$is_answerd<=0} {
		db_dml add_answer "
			insert into im_vmc_project_answers (
				project_id,
				question_no,
				answerd_by,
				answer
				) values (
				$project_id,
				$question_no,
				$answer_by,
				:answer
				)
		" 

	} else {
		db_dml update_ans "
			update im_vmc_project_answers set
				answer=:answer,
				answerd_by =:answer_by
			where
				project_id=$project_id
				and question_no =$question_no

		"
	}
}
#ad_returnredirect "/intarnet/projects/view?project_id=$project_id"
}
append page_body "<form name=project-ans id=project-ans method=post><table border=0>
			<tr $bgcolor(2)>
			<td $bgcolor(2)>S.No</td></td>
                      <td $bgcolor(2) > Questions</td>
                      <td $bgcolor(2)   align=center>Answers</td>
			
                    </tr>"
db_foreach question $questions_sql {
set answer [db_string as "select answer from im_vmc_project_answers where project_id=$project_id and question_no=$question_no" -default ""]
#ad_return_complaint 1 "$answer $project_id $question_no" 
append page_body "
		<tr>
		<td $bgcolor([expr $count%2]) >$count</td>
		<td $bgcolor([expr $count%2]) >$question</td>
		<td $bgcolor([expr $count%2])><textarea size=40 cols=40 rows=3 name=ans.$question_no style=\"width: 348px; height: 51px;\"  />$answer</textarea></td>
		<input type=hidden name=question_no value=$question_no />
		<input type=hidden name=\"taskset\" value=$question_no></td>
		</tr>

"
incr count
}
append page_body "<td colspan=3 align=right >
	<input type=hidden name=project_id value=$project_id />
	 <input type=submit value=Apply name=save1></tr></table></form>
	"



