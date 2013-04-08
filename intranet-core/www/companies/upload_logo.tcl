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
    To create Brand for Company
    @author nikhil.arpally@venkatmangudi.com
  
} {
	{brand_id:integer 0}
    {company_id:integer 0}
    { form_mode "edit" }
    {flag 0}
    {upload_file ""}
}
set user_id [ad_maybe_redirect_for_registration]
set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set required_field "<font color=red size=+1><B>*</B></font>"
if {$flag==1} {
   
   set filename [template::util::file::get_property filename $upload_file] 
        set tmp_filename [template::util::file::get_property tmp_filename $upload_file] 
        set mime_type [template::util::file::get_property mime_type $upload_file]
    exec rm -rf /web/projop/www/logo/$brand_id/
    exec cp $tmp_filename /web/projop/www/logo/$brand_id/$filename
    set logo_path "/$brand_id/$filename"
     db_dml update_product "
                update im_vmc_brands
                set 
                 logo_path=:logo_path
                where
                    brand_id=$brand_id
            "

}
ad_returnredirect "/intranet/companies/view?company_id=$company_id"