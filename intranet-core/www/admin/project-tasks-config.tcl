# /packages/intranet-core/www/admin/project-tasks-config.tcl
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
  craete and update duration,document config for tasks.
  @author vijetha.m@venkatmangudi.com
} {
   {duration:array ""}
   {num_docs:array ""}
   {doc_id1:array ""}
   {doc_id2:array ""}
   {doc_id3:array ""}
   {man_doc1:array ""}
   {man_doc2:array ""}
   {man_doc3:array ""}
   {num_docs:array ""}
   {save ""}

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
set page_title "Project Tasks Configuration"

#-----------------------------------------------------------------------------------------------------------
#Form Creation
#-----------------------------------------------------------------------------------------------------------

set show_html "<form name=project-tasks id=project-tasks method=POST>
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

#----------------------------------------------------------------------------------------------------------
# if Form  is submitted Delete all values and re-insert again 
#----------------------------------------------------------------------------------------------------------
if {$save=="Save"} {
      db_dml delete_content "delete from im_vmc_config_tasks"

    }

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
append show_html "<table width=100 border=1><tr $bgcolor(2)>
                      <td $bgcolor(2)>Project Type</td>
                      <td $bgcolor(2)>Task Type</td>
                      <td $bgcolor(2)>Duration</td>
                      <td $bgcolor(2)>No.of Docs </td>
                      <td $bgcolor(2)>Document Type</td>
                      <td $bgcolor(2)></td>
                      <td $bgcolor(2)>Document Type</td>
                      <td $bgcolor(2)></td>
                      <td $bgcolor(2)>Document Type</td>
                      <td $bgcolor(2)></td>
                    </tr>
                "

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
                  c.category_type='Intranet Project Task Types' 
                  and h.parent_id=c.category_id"


#---------------------------------------------------------------------------------------------------------
#Getting Types of Documents
#---------------------------------------------------------------------------------------------------------
set doc_ids [db_list_of_lists tt "select category_id from im_categories where category_type = 'Intranet Document Type' "]
set doc_types [list "" "---Please Select---"]

#---------------------------------------------------------------------------------------------------------
# Adding all doument list into dropdown list
#---------------------------------------------------------------------------------------------------------
foreach doc_id $doc_ids {
  set document_name [db_string tsk_ty "select category from im_categories where category_id = :doc_id" -default ""]
  lappend doc_types "$doc_id" "$document_name"
}

set current_date [db_string x "select current_date from dual"]
#---------------------------------------------------------------------------------------------------------
#Running loop for Project Types
#---------------------------------------------------------------------------------------------------------
db_foreach project_type $project_types {

  append show_html "<tr $bgcolor(2)>
                        <td $bgcolor(2)>$project_type</td>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                        <td $bgcolor(2)>
                    </tr>
                    "
#-------------------------------------------------------------------------------------------------------------
#For each project id getting list of tasks
#-------------------------------------------------------------------------------------------------------------
  set task_list "
                select 
                  distinct 
                    child_id as task_name_id, 
                    im_category_from_id(child_id) as task_type 
                from 
                    im_category_hierarchy 
                where 
                    parent_id=$project_type_id
                order by child_id
                "
  #---------------------------------------------------------------------------------------------------------
  #Running Loop for each task
  #---------------------------------------------------------------------------------------------------------
  db_foreach task $task_list {

    #---------------------------------------------------------
    #If form has submitted enter values in db 
    #--------------------------------------------------------
    if {$save=="Save"} {

            #Validations for Duration and Number of documents
            if {$duration($count)==""} {
              set duration($count) 0
            }

            if {$num_docs($count)==""} {
              set num_docs($count) 0
            }

            #validation for Document type1 and mandatory
            set mand_flag1 "t"
            if {![info exists man_doc1($count)]} {
              set mand_flag1 "f"
            }

            
            if {![info exists doc_id1($count)] || $doc_id1($count) ==""} {
              set doc_id1($count) 0
            }



            #validation for Document type and mandatory
           set mand_flag2 "t"
           if {![info exists man_doc2($count)]} {
              set mand_flag2 "f"
            }

            if {![info exists doc_id2($count)] || $doc_id2($count) ==""} {
              set doc_id2($count) 0
            }



            #validation for Document type3 and mandatory
          set mand_flag3 "t"
           if {![info exists man_doc3($count)]} {
              set mand_flag3 "f"
            }

           if {![info exists doc_id3($count)] || $doc_id3($count) ==""} {
              set doc_id3($count) 0
            }

          ns_log Notice "vijetha 1======== $doc_id1($count) === $doc_id2($count) === $doc_id3($count)"
          #-------------------------------------------------------------------------------------
          #inserting values in db
          #--------------------------------------------------------------------------------------
           db_dml insert_values "
            insert into im_vmc_config_tasks (
              project_type_id,
              task_name_id,
              doc_type_id1,
              doc_mandatory1,
              doc_type_id2,
              doc_mandatory2,
              doc_type_id3,
              doc_mandatory3, 
              duration, 
              updated_on,
              num_docs
              ) values (
              $project_type_id,
              $task_name_id,
              $doc_id1($count),
              '$mand_flag1',
              $doc_id2($count),
              '$mand_flag2',
              $doc_id3($count),
              '$mand_flag3',
              $duration($count),
              :current_date,
              $num_docs($count)
              )

           "

    }


    set get_config_values "select 
                              num_docs as num_docs1, 
                              doc_type_id1,doc_mandatory1,
                              doc_type_id2,doc_mandatory2,
                              doc_type_id3,doc_mandatory3,
                              duration as duration1 
                          from 
                              im_vmc_config_tasks 
                          where 
                              project_type_id=$project_type_id 
                              and task_name_id=$task_name_id
                          "
    set duration1 0
    set doc_type_id1 ""
    set doc_type_id2 ""
    set doc_type_id3 ""
    set doc_mandatory3 ""
    set doc_mandatory2 ""
    set doc_mandatory1 ""
    set num_docs1 0

    db_foreach sd $get_config_values {
        set duration1 $duration1
        set doc_type_id1 $doc_type_id1
        set doc_type_id2 $doc_type_id2
        set doc_type_id3 $doc_type_id3
        set num_docs1 $num_docs1
        if {$doc_mandatory3=="t"} {
          set doc_mandatory3 "checked=checked"
        }
        if {$doc_mandatory2=="t"} {
          set doc_mandatory2 "checked=checked"
        }
        if {$doc_mandatory1=="t"} {
          set doc_mandatory1 "checked=checked"
        }


    }

 append show_html "<tr $bgcolor([expr $count%2])>
                          <td $bgcolor([expr $count%2])>
                          <td $bgcolor([expr $count%2])>$task_type</td>
                          <td $bgcolor([expr $count%2])>
                              <input type=text name=\"duration.$count\" id=\"duration.$count\" value=$duration1 size=3 maxlength=3 onkeypress= \"return isNumericKey(event)\"></td>
                          <td $bgcolor([expr $count%2])>
                              <input type=text name=\"num_docs.$count\" id=\"num_docs.$count\" size=1 maxlength=1 onkeypress=\"return isNumericKey1(event)\" value=$num_docs1></td>
                          <td $bgcolor([expr $count%2]) >
                              [im_select doc_id1.$count $doc_types $doc_type_id1] <td $bgcolor([expr $count%2]) ><input type=checkbox name=\"man_doc1.$count\" id=\"man_doc1.$count\" $doc_mandatory1></td>
                          <td $bgcolor([expr $count%2]) >
                              [im_select doc_id2.$count $doc_types $doc_type_id2] <td $bgcolor([expr $count%2]) ><input type=checkbox name=\"man_doc2.$count\" id=\"man_doc2.$count\" $doc_mandatory2></td>
                          <td $bgcolor([expr $count%2])>
                              [im_select doc_id3.$count $doc_types $doc_type_id3] <td $bgcolor([expr $count%2]) ><input type=checkbox name=\"man_doc3.$count\" id=\"man_doc3.$count\" $doc_mandatory3></td>
                      </tr>"
  incr count
  }

}

append show_html "</table><input type=Submit value=Save name=save></form>"




