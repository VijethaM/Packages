# /packages/intranet-core/www/companies/create_brand.tcl
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
    Lets users add/modify information about our brands.
    Contact details are not stored with the company itself,
    but with a "main_office" that is a required property
    (not null).

    @param company_id if specified, we edit the company with this company_id
    @param return_url Return URL

    @author nikhil.arpally@venkatmangudi.com
  
} {
    {brand_id:integer 0}
    {company_id:integer 0}
    { form_mode "" }
    {brand_name ""}
    {description ""}
    {upload_file ""}
    {manager_id ""}
    {phone ""}
    {email ""}
    { return_url "" }
    {return_url1 ""}
    {first_name ""}
    {last_name ""}
    {flag ""}
    {industry_category ""}
    {logo_path ""}

}

# ------------------------------------------------------
# Defaults & Security
# ------------------------------------------------------
# ad_return_complaint 1 "$formbutton"
set user_id [ad_maybe_redirect_for_registration]
set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set required_field "<font color=red size=+1><B>*</B></font>"
set display_logo_html ""
set today [db_string s "select sysdate from dual"]
set ip_address [ad_conn peeraddr]
set user_id1 [ad_maybe_redirect_for_registration]

# set action_url "/intranet/companies/new-2"
set focus "menu.var_name"

set page_title ""
set context_bar [im_context_bar [list index "[_ intranet-core.Companies]"] [list "view?[export_url_vars company_id]" "[_ intranet-core.One_company]"] $page_title]

# Should we bother about State and ZIP fields?
# set some_american_readers_p [parameter::get_from_package_key -package_key acs-subsite -parameter SomeAmericanReadersP -default 0]

# set current_url [im_url_with_query]

# ------------------------------------------------------------------
# Permissions
# ------------------------------------------------------------------

# Check if we are creating a new company or editing an existing one:
set brand_exists_p 0
if {[info exists brand_id]} {
    set brand_exists_p [db_string company_exists "
	select count(*) 
	from im_vmc_brands 
	where brand_id = :brand_id
    "]
}
set bgcolor(0) "class=roweven"
set bgcolor(1) "class=rowodd"
set bgcolor(2) "class=roweven"
if {$brand_exists_p} {
    set page_title "Edit Brand"
    # Check company permissions for this user
    im_company_permissions $user_id $company_id view read write admin
    if {!$write} {
	ad_return_complaint "[_ intranet-core.lt_Insufficient_Privileg]" "
            <li>[_ intranet-core.lt_You_dont_have_suffici]"
	return
    }
   set brand_details_sql "
		select 
			*
		from
			im_vmc_brands
		where
			brand_id=:brand_id
   "
   db_foreach brd_list $brand_details_sql {
        set brand_name $brand_name
	set logo_path $logo_path
	set description $description
	set phone $phone
	set email $email
	set manager_id $key_contact
	set industry_category $industry_category


	}


} else {
    set page_title "Create Brand"
    # Does the current user has the right to create a new company?
    if {![im_permission $user_id add_companies]} {
	ad_return_complaint "[_ intranet-core.lt_Insufficient_Privileg]" "
            <li>[_ intranet-core.lt_You_dont_have_suffici]"
	return
    }
}
set is_display_mode 0
if {$form_mode=="display" } {
set is_display_mode 1
append display_logo_html "
    <a href=\"/intranet/companies/create_brand?company_id=$company_id&brand_id=$brand_id&form_mode=display&flag=1\">
 <img border=\"2px\" width=\"120\" name=\"image_name\" height=\"120\" onmouseout=\"image_name.width='120';image_name.height='120';image_name.border='2px';\" onmouseover=\"image_name.width='200';image_name.height='200';\" name=\"image_name\" title=\"Change Logo\" alt=\"brand-001 for test\" src=\"/logo/$logo_path\">
</a>"

append show_products_html "

    <script language=\"javascript\"> 
    function toggle(e) {
        var ele = document.getElementById('toggleText' + e);
        var text = document.getElementById('displayText' + e);
        if(ele.style.display == \"block\") {
                ele.style.display = \"none\";
            text.innerHTML = \"Show\";
        }
        else {
            ele.style.display = \"block\";
            text.innerHTML = \"Hide\";
        }

    }
    </script>
    "
append show_products_html "
<table width=\"100%\">
<tbody>
<tr class=\"rowtitle\">
    <td class=\"rowtitle\">Product Name</td>
    <td class=\"rowtitle\">Project Name</td>
    <td class=\"rowtitle\">Personnel</td>
</tr>
"
set product_list "
        select 
            product_id,product_name
        from 
            im_vmc_products
        where 
            brand_id=$brand_id
"
set ctr 0
db_foreach prt_list $product_list {

    append show_products_html "
        <tr $bgcolor([expr $ctr % 2])>
            <td $bgcolor([expr $ctr % 2])><b>
        <a href=\"/intranet/companies/add_product?brand_id=$brand_id&product_id=$product_id\">$product_name</a>
            </b></td>
    "
    set project_list "
        select 
            project_name,project_id
        from 
            im_projects
        where 
            product_id=$product_id
    "
    append show_products_html "
                <td $bgcolor([expr $ctr % 2])>
                <a id=\"displayText$product_id\" href=\"javascript:toggle($product_id);\">Show</a>
                <div id=\"toggleText$product_id\" style=\"display: none\">
                <b>
                "
                
        db_foreach s $project_list {
        append show_products_html "
                <b>
                <a href=\"/intranet/projects/view?project_id=$project_id\">$project_name</a> <br/>
            "
        }
        append show_products_html "
                </b>
                </div>
                </td>
        "
        append show_products_html "
            <td $bgcolor([expr $ctr % 2])>&nbsp;&nbsp;&nbsp;</td>
            </tr>


        "
    incr ctr
}







}







# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------


#set employee_options [im_employee_options]
set employee_options [db_list_of_lists ss "select im_name_from_user_id(object_id_two),object_id_two from acs_rels where object_id_one=$company_id and rel_type='im_company_employee_rel'"]
set last [db_string ds "select count(*)+1 from acs_rels where object_id_one=$company_id and rel_type='im_company_employee_rel'" -default 0]
set employee_options [linsert $employee_options 0 {"" "" }]
set employee_options [linsert $employee_options $last {{Other} 11}]
set industry_category_options [db_list_of_lists opt "select category,category_id from im_categories where category_type='Intranet Company Type'"]
set industry_category_options [linsert $industry_category_options 0 {"" "" }]
set form_id "brand"
set all_widgets {}
lappend all_widgets \
    [list brand_id:text(hidden) {value $brand_id}] \
    [list form_mode:text(hidden) {value $form_mode}] \
    [list company_id:text(hidden) {value $company_id}] \
    [list brand_name:text(text) {label "[_ intranet-core.Brand_Name]"} {html {size 30}} {value $brand_name}] 
lappend all_widgets \
    [list description:text(textarea) {label "[_ intranet-core.Description]"} {html {rows 5 cols 35}} {value $description} ] 
if {$manager_id !="11"} {
	lappend all_widgets \
        [list manager_id:text(select),optional {label "[_ intranet-core.Key_Brand_Contact_Name]"} {options $employee_options} {value $manager_id} {html {onChange "document.brand.__refreshing_p.value='1';document.brand.submit()"}} {section "Contact Information"}]
} else {
    lappend all_widgets \
        [list first_name:text(text),optional {label "[_ intranet-core.Key_Brand_Contact_First_Name]"} {html {size 30}} {section "Contact Information"} ]\
        [list last_name:text(text),optional {label "[_ intranet-core.Key_Brand_Contact_Last_Name]"} {html {size 30}} {section "Contact Information"} ]
	
}
lappend all_widgets \
    [list phone:text(text),optional {label "[_ intranet-core.Phone ]"} {html {size 30}} {value $phone} {section "Contact Information"}] \
    [list email:text(text),optional {label "[_ intranet-core.Email_Address]"} {html {size 30}} {value $email} {section "Contact Information"}] \
    [list industry_category:text(select) {label "[_ intranet-core.IndustryCategory ]"} {options $industry_category_options}  {value $industry_category} {section "Contact Information"}] 
if {$form_mode!="display" || $flag==1} {
lappend all_widgets \
    [list upload_file:file(file) {label "[_ intranet-core.Logo]"} {html {size 30}} ]  
}
set edit_buttons [list]
lappend edit_buttons { "Save Changes" "ok" }

ad_form -name brand \
    -mode edit \
    -method post \
    -cancel_url /intranet/companies/view?company_id=$company_id \
    -cancel_label "Cancel" \
    -edit_buttons "$edit_buttons" \
    -html { enctype multipart/form-data } \
    -form $all_widgets \
    -on_submit {
        # if {$upload_file==""} {
        #     ad_return_complaint 1 "Please Select Logo For Brand"
        # }
        
        # ad_return_complaint 1 "$tmp_filename"
        # set log_path "/logo/$brand_id/$filename"
        # ad_return_complaint 1 "$manager_id"
	
        if {$brand_name==""} {
            ad_return_complaint 1 "Please enter value for Brand Name"
            ad_script_abort
        }
        if {$description==""} {
            ad_return_complaint 1 "Please enter value for Description"
            ad_script_abort
        }
        if {$industry_category==""} {
            ad_return_complaint 1 "Please enter value for Industry Category"
            ad_script_abort
        }
        if {$first_name!=""} {
            set screen_name [string tolower "$first_name $last_name"]
            regsub -all {[^A-Za-z0-9_]} $screen_name "_" username
            set secret_question ""
            set secret_answer ""
            set web_page ""
            set password ""
            set password_confirm ""
            set username "$screen_name"
            set manager_id [db_nextval acs_object_id_seq]
            array set creation_info [auth::create_user \
                                             -user_id $manager_id \
                                             -verify_password_confirm \
                                             -username $username \
                                             -email $email \
                                             -first_names $first_name \
                                             -last_name $last_name \
                                             -screen_name $screen_name \
                                             -password $password \
                                             -password_confirm $password_confirm \
                                             -url $web_page \
                                             -secret_question $secret_question \
                     -secret_answer $secret_answer]
           
	    set profile_id [im_profile_customers]
	    set rel_id [relation_add -member_state "approved" "membership_rel" $profile_id $manager_id]
            db_dml update_relation "update membership_rels set member_state='approved' where rel_id=:rel_id"
             im_biz_object_add_role $manager_id $company_id [im_biz_object_role_full_member]
        }
   
	if {$brand_exists_p} {
            if {$upload_file !=""} {
                set filename [template::util::file::get_property filename $upload_file] 
                set tmp_filename [template::util::file::get_property tmp_filename $upload_file] 
                set mime_type [template::util::file::get_property mime_type $upload_file]
#                  ad_return_complaint 1 "$filename"
                 set file_format [string tolower [lindex [split $mime_type "/"] 0]]
#                  ad_return_complaint 1 "$tmp_filename"
                if { $file_format != "image" } {
                    ad_return_complaint 1 "Please enter correct format to upload."
                    ad_script_abort 
                }
                
                exec rm -rf /web/projop/www/logo/$brand_id
                exec mkdir /web/projop/www/logo/$brand_id
                exec cp $tmp_filename /web/projop/www/logo/$brand_id/$filename
                set logo_path /$brand_id/$filename
                set select_options ",logo_path =:logo_path"
                
            } else {
                set select_options ""
            }
            if {$phone!=""} {
                append select_options ",phone=$phone"
            }
            if {$email!=""} {
                append select_options ",email=:email"
            }
	    if {$manager_id!=""} {
		append select_options ",key_contact=$manager_id"
	    }
            db_dml update_product "
                update im_vmc_brands
                set brand_name=:brand_name,
                description=:description,
                company_id=:company_id,
                industry_category=:industry_category
                $select_options
                where
                    brand_id=$brand_id
            "
        } else {
                set filename [template::util::file::get_property filename $upload_file] 
                set tmp_filename [template::util::file::get_property tmp_filename $upload_file] 
                set mime_type [template::util::file::get_property mime_type $upload_file]
               set file_format [string tolower [lindex [split $mime_type "/"] 0]]
#                  ad_return_complaint 1 "$tmp_filename"
                if { $file_format != "image" } {
                    ad_return_complaint 1 "Please enter correct format to upload."
                    ad_script_abort 
                }
                # ad_return_complaint 1 "ddddddd $tmp_filename"
                set new_obj_id [im_new_object_id]
                 # ad_return_complaint 1 "ddddddd $tmp_filename"
                set brand_id [db_string create_obj "select acs_object__new (
                        :new_obj_id,
                        'im_vmc_brands',
                        :today,                
                        :user_id1,       
                        :ip_address,
                        null
                    )"]
                
                exec mkdir /web/projop/www/logo/$brand_id
                exec cp $tmp_filename /web/projop/www/logo/$brand_id/$filename
                set logo_path /$brand_id/$filename
                db_dml add_brand "
                    insert into im_vmc_brands (
                        brand_id,
                        brand_name,
                        description,
                        company_id,
                        key_contact,
                        industry_category,
                        phone,
                        email,
                        logo_path
                        )
                    values (
                        :brand_id,
                        :brand_name,
                        :description,
                        :company_id,
                        :manager_id,
                        :industry_category,
                        :phone,
                        :email,
                        :logo_path
                        )
                    "
        }
        ad_returnredirect "/intranet/companies/view?company_id=$company_id"
        ad_script_abort
        # ad_return_complaint 1 "$filename ................. $tmp_filename ......... $mime_type"
    # send email
    set button [form::get_button brand]

         

    # ad_returnredirect "[ad_conn url]?[export_vars { locale package_key show page_start }]"
    # ad_script_abort 

}
