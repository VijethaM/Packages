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

    @author vijetha.m@venkatmangudi.com
    @author nikhil.arpally@venkatmangudi.com
  
} {
    {company_id 0}



}


set bgcolor(0) "class=roweven"
	set bgcolor(1) "class=rowodd"
	set bgcolor(2) "class=roweven"

set log_path "/logo"
	append view_html "<table width=100% cellspacing=3><tr height=15px bgcolor=#A3D6FA ><td bgcolor=#A3D6FA><b>Brand Info</b></td>
											<!--<td $bgcolor(2)>Brand Name </td> -->
										<td bgcolor=#A3D6FA><b>Product Name</b></td>
										<td bgcolor=#A3D6FA><b>Personnel</b></td>
						</tr>
							
	"

	set brand_query "
			select 
				brand_id,
				brand_name,
				key_contact,
				im_name_from_user_id(key_contact) as key_contact_name,
				logo_path 
			from 
				im_vmc_brands
			where 
				company_id=$company_id
	"

	set ctr 0
	set brands_count [db_string xx "select count(*) from im_vmc_brands where company_id=$company_id" -default 0]
	if {$brands_count==0} {
		append view_html "<tr><td colspan=3>No Brands created</td></tr>"
	} else {
		db_foreach x $brand_query {
			append log_path "$logo_path"
			# ad_return_complaint 1 "$log_path"
			set brand_products_sql  "select product_name from im_vmc_products where brand_id=$brand_id"
			set row_span [db_string q "select count(*) from im_vmc_products where brand_id=$brand_id" -default 2]
			append view_html "
				<tr class=rowtitle >
					<td bgcolor=#FFFFFF rowspan=[expr $row_span+1]><a href= /intranet/companies/create_brand?company_id=$company_id&brand_id=$brand_id&form_mode=display><img  src=\"$log_path\" alt=\"$brand_name\" title=\"$brand_name\" width=\"70\" height=\"70\" ></a></td><td $bgcolor([expr $ctr%2]) colspan=2></tr>
			"	
			set brand_products_sql  "select product_name,product_id from im_vmc_products where brand_id=$brand_id"
			set ct 1

			db_foreach xy $brand_products_sql {
				if { [expr $ct%2]==0} {
					set x "bgcolor=#FFFFFF"
				} else {
					set x "bgcolor=#DFF4FF"
				}
				append view_html "<tr $x ><td  $x><b><a href =/intranet/companies/add_product?brand_id=$brand_id&product_id=$product_id>$product_name</b><a></td>
					<td $x><b>$key_contact_name</b></td>
				"
				
				incr ct
			}
			append view_html "<tr><td colspan=3 align=right>&nbsp;&nbsp; &nbsp; &nbsp;  <a href=/intranet/companies/add_product?brand_id=$brand_id>Add Product</a> <br/>
			</td></tr>"
			incr ctr
			set log_path "/logo"
		}
	}
	
	append view_html "</table>
	<a href=/intranet/companies/create_brand?company_id=$company_id>Create Brand</a><br/><br/>
	"