ad_page_contract {
    The display for the project base data 
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-10-07

} 

# ---------------------------------------------------------------------
# Get Everything about the project
# ---------------------------------------------------------------------


set extra_selects [list "0 as zero"]
db_foreach column_list_sql {}  {
    lappend extra_selects "${deref_plpgsql_function}($attribute_name) as ${attribute_name}_deref"
}
    
set extra_select [join $extra_selects ",\n\t"]

    
if { ![db_0or1row project_info_query {}] } {
    ad_return_complaint 1 "[_ intranet-core.lt_Cant_find_the_project]"
    return
}

set user_id [ad_conn user_id] 
set project_type [im_category_from_id $project_type_id]
set project_status [im_category_from_id $project_status_id]
set yet_to_start "Yet To Start"
# Get the parent project's name
if {"" == $parent_id} { set parent_id 0 }
set parent_name [util_memoize [list db_string parent_name "select project_name from im_projects where project_id = $parent_id" -default ""]]


# ---------------------------------------------------------------------
# Redirect to timesheet if this is timesheet
# ---------------------------------------------------------------------

# Redirect if this is a timesheet task (subtype of project)
if {$project_type_id == [im_project_type_task]} {
    ad_returnredirect [export_vars -base "/intranet-timesheet2-tasks/new" {{task_id $project_id}}]
    
}


# ---------------------------------------------------------------------
# Check permissions
# ---------------------------------------------------------------------

# get the current users permissions for this project                                                                                                         
im_project_permissions $user_id $project_id view read write admin

set current_user_id $user_id
set enable_project_path_p [parameter::get -parameter EnableProjectPathP -package_id [im_package_core_id] -default 0] 

set view_finance_p [im_permission $current_user_id view_finance]
set view_budget_p [im_permission $current_user_id view_budget]
set view_budget_hours_p [im_permission $current_user_id view_budget_hours]


# ---------------------------------------------------------------------
# Project Base Data
# ---------------------------------------------------------------------
    

set im_company_link_tr [im_company_link_tr $user_id $company_id $company_name "[_ intranet-core.Client]"]
set im_render_user_id [im_render_user_id $project_lead_id $project_lead $user_id $project_id]

# VAW Special: Freelancers shouldnt see star and end date
# ToDo: Replace this hard coded condition with DynField
# permissions per field.
set user_can_see_start_end_date_p [expr [im_user_is_employee_p $current_user_id] || [im_user_is_customer_p $current_user_id]]

set show_start_date_p 0
if { $user_can_see_start_end_date_p && ![empty_string_p $start_date_formatted] } { 
    set show_start_date_p 1
}

set show_end_date_p 0
if { $user_can_see_start_end_date_p && ![empty_string_p $end_date] } {
    set show_end_date_p 1
}

set im_project_on_track_bb [im_project_on_track_bb $on_track_status_id]
 
# ---------------------------------------------------------------------
# Add DynField Columns to the display
set project_dynfield_attribs ""

# db_multirow -extend {attrib_var value} project_dynfield_attribs dynfield_attribs_sql {} {
#     set var ${attribute_name}_deref
#     set value [expr $$var]
#     if {"" != [string trim $value]} {
# 	set attrib_var [lang::message::lookup "" intranet-core.$attribute_name $pretty_name]
#     }
# }


set edit_project_base_data_p [im_permission $current_user_id edit_project_basedata]
set user_can_see_start_end_date_p [expr [im_user_is_employee_p $current_user_id] || [im_user_is_customer_p $current_user_id]]

set brand_id [db_string s "select brand_id from im_projects where project_id=$project_id" -default 0]
set product_id [db_string d "select product_id from im_projects where project_id=$project_id" -default 0]

set brand_info "select *, im_name_from_user_id(key_contact) as key_contact_name from im_vmc_brands where brand_id=$brand_id"
db_foreach ss $brand_info {
	set brand_name "<a href=/intranet/companies/create_brand?company_id=$company_id&brand_id=$brand_id&form_mode=display>$brand_name</a>"
    set contact_name "<a href=/intranet/users/view?user_id=$key_contact>$key_contact_name</a>"
    set phone_num $phone
    set email $email
    set product_name [db_string s "select product_name from im_vmc_products where product_id=$product_id" -default ""]
    set product_name "<a href=/intranet/companies/add_product?brand_id=$brand_id&product_id=$product_id>$product_name</a>"
}
set project_options [db_list_of_lists opt "SELECT 
    
     im_project_name_from_id(project_id) as projectname,
       project_id
 from 
     im_projects p
 where 
    parent_id=$project_id 
   and task_position is not null
   and project_status_id=(select category_id from im_categories where category_type='Intranet Project Status' and category='Closed') "]
set project_options [linsert $project_options 0 {"" "" }]
set add_adhoc_html ""
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
            background: url(\"/button_bg.gif\") repeat-x scroll 0 0 transparent;
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
append add_adhoc_html "<a href= href onClick=\"return pop2('pop1')\" style=text-decoration:none><input type=button name=Redo value=Redo class=\"form-button40\"></a>

"
append add_adhoc_html "
<div id=\"pop1\" class=\"parentDisable1\">
   <br/><br/>
    <table border=\"0\" id=\"popup1\" height=\"150\" width=\"425\">
     <tr/><tr/>
    <form id=\"myProfile\" method=\"get\" action=\"/intranet/projects/view\" onsubmit=\"return Checkfiles(this);\">
        <tr class=\"rowtitle1\">
            <td align=\"top\" colspan=2 algin=\"right\" class=\"rowtitle1\">
                <div class=\"rowtitle1\"><h3>Redo Task From</h3></div>
            </td>
            
            <td valign=\"top\">
                <div class=\"rowtitle1\"\"><a onClick=\"return hide2('pop1')\"><img src=\"/close_portlet.gif\" alt=\"X\"/></a></div>                     
            </td>
        </tr>
        <tr>
            <td align=\"left\" height=\"2px\" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Redo From<b/><br><br></td>         
            <td align=\"left\"height=\"2px\" > [im_select -ad_form_option_list_style_p 1 -translate_p 0 task_id $project_options 0]
                  
                
                    
            </td>
         </tr><tr >

               
            <td align=\"right\"  height=\"2px\">
               <input type=\"checkbox\" name=\"duration_from_config\" value=\"t\">
		
                    
            </td>
		<td align=\"lest\" height=\"2px\"><b>Duration should consider from home page<b/></td>      
        </tr>
        <tr>
            <td colspan=\"2\" align=\"center\" font=\"50\"> <b><input type=\"submit\" value=\"Redo  \" /></td></b>
           <input type=hidden name=flag1 value=1>
           <input type=hidden name=project_id value=$project_id>
        </tr>                       
    </form>
    </table>
   
    </div>

"

set count_tasks [db_string sd "select count(*) from im_projects where parent_id=$project_id and task_position=1 and project_status_id=(select category_id from im_categories where category_type='Intranet Project Status' and category='Closed') " -default 0]


if {$count_tasks==0} {
  set add_adhoc_html ""
}