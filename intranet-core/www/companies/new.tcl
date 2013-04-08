# /packages/intranet-core/www/companies/new.tcl
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
    Lets users add/modify information about our companies.
    Contact details are not stored with the company itself,
    but with a "main_office" that is a required property
    (not null).

    @param company_id if specified, we edit the company with this company_id
    @param return_url Return URL

    @author mbryzek@arsdigita.com
    @author frank.bergmann@project-open.com
    @author juanjoruizx@yahoo.es
} {
    company_id:integer,optional
    company_status_id:integer,optional
    {company_name "" }
    {company_type_id "" }
    { form_mode "edit" }
    { return_url "" }
    { also_add_users "" }
    {company_name "" }
    { company_path "" }
	{ main_office_id:integer "" }
    { group_type "" }
    { approved_p "" }
    { new_member_policy "" }
    { parent_group_id "" }
    { referral_source "" }
    { annual_revenue_id "" }
    { vat_number "" }
    { note "" }
    { contract_value "" }
    { site_concept "" }
    { manager_id "" }
    { billable_p "" }
    { start_date "" }
    { phone "" }
    { fax "" }
    { address_line1 "" }
    { address_line2 "" }
    { address_city "" }
    { address_state "" }
    { address_postal_code "" }
    { address_country_code "" }
    { start:array,date "" }
    { old_company_status_id "" }
    { status_modification_date.expr "" }
	{ upload_file ""}
	{flag1 0}
	{flag 0}
}

# ------------------------------------------------------
# Defaults & Security
# ------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set required_field "<font color=red size=+1><B>*</B></font>"
set display_logo_html ""
# set action_url "/intranet/companies/new-2"
set focus "menu.var_name"

set page_title "[_ intranet-core.Edit_Company]"
set context_bar [im_context_bar [list index "[_ intranet-core.Companies]"] [list "view?[export_url_vars company_id]" "[_ intranet-core.One_company]"] $page_title]

# Should we bother about State and ZIP fields?
set some_american_readers_p [parameter::get_from_package_key -package_key acs-subsite -parameter SomeAmericanReadersP -default 0]

set current_url [im_url_with_query]

# ------------------------------------------------------------------
# Permissions
# ------------------------------------------------------------------

# Check if we are creating a new company or editing an existing one:
set company_exists_p 0
if {[info exists company_id]} {
    set company_exists_p [db_string company_exists "
	select count(*) 
	from im_companies 
	where company_id = :company_id
    "]
} 

if {$company_exists_p} {

    # Check company permissions for this user
    im_company_permissions $user_id $company_id view read write admin
    if {!$write} {
	ad_return_complaint "[_ intranet-core.lt_Insufficient_Privileg]" "
            <li>[_ intranet-core.lt_You_dont_have_suffici]"
	return
    }

} else {

    # Does the current user has the right to create a new company?
    if {![im_permission $user_id add_companies]} {
	ad_return_complaint "[_ intranet-core.lt_Insufficient_Privileg]" "
            <li>[_ intranet-core.lt_You_dont_have_suffici]"
	return
    }

    # Do we need to get the company type first in order to show the right DynFields?
    if {("" == $company_type_id || 0 == $company_type_id)} {
	set all_same_p [im_dynfield::subtype_have_same_attributes_p -object_type "im_company"]
	if {!$all_same_p} {
	    set exclude_category_ids [list [im_id_from_category "CustOrIntl" "Intranet Company Type"]]
	    ad_returnredirect [export_vars -base "/intranet/biz-object-type-select" {
		company_name
		also_add_users
		{ return_url $current_url } 
		{ object_type "im_company" }
		{ type_id_var "company_type_id" }
		{ pass_through_variables "company_name also_add_users" }
		{ exclude_category_ids $exclude_category_ids }
	    }]
	}
    }   
}
if {$company_exists_p} {
	set company_list "
        select 
            company_logo,company_name
        from 
            im_companies
        where 
            company_id=$company_id
	"
	db_foreach logo $company_list {
		set company_logo $company_logo
		set company_name $company_name
	}

}

if {$form_mode=="display" || $flag==1 || $flag1==1 || $company_exists_p} {
append display_logo_html "
    <a href=\"/intranet/companies/new?company_id=$company_id&form_mode=edit&flag1=1\">
 <img border=\"2px\" width=\"200\" name=\"image_name\" height=\"200\" onmouseout=\"image_name.width='200';image_name.height='200';image_name.border='2px';\" onmouseover=\"image_name.width='280';image_name.height='280';\" name=\"image_name\" title=\"Change Logo\" alt=\"brand-001 for test\" src=\"/company_logo$company_logo\" alt=\"$company_name\"/>
</a>"
}
if {$company_exists_p && $flag==1} {
	set flag1 1
}
if {!$company_exists_p} {
	set flag1 1
}
# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------

set company_status_options [list]
set company_type_options [list]
set annual_revenue_options [list]
set country_options [im_country_options]
set employee_options [im_employee_options]

set form_id "company"

ad_form \
    -name $form_id \
    -method post \
    -cancel_url $return_url \
    -mode edit \
    -html { enctype multipart/form-data } \
    -form {
	company_id:key
	{main_office_id:text(hidden),optional}
	{start_date:text(hidden),optional}
	{contract_value:text(hidden),optional}
	{billable_p:text(hidden),optional}
	{company_name:text(text) {label "[_ intranet-core.Company_Name]"} {html {size 60}}}
	{company_path:text,optional {label "[_ intranet-core.Company_Short_Name]"} {html {size 40}}}
	{referral_source:text(hidden),optional {label "[_ intranet-core.Referral_Source]"} {html {size 60}}}
	{company_status_id:text(im_category_tree) {label "[_ intranet-core.Company_Status]"} {custom {category_type "Intranet Company Status" } } }
	{company_type_id:text(im_category_tree) {label "[_ intranet-core.Company_Type]"} {custom {category_type "Intranet Company Type"} } }
	{manager_id:text(hidden),optional {label "[_ intranet-core.Key_Account]"} {options $employee_options} }
	{phone:text(text),optional {label "[_ intranet-core.Phone]"} {html {size 20}}}
	{fax:text(text),optional {label "[_ intranet-core.Fax]"} {html {size 20}}}
	{address_line1:text(text),optional {label "[_ intranet-core.Address_1]"} {html {size 40}}}
	{address_line2:text(text),optional {label "[_ intranet-core.Address_2]"} {html {size 40}}}
	{address_city:text(text),optional {label "[_ intranet-core.City]"} {html {size 30}}}
    }

if {$form_mode!="display"} {
	ad_form -extend -name $form_id -form {
	{upload_file:file(file) {label "[_ intranet-core.Logo]"} {html {size 30}}}
	}

}
if {$some_american_readers_p} {
    ad_form -extend -name $form_id -form {
	{address_state:text(text),optional {label "[_ intranet-core.State]"} {html {size 30}}}
    }
} else {
    ad_form -extend -name $form_id -form {
	{address_state:text(hidden),optional}
    }    
}

ad_form -extend -name $form_id -form {
	{address_postal_code:text(text),optional {label "[_ intranet-core.ZIP]"} {html {size 6}}}
	{address_country_code:text(select),optional {label "[_ intranet-core.Country]"} {options $country_options} }
	{site_concept:text(text),optional {label "[_ intranet-core.Web_Site]"} {html {size 60}}}
	{vat_number:text(hidden),optional {label "[_ intranet-core.VAT_Number]"} {html {size 60}}}
	{annual_revenue_id:text(hidden),optional {label "[_ intranet-core.Annual_Revenue]"} {custom {category_type "Intranet Annual Revenue"} } }
	{note:text(textarea),optional {label "[_ intranet-core.Description]"} {}}
    }

# ------------------------------------------------------
# Dynamic Fields
# ------------------------------------------------------

set object_type "im_company"
set my_company_id 0
if {[info exists company_id]} { set my_company_id $company_id }

if {$company_exists_p} {
    set my_company_type_id [db_string type "select company_type_id from im_companies where company_id = :my_company_id" -default 0]
} else {
    set my_company_type_id $company_type_id
}

# Add dynfields to the form
#commented because its not needed  for proKen
# im_dynfield::append_attributes_to_form \
#     -object_type "im_company" \
#     -form_id $form_id \
#     -object_id $my_company_id \
#     -object_subtype_id $my_company_type_id


# Set the company type which might be available already.
if {0 != $company_type_id && "" != $company_type_id} { 
    template::element::set_value $form_id company_type_id $company_type_id
}

# if {"" != $company_name} { 
#     template::element::set_value $form_id company_name $company_name

#     regsub {[^a-zA-Z0-9_]} [string tolower $company_name] "_" company_path
#     template::element::set_value $form_id company_path $company_path
# }

# Execute the form - pull out variables and perform actions
ad_form -extend -name $form_id -select_query {

select
	c.*,
	to_char(c.start_date,'YYYY-MM-DD') as start_date_formatted,
	o.phone,
	o.fax,
	o.address_line1,
	o.address_line2,
	o.address_city,
	o.address_state,
	o.address_postal_code,
	o.address_country_code
from 
	im_companies c, 
	im_offices o
where 
	c.company_id = :company_id
	and c.main_office_id = o.office_id

} -on_submit {

# -----------------------------------------------------------------
# To-Lower the company path and check for alphanum characters
#																																																																																																																																																															
# set normalize_company_path_p [parameter::get_from_package_key -package_key "intranet-core" -parameter "NormalizeCompanyPathP" -default 1]

# if {$normalize_company_path_p} {
#     set company_path [string tolower [string trim $company_path]]
    
#     if {![regexp {^[a-z0-9_]+$} $company_path match]} {
# 	incr exception_count
# 	append errors "  <li>[lang::message::lookup "" intranet-core.Non_alphanum_chars_in_path "The specified path contains invalid characters. Allowed are only aphanumeric characters from a-z, 0-9 and '_'."]: '$company_path'"
#     }
# }
#
# Make sure company name is unique
set exists_p [db_string group_exists_p "
	select count(*)
	from im_companies
	where lower(trim(company_path))=lower(trim(:company_path))
            and company_id != :company_id
"]
# set filename [template::util::file::get_property filename $upload_file] 
# set tmp_filename [template::util::file::get_property tmp_filename $upload_file] 
# set mime_type [template::util::file::get_property mime_type $upload_file]
# ad_return_complaint 1 "$tmp_filename"
if { $exists_p } {
    incr exception_count
    append errors "  <li>[_ intranet-core._The]"
}

if { [exists_and_not_null errors] } {
    ad_return_complaint $exception_count "<ul>$errors</ul>"
    return
}


# ------------------------------------------------------------------
# Permissions
# ------------------------------------------------------------------

# Check if we are creating a new company or editing an existing one:
set company_exists_p 0
if {[info exists company_id]} {
    set company_exists_p [db_string company_exists "
        select count(*)
        from im_companies
        where company_id = :company_id
    "]
}
if {$company_exists_p} {
    if {$upload_file !=""} {
        set filename [template::util::file::get_property filename $upload_file] 
        set tmp_filename [template::util::file::get_property tmp_filename $upload_file] 
        set mime_type [template::util::file::get_property mime_type $upload_file]
         # ad_return_complaint 1 "$filename $tmp_filename"
         # set mime_type [template::util::file::get_property mime_type $upload_file]
         # ad_return_complaint 1 "$mime_type"
         set file_format [string tolower [lindex [split $mime_type "/"] 0]]
         # ad_return_complaint 1 "$file_format"
        if { $file_format != "image" } {
            ad_return_complaint 1 "Please enter correct format to upload."
            ad_script_abort 
        }
                
	    exec rm -rf /web/projop/www/company_logo/$company_id
	    exec mkdir /web/projop/www/company_logo/$company_id
	    exec cp $tmp_filename /web/projop/www/company_logo/$company_id/$filename
	    set logo_path /$company_id/$filename
	    set select_options ",logo_path =:logo_path"
        
    } else {
        set select_options ""
    }
 }
if {$company_exists_p} {

    # Check company permissions for this user
    im_company_permissions $user_id $company_id view read write admin
    if {!$write} {
        ad_return_complaint "[_ intranet-core.lt_Insufficient_Privileg]" "
            <li>[_ intranet-core.lt_You_dont_have_suffici]"
        return
    }

} else {

    if {![im_permission $user_id add_companies]} {
        ad_return_complaint "[_ intranet-core.lt_Insufficient_Privileg]" "
            <li>[_ intranet-core.lt_You_dont_have_suffici]"
        return
    }

}


# -----------------------------------------------------------------
# Create a new Company if it didn't exist yet
# -----------------------------------------------------------------

if {![exists_and_not_null office_name]} {
    set office_name "$company_name [_ intranet-core.Main_Office]"
}
if {![exists_and_not_null office_path]} {
    set office_path "$company_path"
}

# Double-Click protection: the company Id was generated at the new.tcl page
if {0 == $company_exists_p} {

    db_transaction {
	# First create a new main_office:
	set main_office_id [office::new \
		-office_name	$office_name \
		-company_id     $company_id \
		-office_type_id [im_office_type_main] \
		-office_status_id [im_office_status_active] \
		-office_path	$office_path]

	# add users to the office as 
        set role_id [im_biz_object_role_office_admin]
        im_biz_object_add_role $user_id $main_office_id $role_id

	ns_log Notice "/companies/new: main_office_id=$main_office_id"
	

	# Now create the company with the new main_office:
	set company_id [company::new \
		-company_id $company_id \
		-company_name	$company_name \
		-company_path	$company_path \
		-main_office_id	$main_office_id \
		-company_type_id $company_type_id \
		-company_status_id $company_status_id]
	
	# add users to the company as key account
	set role_id [im_biz_object_role_key_account]
	im_biz_object_add_role $user_id $company_id $role_id

    }
}
if {$upload_file !=""} {
	   set filename [template::util::file::get_property filename $upload_file] 
	   set tmp_filename [template::util::file::get_property tmp_filename $upload_file] 
	   set mime_type [template::util::file::get_property mime_type $upload_file]
	    # ad_return_complaint 1 " $tmp_filename $mime_type"
	   #set mime_type [template::util::file::get_property mime_type $upload_file]
	   set file_format [string tolower [lindex [split $mime_type "/"] 0]]
         # ad_return_complaint 1 "$file_format"
        if { $file_format != "image" } {
            ad_return_complaint 1 "Please enter correct format to upload."
            ad_script_abort 
        }
        exec rm -rf /web/projop/www/company_logo/$company_id
		exec mkdir /web/projop/www/company_logo/$company_id
		exec cp $tmp_filename /web/projop/www/company_logo/$company_id/$filename
		set logo_path /$company_id/$filename
		set select_options ",company_logo ='$logo_path'"
		
} else {
    set select_options ""
}
#ad_return_complaint 1 "$select_options      $tmp_filename"
# -----------------------------------------------------------------
# Update the Office
# -----------------------------------------------------------------

set update_sql "
	update im_offices set
		office_name	= :office_name,
		phone		= :phone,
		fax		= :fax,
		address_line1	= :address_line1,
		address_line2	= :address_line2,
		address_city	= :address_city,
		address_state	= :address_state,
		address_postal_code = :address_postal_code,
		address_country_code = :address_country_code
	where
		office_id = :main_office_id
"
db_dml update_offices $update_sql

im_audit -object_type "im_office" -object_id $main_office_id -action after_update


# -----------------------------------------------------------------
# Update the Company
# -----------------------------------------------------------------
set company_path "$company_name"
set update_sql "
	update im_companies set
		company_name		= :company_name,
		company_path		= :company_path,
		vat_number		= :vat_number,
		company_status_id	= :company_status_id,
		old_company_status_id	= :old_company_status_id,
		company_type_id		= :company_type_id,
		referral_source		= :referral_source,
		start_date		= :start_date,
		annual_revenue_id	= :annual_revenue_id,
		contract_value		= :contract_value,
		site_concept		= :site_concept,
		manager_id		= :manager_id,
		billable_p		= :billable_p,
		note			= :note
		$select_options
	where
		company_id = :company_id
"
# ad_return_complaint 1 "$update_sql"
db_dml update_company $update_sql
im_audit -object_type "im_company" -object_id $company_id -action after_update


# -----------------------------------------------------------------
# Make sure the creator and the manager become Key Accounts
# -----------------------------------------------------------------

set role_id [im_company_role_key_account]

im_biz_object_add_role $user_id $company_id $role_id
if {"" != $manager_id } {
    im_biz_object_add_role $manager_id $company_id $role_id
}


# Add additional users to the company
array set also_add_hash $also_add_users
foreach uid [array names also_add_hash] {
    set role_id $also_add_hash($uid)
    ns_log Notice "/intranet/companies/new: add user $uid to company $company_id with role $role_id"
    im_biz_object_add_role $uid $company_id $role_id
}

# -----------------------------------------------------------------
# Store dynamic fields
# -----------------------------------------------------------------

set form_id "company"
set object_type "im_company"

ns_log Notice "companies/new: before append_attributes_to_form"
im_dynfield::append_attributes_to_form \
    -object_type im_company \
    -form_id company \
    -object_id $company_id

ns_log Notice "companies/new: before attribute_store"
im_dynfield::attribute_store \
    -object_type $object_type \
    -object_id $company_id \
    -form_id $form_id



# ------------------------------------------------------
# Finish
# ------------------------------------------------------

# Flush the company cache
im_company::flush_cache

# Not sure if still necessary...
db_release_unused_handles


# Return to the new company page after creating
if {"" == $return_url} {
    set return_url [export_vars -base "/intranet/companies/view?" {company_id}]
}
} -after_submit {

	ad_returnredirect $return_url
	ad_script_abort
}

