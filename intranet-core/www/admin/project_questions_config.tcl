# /packages/intranet-core/www/admin/project_questions_config.tcl
# Copyright (C) 1998 - 2012 various parties
# The code is based on ArsDigita ACS 3.4 
# This program is free software. You can redistribute it 
# and/or modify it under the terms of the GNU General 
# Public License as published by the Free Software Foundation; 
# either version 2 of the License, or (at your option) 
# any later version. This program is distributed in the 
# hope that it will be useful,but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or 
# FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details. 
ad_page_contract {
  craete and update questions config for tasks.
  @author NIKHIL(nikhil.arpally@venkatmangudi.com)
} {
  {project_type 0}
  {question ""}
  {save ""}
  { taskset:multiple "" }
   {ques:array "" }
   {action ""}

}
#ad_return_complaint 1 "$taskset"
#-----------------------------------------------------------------------------------------------------------
#Defaults and security
#-----------------------------------------------------------------------------------------------------------
set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}
set page_title "Project Question Configuration"
#Updating existing questions
if {$taskset != ""} {
	foreach  question_no $taskset {
#		ad_return_complaint 1 "$question_no"
		if {$action== "save"} {
			set quest "$ques($question_no)"
			db_dml update_ques "
				update im_vmc_project_questions
					set question=:quest
				where
					question_no=$question_no
			"
		}
		if {$action== "delete"} {
			db_dml delete_ques "delete from im_vmc_project_questions where question_no=$question_no"
		}
	}
}
#-----------------------------------------------------------------------------------------------------------
#Form Creation
#-----------------------------------------------------------------------------------------------------------
set show_html "<form name=project-tasks id=project-tasks method=post>
<script type=text/javascript>
      function isNumericKey(e)
      {
          if (window.event) { var charCode = window.event.keyCode; }
          else if (e) { var charCode = e.which; }
          else { return true; }
          if (charCode > 31 && (charCode < 48 || charCode > 57)) { return false; }
          return true;
      }
      function isNumericKey1(e)
      {

          if (window.event) { var charCode = window.event.keyCode; }
          else if (e) { var charCode = e.which; }
          else { return true; }
          if (charCode > 52 && (charCode < 48 || charCode > 57)) { return false; }
          if (charCode == 49 || charCode == 50 || charCode ==51 ||charCode ==8 || charCode ==0) {
          return true;
        }
        return false;
      }
</script>
"

#---------------------------------------------------------------------------------------------------------
#Column Background colrs
#----------------------------------------------------------------------------------------------------------
set bgcolor(0) " class=rowodd"
set bgcolor(1) " class=roweven"
set bgcolor(2) " class=rowtitle"

set count 0
#---------------------------------------------------------------------------------------------------------
#Column Headrs
#---------------------------------------------------------------------------------------------------------
#append show_html "<table width=850 border=1><tr $bgcolor(2)>
#                      <td $bgcolor(2) width=20%>Project Type</td>
#                      <td $bgcolor(2)   width=80%>Set Of Questions</td>
#                    </tr>
#                "

#---------------------------------------------------------------------------------------------------------
#Getting Types of Documents
#---------------------------------------------------------------------------------------------------------
set proj_type_ids  " select im_category_from_id(child_id) as task_name, 
                            child_id as task_name_id, im_category_from_id(parent_id) as parent
                        from 
                            im_category_hierarchy 
                        where 
                            parent_id in(select category_id 
                                        from 
                                                im_categories 
                                        where 
                                                category in (select category 
                                                            from 
                                                                im_categories 
                                                            where 
                                                                category_type='Intranet Project Type') 
and category_type='Intranet Project Task Types') 
                        order by parent_id,child_id" 
                 
set doc_types [list "" "---Please Select---"]

#---------------------------------------------------------------------------------------------------------
# Adding all doument list into dropdown list
#---------------------------------------------------------------------------------------------------------
db_foreach type_id $proj_type_ids {
 lappend doc_types "$task_name_id" "$task_name---$parent"
#ad_return_complaint 1 "$doc_id      $document_name"
}

#----------------------------------------------------------------------------------------------------------
#Getting all Project Types which has Tasks
#---------------------------------------------------------------------------------------------------------
set project_types "
              select 
                  distinct 
                  c.category_id as project_type_id, 
                  c.category as project_type
              from 
                  im_categories c, 
                  im_category_hierarchy h 
              where 
                  c.category_type='Intranet Project Type' 
                  and h.parent_id=c.category_id"
#******************************************************************************************
#Display
#******************************************************************************************
append show_html "<table width=850 border=0><tr $bgcolor(2)><tr $bgcolor(2)>
                       <td><b>Project Type</b></td> <td><b>:</b></td><td>[im_select project_type $doc_types $project_type]</td></tr>
			<tr ><td><b>Question</b></td> <td><b>:</b></td><td ><input type=text size=80 name=question ></td></tr>"
	
append show_html "</table><input type=Submit value='Add Question' name=save class=\"form-butto40\"></form>"

#******************************************************************************************
#Code for adding new question
#*******************************************************************************************
if {$save=="Add Question"} {
if {$project_type==""} {
	ad_return_complaint 1 "Please enter Project type"
 	ad_script_abort
}
if {$question==""} {
	ad_return_complaint 1 "Please Enter  Value For Question"
	ad_script_abort
}
#ad_return_complaint 1 "$project_type"
set question_no [db_string as "select count(*) from im_vmc_project_questions " -default 0]
set question_no [expr $question_no+1]
db_dml add_question "
		insert into im_vmc_project_questions (
			project_type_id,
			question,
			question_no
			) values (
			:project_type,
			:question,
			$question_no
			)
" 
}

#******************************************************************************************
#Display
#*******************************************************************************************
set show_html1 "<form name=project-questions id=project-questions method=post>"
append show_html1 "<table width=850 border=1><tr $bgcolor(2)>
                      <td $bgcolor(2) width=20%>Project Type</td>
                      <td $bgcolor(2)   width=80%>Set Of Questions</td>
			<td $bgcolor(2)></td>
                    </tr>
                "
set selection_sql "
		select 
			im_category_from_id(project_type_id) as project_type,
			question,
			question_no,
			project_type_id
		from
			im_vmc_project_questions
		order by
			project_type_id
"
set count 0
set prev_type ""
db_foreach as $selection_sql {
	if {$prev_type!=$project_type} {
		set project_type1 "$project_type"
		set prev_type "$project_type"
	} else {
		set project_type1 "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
		set prev_type "$project_type"
	}
	append show_html1 "
		<tr $bgcolor([expr $count%2])><td $bgcolor([expr $count%2]) width=20%><b>$project_type1</b></td>
                      <td $bgcolor([expr $count%2])   width=80%><input type=text size=80 name=ques.$question_no value ='$question'></td>
			<td $bgcolor([expr $count%2])><input type=checkbox name=\"taskset\" value=$question_no></td>
                    </tr>"
	incr count
}
append show_html1 "<td bgcolor='#E8EDFF' colspan=3 align=right>
                <select name=action class=\"form-butto40\">
                    <option value='save'>Update </option>
                    <option value='delete'>Delete</option> 
                </select>
                <input type=submit value=Apply name=save1></form></table>"
