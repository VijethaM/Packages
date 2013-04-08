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
    brand_id:integer,optional
    
    {product_id:integer 0}
    { form_mode "edit" }
    {product_name ""}
    {description ""}
    { return_url "" }
}

# ------------------------------------------------------
# Defaults & Security
# ------------------------------------------------------
# set name ""
# set descrip ""
set user_id1 [ad_maybe_redirect_for_registration]
# set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set required_field "<font color=red size=+1><B>*</B></font>"
set today [db_string s "select sysdate from dual"]
set ip_address [ad_conn peeraddr]
set action_url "/intranet/companies/new-2"
set focus "menu.var_name"

set page_title "Create Product"
set context_bar [im_context_bar [list index "[_ intranet-core.Companies]"] [list "view?[export_url_vars company_id]" "[_ intranet-core.One_company]"] $page_title]

# Should we bother about State and ZIP fields?
set some_american_readers_p [parameter::get_from_package_key -package_key acs-subsite -parameter SomeAmericanReadersP -default 0]

set current_url [im_url_with_query]

# ------------------------------------------------------------------
# Permissions
# ------------------------------------------------------------------

# Check if we are creating a new company or editing an existing one:
set product_exists_p 0
if {[info exists product_id]} {
    set product_exists_p [db_string company_exists "
	select count(*) 
	from im_vmc_products 
	where product_id = $product_id
    "]
}
# 
set company_id [db_string cmpy "select distinct company_id from im_vmc_brands where brand_id=$brand_id" -default 0] 
if {$product_exists_p} {
    set page_title "Edit Product"
    set product_details_sql "select product_name as name,description  from im_vmc_products where product_id=$product_id"
    db_foreach li $product_details_sql {
        set product_name $name
        set description $description
    }

} else {
    set product_name ""
    set description ""
}
# ad_return_complaint 1 "$brand_id"




# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------
set edit_buttons [list]
lappend edit_buttons { "Save Changes" "ok" }
set form_id "product"
set all_widgets {}

lappend all_widgets \
    [list product_id:text(hidden) {value $product_id }] \
    [list brand_id:text(hidden) {value $brand_id }] \
    [list product_name:text(text) {label "[_ intranet-core.Name]"} {html {size 30}} {value $product_name }] \
    [list description:text(textarea) {label "[_ intranet-core.Description]"} {html {rows 5 cols 30}} {value $description } ] 
ad_form -name product \
    -mode $form_mode \
    -method get \
    -cancel_url /intranet/companies/view?company_id=$company_id \
    -cancel_label "Cancel" \
    -export {next_url user_id return_url also_add_users} \
    -form $all_widgets \
    -edit_buttons "$edit_buttons" \
    -on_submit {
        if {$product_name==""} {
            ad_return_complaint 1 "Please Enter Product Name "
            ad_script_abort
        }
        if {$description==""} {
            ad_return_complaint 1 "Please Enter Description "
            ad_script_abort
        }
#	set brand_name [db_string cmpy "select brand_name from im_vmc_brands where brand_id=$brand_id" -default 0] 
#	ad_return
#          ad_return_complaint 1 "$company_id           $brand_id  $brand_name"
        if {$product_exists_p} {
	  
            db_dml update_product "
                update im_vmc_products
                set product_name=:product_name,
                description=:description
                where
                    product_id=$product_id
            "
        } else {
                set new_obj_id [im_new_object_id]
                set product_id [db_string create_obj "select acs_object__new (
                        :new_obj_id,
                        'im_vmc_products',
                        :today,                
                        :user_id1,       
                        :ip_address,
                        null
                    )"]
                db_dml add_product "
                    insert into im_vmc_products (
                        product_id,
                        product_name,
                        description,
                        brand_id
                        )
                    values (
                        :product_id,
                        :product_name,
                        :description,
                        :brand_id
                        )
                    "
        }
        ad_returnredirect "/intranet/companies/view?company_id=$company_id"
        ad_script_abort
    }

# ad_form -name upload_test -html {enctype multipart/form-data} -form { {upload_file:file {label "Enter a filename or use the browse button"}} } 
