# /packages/notifications/proken_notifications/index.tcl

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



ad_page_contract {
	@param Page to display dashboards
	@author Vijetha.M(vijetha.m@venkatmangudi.com)
} {
	{out_table1 ""}
	{out_table2 ""}
	{out_table3 ""}
	{out_table4 ""}
	{out_table7 ""}
	{out_table8 ""}
	{out_table9 ""}
	{out_table10 ""}
}

# ---------------------------------------------------------------
# Project Menu
# ---------------------------------------------------------------
set user_id [ad_maybe_redirect_for_registration]
set page_title "The Work"
set bg_color(0) "class=rowodd"
set bg_color(1) "class=roweven"
set bg_color(2) "class=rowtitle"

set out_table1 "
<table cellpadding=0><tr $bg_color(2)><td $bg_color(2)>Task Name1</td><td $bg_color(2)>Project name</td><td $bg_color(2)>Start Date</td><td $bg_color(2)>End Date</td><td $bg_color(2)>Assigned By Me</tr>
"
append out_table1 "</table>"

# $bg_color([expr $ctr%2])
set out_table2 "
<table><tr><td>Task Name2</td><td>Create By2</td></tr>
"

append out_table2 "</table>"
set out_table3 "
<table><tr><td>Task Name3</td><td>Create By3</td></tr>
"

append out_table3 "</table>"
set out_table4 "
<table><tr><td>Task Name4</td><td>Create By4</td></tr>
"

append out_table4 "</table>"
set out_table7 "
<table><tr><td>Task Name7</td><td>Create By7</td></tr>
"

append out_table7 "</table>"
set out_table8 "
<table><tr><td>Task Name8</td><td>Create By8</td></tr>
"

append out_table8 "</table>"

set out_table9 "
<table><tr><td>Task Name9</td><td>Create By9</td></tr>
"

append out_table9 "</table>"
set out_table10 "
<table><tr><td>Task Name2</td><td>Create By10</td></tr>
"

append out_table10 "</table>"