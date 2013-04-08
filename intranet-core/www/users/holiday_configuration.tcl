# /packages/leave-management/www/index.tcl
#

ad_page_contract { 
    leave management screen for HR

    @author Iqbal Shirol from VMC (iqbal.shirol@venkatmangudi.com)
} {
   { work_day_id "" }
   { leave_year_id "" }
   { min_leave_id "" }
   { optional "" }
   { empl_id "" }
   { day1 "" }
   { month1 "" }
   { year1 "" }
   { location "" }
   { hol_date:array "" }
   { hol_name:array "" }
   { hol_type:array "" }
   { hol_date_old:array "" }
   { hol_name_old:array "" }
   { check1 "" }
   { hol_comment:array "" }
   { is_saved:integer 0 }
   { is_submitted:integer 0 }
   { comment "" }
   { is_saved1:integer 0 }
   { is_added:integer 0 }
   { is_submitted1:integer 0 }
   { is_edited:integer 0 }
    { is_added_from:integer 0 }
   { location_id "" }
   { ab "" }
   { sel1 "" }
   { sel2 "" }
   { is_saved2 "" }
   { is_saved3 "" }
   { ho_date:array "" }
   { ho_name:array "" }
   { ho_type:array "" }
   { ho_comment:array "" }
   { len "" }
   { yr1 "" }
   { ctr2 0}
   { eff_earn_date ""}
   { n_days ""}
   { lv_type ""}
   { sun 0}
   { mon 0}
   { tue 0}
   { wed 0}
   { thu 0}
   { fri 0}
   { sat 0}
   { min_lv_id ""}
   { lv_year_id ""}
}
# ---------------------------------------------------------------
# Security & Defaults
# ---------------------------------------------------------------
set user_id [ad_maybe_redirect_for_registration]
set current_user_id $user_id

# set menu_id [db_string menu "select menu_id from im_menus where package_name = 'leave-management' and label='leave-management1'"]
# set sub_navbar [im_sub_navbar $menu_id "" "" "" ""]

# set page_title "Leave Configuration"

set current_url [ns_conn url]
set page_title "Holiday List Configuration Screen"
set user_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
set today [lindex [split [ns_localsqltimestamp] " "] 0]
set todays_date [ns_localsqltimestamp]

set check ""
if {$optional=="opt"} {
set check "checked"
}


set holiday_list_html ""

array set mon1 {
                 01 {January}
                 02 {February}
                 03 {March}
                 04 {April}
                 05 {May}
                 06 {June}
                 07 {July}
                 08 {August}
                 09 {September}
                 10 {October}
                 11 {November}
                 12 {December}
                 }
# set current_year [db_string as "select to_char(sysdate,'YYYY') from dual" -default ""]
# set yrs "{ $current_year"
# for {set i 0} {$i < 10} {incr i} {
# 	set current_year [expr $current_year+1]
# 	append yrs " $current_year"
	
# }
# append yrs " }"
# ad_return_complaint 1 "$yrs"
 set yrs { 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037 2038 2039 2040}

if { $yr1=="" } { set yr1 [lindex [split $today "-"] 0] }

append holiday_list_html "
<table>
	<form name=\"holiday_form\" id=\"holiday_form\" method=get>
	<script type=\"text/javascript\" src=\"/intranet/datetimepicker_css.js\"></script>
	<script language=\"javascript\">
		function is_submit1()
		{
			document.holiday_form.is_saved3.value = 0;
			document.holiday_form.is_added_from.value = 0;
			document.holiday_form.is_submitted1.value = 1;
		}
		function is_edit()
		{
			document.holiday_form.is_edited.value = 1;
		}
		function is_add()
		{	
			document.holiday_form.is_added.value = 1;
		}
		function is_add_from()
		{	
			document.holiday_form.is_added_from.value = 1;	
		}
		function is_save2()
		{
			document.holiday_form.is_saved2.value = 1;
		}
		function is_save1()
		{
			document.holiday_form.is_saved1.value = 1;
		}
		function is_save3()
		{
			document.holiday_form.is_saved3.value = 1;
		}

	</script>
	
	<tr>
	</tr>
	<tr>
		<td align=left width=150 class=form-widget style=\"font-size: 10pt;\"><b>Year:</b>
		<select name=yr1>
                 "   
                 foreach yr $yrs {
                    set selec ""
                    if {$yr==$yr1} {set selec "selected"} 
						append holiday_list_html "    
                            <option value=$yr $selec>$yr</option>
                        "                                            
                }
append holiday_list_html "  

          </select>
        </td>
        <td align=left  width=250 class=form-widget style=\"font-size: 10pt;\"><b>Location :</b>
			[im_category_select -include_empty_p 0 "Intranet Office Location" location_id $location_id]
		</td>
		"

append holiday_list_html "

		<td>
		
		<input type=hidden id='is_submitted1' name='is_submitted1' value=0 /><input type=submit value='View holidays' onClick='is_submit1();' /></td></tr>
		"
#Mukesh@vmcpl07-feb2012 added default values for codes below
set year_flg [db_string yrf "select working_year from im_vmc_leave_config" -default 0]
set leave_year [db_string lyr "select category from im_categories where category_id = $year_flg" -default ""]
set start_leave_yr [lindex [split $leave_year "-"] 0]
set end_leave_yr [lindex [split $leave_year "-"] 1]
set yr [lindex [split $today "-"] 0]
#Mukesh@vmcpl07-feb2012 added default initialisation for start and end month type selection
set mon_start "01"
set start_yr $yr1
set mon_end "12"
set end_yr $yr1
#------------------------------------------------------------------------------------------
if { $start_leave_yr == "Jan" } {
	set mon_start "01"
	set start_yr $yr1
	set mon_end "12"
	set end_yr $yr1
	} elseif { $start_leave_yr == "Feb" } {
	set mon_start "02"
	set start_yr $yr1
	set mon_end "01"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Mar" } {
	set mon_start "03"
	set start_yr $yr1
	set mon_end "02"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Apr" } {
	set mon_start "04"
	set start_yr $yr1
	set mon_end "03"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "May" } {
	set mon_start "05"
	set start_yr $yr1
	set mon_end "04"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Jun" } {
	set mon_start "06"
	set start_yr $yr1
	set mon_end "05"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Jul" } {
	set mon_start "07"
	set start_yr $yr1
	set mon_end "06"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Aug" } {
	set mon_start "08"
	set start_yr $yr1
	set mon_end "07"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Sep" } {
	set mon_start "09"
	set start_yr $yr1
	set mon_end "08"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Oct" } {
	set mon_start "10"
	set start_yr $yr1
	set mon_end "09"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Nov" } {
	set mon_start "11"
	set start_yr $yr1
	set mon_end "10"
	set end_yr [expr $yr1 + 1]
	} elseif { $start_leave_yr == "Dec" } {
	set mon_start "12"
	set start_yr $yr1
	set mon_end "11"
	set end_yr [expr $yr1 + 1]
	} 

set start "$start_yr-$mon_start"
set end "$end_yr-$mon_end"
set start_date "01-$mon_start-$start_yr"
set end_date "31-$mon_end-$end_yr"
set st "$mon1($mon_start)  $start_yr"
set en "$mon1($mon_end)  $end_yr"
#Mukesh@vmcpl07-feb2012- Added default value for line below
set op_fix [db_string opf "select optional_fixed from im_vmc_leave_config" -default ""]

append holiday_list_html "
	
	<tr>
		<td colspan=3 align=center><b>Showing holidays from $st to $en</b></td>
	</tr>
	<tr class=rowtitle align=center>
		<td class=rowtitle align=center style=\"font-size: 10pt;\">Date</td>
		<td class=rowtitle align=center style=\"font-size: 10pt;\">Holiday Name</td>
	"
if { $op_fix=="yes" } {		
	append holiday_list_html "
		<td class=rowtitle align=center style=\"font-size: 10pt;\">Type</td>
		"
}
append holiday_list_html "
	<td class=rowtitle align=center style=\"font-size: 10pt;\">Comment</td>
	</tr>
"
if { $is_added_from!=1} {
	if { $is_added!=1 } {
		if {$is_edited != 1} {
			if { $is_submitted1==1 } {
				if { $location_id == ""} {
					#Mukesh@vmcpl07-feb2012-Added sql for sql given below
					set location_id [db_string loc "select min(category_id) from im_categories where category_type='Intranet Office Location'" -default 0]
				}
				set sql "
					select
						h.*,
						to_char(h.date,'DD-MM-YYYY') as day
					from
						im_vmc_holiday_list h
					where
						h.location_id = $location_id
						and to_char(h.date,'YYYY-MM')>='$start'
						and to_char(h.date,'YYYY-MM')<='$end'
					order by h.date
				"
				set bgcolor(1) " class=roweven"
				set bgcolor(0) " class=rowodd"
				set ctr 0
				db_foreach date $sql {

					append holiday_list_html "
						<tr $bgcolor([expr $ctr % 2])>
							<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$day</td>
							<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$holiday_name </td>
							"
					if { $op_fix=="yes" } {		
						append holiday_list_html "
							<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$type</td>
							"
						}
					append holiday_list_html "
							<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$comment</td>
						</tr>
						"
					incr ctr
				}
				append holiday_list_html "
					<tr></tr>
					<tr>
				        	<td align=left><input type=hidden id='is_added' name='is_added' value=0 /><input type=submit value='Add holiday' onClick='is_add();' /></td>
						<td><input type=hidden id='is_added_from' name='is_added_from' value=0 /><input type=submit value='Add from Previous Year' onClick='is_add_from();' />
						</td><td align=left><input type=hidden id='is_edited' name='is_edited' value=0 /><input type=submit value='Edit' onClick='is_edit();' /></td></tr>
				        	"
				#if {$ctr==0} {
				#append holiday_list_html "
				#	<td><input type=hidden id='is_added_from' name='is_added_from' value=0 /><input type=submit value='Add from Previous Year' onClick='is_add_from();' />
				#</td></tr>
				#	"
				#} else { append holiday_list_html "<td align=left><input type=hidden id='is_edited' name='is_edited' value=0 /><input type=submit value='Edit' onClick='is_edit();' /></td></tr>"}
			} else {
			if { $location_id == ""} {
			#Mukesh@vmcpl07-feb2012-Added sql for sql given below
			set location_id [db_string loc "select min(category_id) from im_categories where category_type='Intranet Office Location'" -default 0]
			}
			set sql "
				select
					h.*,
					to_char(h.date,'DD-MM-YYYY') as day,
					to_char(h.date,'DD-Mon-YYYY') as day1
				from
					im_vmc_holiday_list h
				where
					h.location_id = $location_id
					and to_char(h.date,'YYYY-MM')>='$start'
					and to_char(h.date,'YYYY-MM')<='$end'
				order by h.date
			"
			set bgcolor(1) " class=roweven"
			set bgcolor(0) " class=rowodd"
			set ctr 0
			db_foreach date $sql {

			if {[im_date_to_comp_date -date $day1]< $today} {
					set font_data "class=rowred"
				} else {
					set font_data "$bgcolor([expr $ctr%2])"
				}
			append holiday_list_html "
				<tr $font_data>
					<td $font_data align=center style=\"font-size: 10pt;\">$day1</td>
					<td $font_data align=center style=\"font-size: 10pt;\">$holiday_name</td>
					"
			if { $op_fix=="yes" } {		
			append holiday_list_html "
					<td $font_data align=center style=\"font-size: 10pt;\">$type</td>
					"
				}
			append holiday_list_html "
					<td $font_data align=center style=\"font-size: 10pt;\">$comment</td>
				</tr>
				"
				incr ctr
				incr ctr2
			}

			append holiday_list_html "
				<tr></tr>
				<tr>
			        	<td align=left><input type=hidden id='is_added' name='is_added' value=0 /><input type=submit value='Add holiday' onClick='is_add();' /></td>
					<!--<td><input type=hidden id='is_added_from' name='is_added_from' value=0 /><input type=submit value='Add from Previous Year' onClick='is_add_from();' />
					</td>--><td align=left><input type=hidden id='is_edited' name='is_edited' value=0 /><input type=submit value='Edit' onClick='is_edit();' /></td></tr>
			        	"
			#if {$ctr==0} {
			#append holiday_list_html "
			#	<td><input type=hidden id='is_added_from' name='is_added_from' value=0 /><input type=submit value='Add from Previous Year' onClick='is_add_from();' />
			#</td></tr>
			#	"
			#} else {append holiday_list_html "<td align=left><input type=hidden id='is_edited' name='is_edited' value=0 /><input type=submit value='Edit' onClick='is_edit();' /></td></tr>"}
			}
		}
	}
}
#ad_return_complaint 1 $is_added_from
if { $is_added!=1 } {
	if { $is_edited==1 } {
		set i 0
		set bgcolor(1) "class=roweven"
		set bgcolor(0) "class=rowodd"
		set ctr 0
		set m 0
		db_foreach ab "select h.*,to_char(h.date,'YYYY-MM-DD') as day, to_char(h.date,'DD-MM-YYYY') as day1 from im_vmc_holiday_list h where h.location_id=$location_id and to_char(h.date,'YYYY-MM')>='$start' and to_char(h.date,'YYYY-MM')<='$end' order by h.date" {
		if { $day < $today } {

			append holiday_list_html "
					<tr $bgcolor([expr $ctr % 2])>
						<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$day1</td>
						<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$holiday_name</td>
					"
			if { $op_fix=="yes" } {		
				append holiday_list_html "
					<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$type</td>
					"
			}
			append holiday_list_html "
					<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$comment</td>
					</tr>
					"	
			incr ctr
			incr m
		} else {
			append holiday_list_html "
				<tr>
					<!--<td align=center><input type=text size=10 name=hol_date.$i id=hol_date.$i value='$day1'></td>-->
						<td><script type=\"text/javascript\" src=\"/intranet/datetimepicker_css.js\"></script><input type=text size=10 id=hol_date.$i name=hol_date.$i value='$day1' readonly><a href=\"javascript:NewCssCal('hol_date.$i','DDMMYYYY','arrow')\" style=\"cursor:pointer\"><img src=\"/intranet/images/cal.gif\" border='0' width='20' height='20' alt=\"Pick a date\"></a> 
					<td align=center><input type=text size=25 name=hol_name.$i id=hol_name.$i value='$holiday_name'></td>
					"
			set hol_date_old.$i "$day"
			set hol_name_old.$i "$holiday_name "
	
			if { $op_fix=="yes" } {
				#Mukesh@vmcpl07-feb2012 added a default value for below sql
				set option [db_string op "select trim(type) from im_vmc_holiday_list where to_char(date,'YYYY-MM-DD')='$day' and location_id=$location_id" -default ""]
				set sel1 ""
				set sel2 ""
				if { "$option" == "Scheduled" } {
					set sel1 "selected"
					set sel2 ""
				} else {
					set sel2 "selected"
					set sel1 ""
				}
				append holiday_list_html "
						<td align=center>
					 		<select name='hol_type.$i'>
					 		"
				append holiday_list_html "	 		
							<option $sel1 value='Scheduled'> Scheduled </option>
							"
				append holiday_list_html "
							<option $sel2 value='Optional'> Optional </option>
							"
				append holiday_list_html "
					  		</select>
					  	 </td>
					  	 "
			}
			append holiday_list_html "
					<td align=center><input type=text size=25 name=hol_comment.$i id=hol_comment.$i value='$comment'></td>
				</tr>
			"

		}
		incr i
		}

		append holiday_list_html "
			<tr></tr>
			<tr>
				<td align=left><input type=hidden id='is_saved1' name='is_saved1' value=0 /><input type=hidden id='ab' name='ab' value=$m /><input type=hidden id='len' name='len' value=$i /><input type=submit value='Save holiday list' onClick='is_save1();' /></td>
				<td align=left><input type=submit value='Cancel' onClick='is_submit1();' /></td>
			</tr>
		"
	}
}

#------------------------------starting----------------is_added_from---------------------------------------------------------------------
#--vijetha@vmc on 09-feb-12----------to display holiday list from previous year----------------------------------------
if {$is_added_from==1} {
set i 0
set bgcolor(1) "class=roweven"
set bgcolor(0) "class=rowodd"
set ctr 0
set m 0
set start [expr [lindex [split $start "-"] 0]-1]-[lindex [split $start "-"] 1]
set end [expr [lindex [split $end "-"] 0]-1]-[lindex [split $end "-"] 1]
# ad_return_complaint 1 "$start $end"
db_foreach ab "select h.*,to_char(h.date,'YYYY-MM-DD') as day, to_char(h.date,'DD-Mon-YYYY') as day2 ,to_char((to_char(h.date,'DD-Mon-YYYY')::date +'1 year'::interval),'DD-MM-YYYY') as day1
 from im_vmc_holiday_list h where h.location_id=$location_id and to_char(h.date,'YYYY-MM')>='$start' and to_char(h.date,'YYYY-MM')<='$end' order by h.date" {



# if { $day < $today } {

# append holiday_list_html "
# 	<tr $bgcolor([expr $ctr % 2])>
# 		<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$day1</td>
# 		<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$holiday_name</td>
# 		"
# if { $op_fix=="yes" } {		
# append holiday_list_html "
# 		<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$type</td>
# 		"
# 		}
# append holiday_list_html "
# 		<td $bgcolor([expr $ctr % 2]) align=center style=\"font-size: 10pt;\">$comment</td>
# 	</tr>
# "	
# incr ctr
# incr m
# } else {
	append holiday_list_html "
		<tr>
			<td>
			<script type=\"text/javascript\" src=\"/intranet/datetimepicker_css.js\"></script>
			 <input type=text size=8 id=hol_date.$i name=hol_date.$i value='$day1' readonly><a href=\"javascript:NewCssCal('hol_date.$i','DDMMYYYY','arrow')\" style=\"cursor:pointer\"><img src=\"/intranet/images/cal.gif\" border='0' width='20' height='20' alt=\"Pick a date\"></a></td>
		
			<!--	<input type=text size=10 name=hol_date.$i id=hol_date.$i value='$day1'></td> -->
			<td align=center><input type=text size=25 name=hol_name.$i id=hol_name.$i value='$holiday_name'></td>
		"
	set hol_date_old.$i "$day"
	set hol_name_old.$i "$holiday_name "
	
if { $op_fix=="yes" } {
#Mukesh@vmcpl07-feb2012 added a default value for below sql
set option ""
set option [db_string op "select trim(type) from im_vmc_holiday_list where to_char(date,'YYYY-MM-DD')='$day' and location_id=$location_id" -default ""]
set sel1 ""
set sel2 ""


if { "$option" == "Scheduled" } {
	set sel1 "selected"
	set sel2 ""
} else {
	set sel2 "selected"
	set sel1 ""
}
append holiday_list_html "
		<td align=center>
	 		<select name='hol_type.$i'>
	 		"
append holiday_list_html "	 		
			<option value='Scheduled' $sel1 > Scheduled </option>
			"
append holiday_list_html "
			<option  value='Optional' $sel2 > Optional </option>
			"
append holiday_list_html "
          		</select>
          	 </td>
          	 "
          	 }
append holiday_list_html "
		<td align=center><input type=text size=25 name=hol_comment.$i id=hol_comment.$i value='$comment'></td>
	</tr>
"

# }
incr i
}

append holiday_list_html "
	<tr></tr>
	<tr>
		<td align=left><input type=hidden id='is_saved3' name='is_saved3' value=0 /><input type=hidden id='ab' name='ab' value=$m /><input type=hidden id='len' name='len' value=$i /><input type=submit value='Save holiday list' onClick='is_save3();' /></td>
		<td align=left><!-- <a href=/leave-management/ ><input type=button value=cancel></a> --><input type=submit value='Cancel' onClick='is_submit1();' /></td>
        </tr>
"


}

if { $is_added==1 } {
set sql "
	select
		h.*,
		to_char(h.date,'DD-MM-YYYY') as day
	from
		im_vmc_holiday_list h
	where
		h.location_id = $location_id
		and to_char(h.date,'YYYY-MM')>='$start'
		and to_char(h.date,'YYYY-MM')<='$end'
	order by h.date
"
set bgcolor(1) "class=roweven"
set bgcolor(0) "class=rowodd"
set ctr 0
db_foreach date $sql {

append holiday_list_html "
	<tr $bgcolor([expr $ctr % 2])>
		<td $bgcolor([expr $ctr % 2]) align=center>$day</td>
		<td $bgcolor([expr $ctr % 2]) align=center>$holiday_name</td>
		"
if { $op_fix=="yes" } {		
append holiday_list_html "
		<td $bgcolor([expr $ctr % 2]) align=center>$type</td>
		"
	}
append holiday_list_html "
		<td $bgcolor([expr $ctr % 2]) align=center>$comment</td>
	</tr>
	"
	incr ctr
}
for { set a 0 } { $a<10 } { incr a } {
append holiday_list_html "
	<tr>
		<!--<td align=center><input type=text size=10 name=ho_date.$a id=ho_date.$a value=''>-->
		<td><script type=\"text/javascript\" src=\"/intranet/datetimepicker_css.js\"></script><input type=text size=10 id=ho_date.$a name=ho_date.$a  readonly><a href=\"javascript:NewCssCal('ho_date.$a','DDMMYYYY','arrow')\" style=\"cursor:pointer\"><img src=\"/intranet/images/cal.gif\" border='0' width='20' height='20' alt=\"Pick a date\"></a>
</td>
		<td align=center><input type=text size=25 name=ho_name.$a id=ho_name.$a value=''></td>
		"
if { $op_fix=="yes" } {
append holiday_list_html "
		<td align=center>
	 		<select name='ho_type.$a'>	 		
			<option value='Scheduled'> Scheduled </option>
			<option value='Optional'> Optional </option>
          		</select>
          	 </td>
          	 "
          	 }
append holiday_list_html "
		<td align=center><input type=text size=25 name=ho_comment.$a id=ho_comment.$a value=''></td>
	</tr>
"

}
append holiday_list_html "
		<tr></tr>
		<tr>
			<td align=left><input type=hidden id='is_saved2' name='is_saved2' value=0 /><input type=submit value='Save holiday list' onClick='is_save2();' /></td>
			<td align=left><input type=submit value='Cancel' onClick='is_submitted1();' /></td>
		</tr>
		</table>

		"
}

		
if { $is_saved2 == 1 } {
for {set b 0} {$b<10} {incr b} {
	set f_ho_date1 $ho_date($b)
	set f_ho_name $ho_name($b)
	if { $op_fix=="yes" } {
	set f_ho_type $ho_type($b)
	}
	set f_ho_comment $ho_comment($b)
	
	if { $f_ho_date1!="" } {
	
	set d [lindex [split $f_ho_date1 "-"] 0]
	set m [lindex [split $f_ho_date1 "-"] 1]
	set y [lindex [split $f_ho_date1 "-"] 2]
	set f_ho_date "$y-$m-$d"
	
	set holiday_id [db_string hol "select category_id from im_categories where category='Holiday'" -default ""]
	
# ===========================================================
#	GETTING THE USERS BELONGING TO THE PARTICULAR LOCATION TO LINK THEIR TIMESHEET
# ===========================================================	
	set state [db_string stt "select category from im_categories where category_id=$location_id" -default ""]
	set office_ids [db_list off "select office_id from im_offices where address_state='$state'"]
	set office_ids [join $office_ids ","]
#mukesh@vmpl@07-feb2012 added code below to set office_ids to zero if null
	if {$office_ids==""} {
		set office_ids 0
	}
	set user_ids [db_list usd "select distinct object_id_two from acs_rels where object_id_one in ($office_ids)"]
	set user_ids [join $user_ids ","]
	set user_ids [split $user_ids ","]
	#Mukesh@vmcpl07-feb2012 added code below to change the date format for compairing
	if {[regexp {[0-3][0-9]\-[0-1][0-9]\-[0-9][0-9][0-9][0-9]} $f_ho_date] } {
		set day11 [lindex [split $f_ho_date "-"] 0]
		set month11 [lindex [split $f_ho_date "-"] 1]
		set year11 [lindex [split $f_ho_date "-"] 2]
		ad_return_complaint 1 "$day11-$month11-$year11"
		set f_ho_date "$year11-$month11-$day11"
	} 
	set holi_en_p [db_string sel "select count(*) from im_vmc_holiday_list where location_id=$location_id and date=:f_ho_date" -default 0]
	if { $f_ho_date<$today || ![regexp {[0-9][0-9][0-9][0-9]\-[0-1][0-9]\-[0-3][0-9]} $f_ho_date] } {
	ad_return_complaint 1 "The date $f_ho_date1 you have entered is already past or should be in DD-MM-YYYY format, Please go back and re-enter only the dates after $f_ho_date1"
	} elseif {$holi_en_p} {
		ad_return_complaint 1 "A holiday on same date is available please add holiday with other dates"
	} else {
	
	if { $op_fix=="yes" } {
		
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_ho_date',
											'$f_ho_name',
											'$f_ho_type',
											'$f_ho_comment'
										)
		"
		if { $f_ho_type=="Optional" } {
			set f_h "\(optional\)"
		} else {
			set f_h ""
		}
		foreach user $user_ids {
		set absence_id [db_nextval "acs_object_id_seq"]
		if {$f_h==""} {
			
			db_dml acs_object_insert "
				insert into acs_objects (
									object_id,
									object_type,
									creation_date,
									creation_user,
									security_inherit_p,
									last_modified
								) values (
									$absence_id,
									'im_user_absence',
									'$todays_date',
									'$user',
									'f',
									'$todays_date'
								)
			"
		}

		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_ho_date',
										'$f_ho_date',
										'$f_ho_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_ho_name $f_h',
										1
									)
		"
		}
		} else {
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_ho_date',
											'$f_ho_name',
											'',
											'$f_ho_comment'
										)
		"
		
		foreach user $user_ids {
		
		set absence_id [db_nextval "acs_object_id_seq"]
		db_dml acs_object_insert "
			insert into acs_objects (
								object_id,
								object_type,
								creation_date,
								creation_user,
								security_inherit_p,
								last_modified
							) values (
								$absence_id,
								'im_user_absence',
								'$todays_date',
								'$user',
								'f',
								'$todays_date'
							)
		"
		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_ho_date',
										'$f_ho_date',
										'$f_ho_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_ho_name ',
										1
									)
		"
		}
		}
}
}
}
ad_returnredirect "/intranet/users/holiday_configuration?yr1=$yr1&location_id=$location_id"
}




if { $is_saved1==1 } {

	db_dml delete_holiday_sql "
			delete 
				from 
					im_vmc_holiday_list
			where
				to_char(date,'YYYY-MM-DD')>'$todays_date'
				and location_id=$location_id
	"
	db_dml delete_user_absences_sql "
		delete
			from
		im_user_absences
			where
			to_char(start_date,'YYYY-MM-DD')>'$todays_date'
			and absence_type_id=75245
			and absence_status_id=1600

	"
for {set i $ab} {$i<$len} {incr i} {
	
	set f_hol_date $hol_date($i)
	set f_hol_name $hol_name($i)
	set f_hol_comment $hol_comment($i)

	if { $op_fix=="yes" } {
	set f_type $hol_type($i)
	}
	#set f_hol_date_old $hol_date_old($i)
	#set f_hol_name_old $hol_name_old($i)
	#ad_return_complaint 1 "$today"
	set holiday_id [db_string hol "select category_id from im_categories where category='Holiday'" -default ""]

	if {[regexp {[0-3][0-9]\-[0-1][0-9]\-[0-9][0-9][0-9][0-9]} $f_hol_date] } {
		set day11 [lindex [split $f_hol_date "-"] 0]
		set month11 [lindex [split $f_hol_date "-"] 1]
		set year11 [lindex [split $f_hol_date "-"] 2]
		
		set f_hol_date "$year11-$month11-$day11"
	}
	set holi_en_p [db_string sel "select count(*) from im_vmc_holiday_list where location_id=$location_id and date=:f_hol_date" -default 0]
	if { $f_hol_date<$today || ![regexp {[0-9][0-9][0-9][0-9]\-[0-1][0-9]\-[0-3][0-9]} $f_hol_date] } {
	ad_return_complaint 1 "The date $f_ho_date1 you have entered is already past or should be in DD-MM-YYYY format, Please go back and re-enter only the dates after $f_ho_date1"
	} elseif {$holi_en_p} {
		ad_return_complaint 1 "A holiday on same date is available please add holiday with other dates"
	} else {
 				
# ===========================================================
#	GETTING THE USERS BELONGING TO THE PARTICULAR LOCATION TO UPDATE THEIR TIMESHEET
# ===========================================================	
	set state [db_string stt "select category from im_categories where category_id=$location_id" -default ""]
	set office_ids [db_list off "select office_id from im_offices where address_state='$state'"]
	set office_ids [join $office_ids ","]
	#mukesh@vmpl@07-feb2012 added code below to set office_ids to zero if null
	if {$office_ids==""} {
		set office_ids 0
	}
	#-----------------------------------
	set user_ids [db_list usd "select distinct object_id_two from acs_rels where object_id_one in ($office_ids)"]
	set user_ids [join $user_ids ","]
	set user_ids [split $user_ids ","]
	
	if { $op_fix=="yes" } {
		
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_hol_date',
											'$f_hol_name',
											'$f_hol_type',
											'$f_hol_comment'
										)
		"
		if { $f_ho_type=="Optional" } {
			set f_h "\(optional\)"
		} else {
			set f_h ""
		}
		foreach user $user_ids {
		set absence_id [db_nextval "acs_object_id_seq"]
		if {$f_h==""} {
			
			db_dml acs_object_insert "
				insert into acs_objects (
									object_id,
									object_type,
									creation_date,
									creation_user,
									security_inherit_p,
									last_modified
								) values (
									$absence_id,
									'im_user_absence',
									'$todays_date',
									'$user',
									'f',
									'$todays_date'
								)
			"
		}

		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_hol_date',
										'$f_hol_date',
										'$f_hol_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_hol_name $f_h',
										1
									)
		"
		}
	} else {

		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_hol_date',
											'$f_hol_name',
											'',
											'$f_hol_comment'
										)
		"
		# ad_return_complaint 1 "$f_hol_date           $f_hol_name "
		foreach user $user_ids {
		
		set absence_id [db_nextval "acs_object_id_seq"]
		db_dml acs_object_insert "
			insert into acs_objects (
								object_id,
								object_type,
								creation_date,
								creation_user,
								security_inherit_p,
								last_modified
							) values (
								$absence_id,
								'im_user_absence',
								'$todays_date',
								'$user',
								'f',
								'$todays_date'
							)
		"
		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_hol_date',
										'$f_hol_date',
										'$f_hol_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_hol_name ',
										1
									)
		"
		}
		}
	# set f_hol_comment $hol_comment($i)
	# set val_date [db_string vd "select count(*) from im_vmc_holiday_list where to_char(date,'YYYY-MM-DD') = '$f_hol_date' and location_id = $location_id" -default ""]
	#  # ad_return_complaint 1 "$val_date"
	# set val_name [db_string vd "select count(*) from im_vmc_holiday_list where holiday_name = '$f_hol_name' and location_id = $location_id" -default ""]

	# if { $val_date!="" } {
	# 	if { $op_fix=="yes" } {
	# 		if { $f_type=="Optional" } {
	# 				set f_h "\(optional\)"
	# 			} else {
	# 				set f_h ""
	# 			}
			
	# 		db_dml hol_update "
	# 				update im_vmc_holiday_list set holiday_name = '$f_hol_name',
	# 										type = '$f_type',
	# 										comment = '$f_hol_comment'
	# 									where
	# 										to_char(date,'YYYY-MM-DD')='$f_hol_date'
	# 										and location_id = $location_id
	# 				"
				
	# 		foreach user $user_ids {
	# 		db_dml absence_update "
	# 				update im_user_absences set absence_name = '$f_hol_name $f_h',
	# 										last_modified = '$todays_date',
	# 										description = '$f_hol_comment'
	# 									where
	# 										owner_id = $user
	# 										and start_date = '$f_hol_date'
	# 				"
	# 				}
	# 			} else {
	# 	db_dml hol_update "
	# 			update im_vmc_holiday_list set holiday_name = '$f_hol_name',
	# 									type = '',
	# 									comment = '$f_hol_comment'
	# 								where
	# 									to_char(date,'YYYY-MM-DD')='$f_hol_date'
	# 									and location_id = $location_id
	# 			"
	#    # ad_return_complaint 1 "update im_vmc_holiday_list set holiday_name = '$f_hol_name',
	# 			# 						type = '',
	# 			# 						comment = '$f_hol_comment'
	# 			# 					where
	# 			# 						to_char(date,'YYYY-MM-DD')='$f_hol_date'
	# 			# 						and location_id = $location_id"
	# 	foreach user $user_ids {
	# 	db_dml absence_update "
	# 			update im_user_absences set absence_name = '$f_hol_name',
	# 									last_modified = '$todays_date',
	# 									description = '$f_hol_comment'
	# 								where
	# 									owner_id = $user
	# 									and start_date = '$f_hol_date'
	# 			"
	# 			}
	# 			}
	# } elseif { $val_name!="" } {
	# if { $op_fix=="yes" } {
	# 	db_dml hol_update1 "
	# 			update im_vmc_holiday_list set date = '$f_hol_date',
	# 									type = '$f_type',
	# 									comment = '$f_hol_comment'
	# 								where
	# 									holiday_name='$f_hol_name'
	# 									and location_id = $location_id
	# 			"
	# 	foreach user $user_ids {
	# 	db_dml absence_update "
	# 			update im_user_absences set start_date = '$f_hol_date',
	# 									end_date = '$f_hol_date',
	# 									last_modified = '$todays_date',
	# 									description = '$f_hol_comment'
	# 								where
	# 									owner_id = $user
	# 									and absence_name like '%$f_hol_name%'
	# 			"
	# 			}
	# 			} else {
	# 	db_dml hol_update1 "
	# 			update im_vmc_holiday_list set date = '$f_hol_date',
	# 									type = '',
	# 									comment = '$f_hol_comment'
	# 								where
	# 									holiday_name='$f_hol_name'
	# 									and location_id = $location_id
	# 			"
	# 	foreach user $user_ids {
	# 	db_dml absence_update "
	# 			update im_user_absences set start_date = '$f_hol_date',
	# 									end_date = '$f_hol_date',
	# 									last_modified = '$todays_date',
	# 									description = '$f_hol_comment'
	# 								where
	# 									owner_id = $user
	# 									and absence_name like '%$f_hol_name%'
	# 			"
	# 			}
	# 			}
	# }
}
}
ad_returnredirect "/intranet/users/holiday_configuration?yr1=$yr1&location_id=$location_id"
}


#------------------------------------is_saved3()----------------------------------------------------
#------------------vijetha@vmc on 09-feb-12 ----to save holiday list which are taken from previous year--------------------------
if { $is_saved3==1 } {
	
#-----------------
for {set i 0} {$i<$len} {incr i} {
	set f_ho_date1 $hol_date($i)
	set f_ho_name $hol_name($i)
	if { $op_fix=="yes" } {
	set f_ho_type $hol_type($i)
	}
	set f_ho_comment $hol_comment($i)
	#set f_hol_date_old $hol_date_old($i)
	#set f_hol_name_old $hol_name_old($i)
	#ad_return_complaint 1 "$today"
if { $f_ho_date1!="" } {
	
	set d [lindex [split $f_ho_date1 "-"] 0]
	set m [lindex [split $f_ho_date1 "-"] 1]
	set y [lindex [split $f_ho_date1 "-"] 2]
	set f_ho_date "$y-$m-$d"
	
	set holiday_id [db_string hol "select category_id from im_categories where category='Holiday'" -default ""]
	
# ===========================================================
#	GETTING THE USERS BELONGING TO THE PARTICULAR LOCATION TO LINK THEIR TIMESHEET
# ===========================================================	
	set state [db_string stt "select category from im_categories where category_id=$location_id" -default ""]
	set office_ids [db_list off "select office_id from im_offices where address_state='$state'"]
	set office_ids [join $office_ids ","]
#mukesh@vmpl@07-feb2012 added code below to set office_ids to zero if null
	if {$office_ids==""} {
		set office_ids 0
	}
	set user_ids [db_list usd "select distinct object_id_two from acs_rels where object_id_one in ($office_ids)"]
	set user_ids [join $user_ids ","]
	set user_ids [split $user_ids ","]
	#Mukesh@vmcpl07-feb2012 added code below to change the date format for compairing
	if {[regexp {[0-3][0-9]\-[0-1][0-9]\-[0-9][0-9][0-9][0-9]} $f_ho_date] } {
		set day11 [lindex [split $f_ho_date "-"] 0]
		set month11 [lindex [split $f_ho_date "-"] 1]
		set year11 [lindex [split $f_ho_date "-"] 2]
		ad_return_complaint 1 "$day11-$month11-$year11"
		set f_ho_date "$year11-$month11-$day11"
	} 
	set holi_en_p [db_string sel "select count(*) from im_vmc_holiday_list where location_id=$location_id and date=:f_ho_date" -default 0]
	if { $f_ho_date<$today || ![regexp {[0-9][0-9][0-9][0-9]\-[0-1][0-9]\-[0-3][0-9]} $f_ho_date] } {
	ad_return_complaint 1 "The date $f_ho_date1 you have entered is already past or should be in DD-MM-YYYY format, Please go back and re-enter only the dates after $f_ho_date1"
	} elseif {$holi_en_p} {
		ad_return_complaint 1 "A holiday on same date is available please add holiday with other dates"
	} else {
	
	if { $op_fix=="yes" } {
		
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_ho_date',
											'$f_ho_name',
											'$f_ho_type',
											'$f_ho_comment'
										)
		"
		if { $f_ho_type=="Optional" } {
			set f_h "\(optional\)"
		} else {
			set f_h ""
		}
		foreach user $user_ids {
		set absence_id [db_nextval "acs_object_id_seq"]
		if {$f_h==""} {
			
			db_dml acs_object_insert "
				insert into acs_objects (
									object_id,
									object_type,
									creation_date,
									creation_user,
									security_inherit_p,
									last_modified
								) values (
									$absence_id,
									'im_user_absence',
									'$todays_date',
									'$user',
									'f',
									'$todays_date'
								)
			"
		}

		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_ho_date',
										'$f_ho_date',
										'$f_ho_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_ho_name $f_h',
										1
									)
		"
		}
		} else {
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_ho_date',
											'$f_ho_name',
											'',
											'$f_ho_comment'
										)
		"
		
		foreach user $user_ids {
		
		set absence_id [db_nextval "acs_object_id_seq"]
		db_dml acs_object_insert "
			insert into acs_objects (
								object_id,
								object_type,
								creation_date,
								creation_user,
								security_inherit_p,
								last_modified
							) values (
								$absence_id,
								'im_user_absence',
								'$todays_date',
								'$user',
								'f',
								'$todays_date'
							)
		"
		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_ho_date',
										'$f_ho_date',
										'$f_ho_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_ho_name ',
										1
									)
		"
		}
		}
}
}
}
ad_returnredirect "/intranet/users/holiday_configuration?yr1=$yr1&location_id=$location_id"
}




# if { $is_saved1==1 } {
# for {set i $ab} {$i<$len} {incr i} {
# 	set f_hol_date $hol_date($i)
# 	set f_hol_name $hol_name($i)
# 	if { $op_fix=="yes" } {
# 	set f_type $hol_type($i)
# 	}
# 	#set f_hol_date_old $hol_date_old($i)
# 	#set f_hol_name_old $hol_name_old($i)
# 	#ad_return_complaint 1 "$today"
# 	if {[regexp {[0-3][0-9]\-[0-1][0-9]\-[0-9][0-9][0-9][0-9]} $f_hol_date] } {
# 		set day11 [lindex [split $f_hol_date "-"] 0]
# 		set month11 [lindex [split $f_hol_date "-"] 1]
# 		set year11 [lindex [split $f_hol_date "-"] 2]
		
# 		set f_hol_date "$year11-$month11-$day11"
# 	}
	
# 	if { $f_hol_date<$today || ![regexp {[0-9][0-9][0-9][0-9]\-[0-1][0-9]\-[0-3][0-9]} $f_hol_date] } {
# 	ad_return_complaint 1 "The date $f_hol_date you have entered is already past or should be in YYYY-MM-DD format, Please go back and re-enter only the dates after $f_hol_date"
# 	} else {
	
# # ===========================================================
# #	GETTING THE USERS BELONGING TO THE PARTICULAR LOCATION TO UPDATE THEIR TIMESHEET
# # ===========================================================	
# 	set state [db_string stt "select category from im_categories where category_id=$location_id" -default ""]
# 	set office_ids [db_list off "select office_id from im_offices where address_state='$state'"]
# 	set office_ids [join $office_ids ","]
# 	#mukesh@vmpl@07-feb2012 added code below to set office_ids to zero if null
# 	if {$office_ids==""} {
# 		set office_ids 0
# 	}
# 	#-----------------------------------
# 	set user_ids [db_list usd "select distinct object_id_two from acs_rels where object_id_one in ($office_ids)"]
# 	set user_ids [join $user_ids ","]
# 	set user_ids [split $user_ids ","]
	
	
# 	set f_hol_comment $hol_comment($i)
# 	set val_date [db_string vd "select count(*) from im_vmc_holiday_list where to_char(date,'DD-MM-YYYY') = '$f_hol_date' and location_id = $location_id" -default ""]
# 	set val_name [db_string vd "select count(*) from im_vmc_holiday_list where holiday_name = '$f_hol_name' and location_id = $location_id" -default ""]

# 	if { $val_date!="" } {
# 	if { $op_fix=="yes" } {
# 	if { $f_type=="Optional" } {
# 			set f_h "\(optional\)"
# 		} else {
# 			set f_h ""
# 		}
		
# 		db_dml hol_update "
# 				update im_vmc_holiday_lisVMC0nsulting
# 				 set holiday_name = '$f_hol_name',
# 										type = '$f_type',
# 										comment = '$f_hol_comment'
# 									where
# 										to_char(date,'YYYY-MM-DD')='$f_hol_date'
# 										and location_id = $location_id
# 				"

# 		foreach user $user_ids {
# 		db_dml absence_update "
# 				update im_user_absences set absence_name = '$f_hol_name $f_h',
# 										last_modified = '$todays_date',
# 										description = '$f_hol_comment'
# 									where
# 										owner_id = $user
# 										and start_date = '$f_hol_date'
# 				"
# 				}
# 				} else {
# 		db_dml hol_update "
# 				update im_vmc_holiday_list set holiday_name = '$f_hol_name',
# 										type = '',
# 										comment = '$f_hol_comment'
# 									where
# 										to_char(date,'YYYY-MM-DD')='$f_hol_date'
# 										and location_id = $location_id
# 				"
# 		foreach user $user_ids {
# 		db_dml absence_update "
# 				update im_user_absences set absence_name = '$f_hol_name',
# 										last_modified = '$todays_date',
# 										description = '$f_hol_comment'
# 									where
# 										owner_id = $user
# 										and start_date = '$f_hol_date'
# 				"
# 				}
# 				}
# 	} 
# 	if { $val_name!="" } {
# 	if { $op_fix=="yes" } {
# 		db_dml hol_update1 "
# 				update im_vmc_holiday_list set date = '$f_hol_date',
# 										type = '$f_type',
# 										comment = '$f_hol_comment'
# 									where
# 										holiday_name='$f_hol_name'
# 										and location_id = $location_id
# 				"
# 		foreach user $user_ids {
# 		db_dml absence_update "
# 				update im_user_absences set start_date = '$f_hol_date',
# 										end_date = '$f_hol_date',
# 										last_modified = '$todays_date',
# 										description = '$f_hol_comment'
# 									where
# 										owner_id = $user
# 										and absence_name like '%$f_hol_name%'
# 				"
# 				}
# 				} else {
# 		db_dml hol_update1 "
# 				update im_vmc_holiday_list set date = '$f_hol_date',
# 										type = '',
# 										comment = '$f_hol_comment'
# 									where
# 										holiday_name='$f_hol_name'
# 										and location_id = $location_id
# 				"
# 		foreach user $user_ids {
# 		db_dml absence_update "
# 				update im_user_absences set start_date = '$f_hol_date',
# 										end_date = '$f_hol_date',
# 										last_modified = '$todays_date',
# 										description = '$f_hol_comment'
# 									where
# 										owner_id = $user
# 										and absence_name like '%$f_hol_name%'
# 				"
# 				}
# 				}
# 	}
# }
# }
# ad_returnredirect "/intranet/users/holiday_configuration"
# }


#------------------------------------is_saved3()----------------------------------------------------
#------------------vijetha@vmc on 09-feb-12 ----to save holiday list which are taken from previous year--------------------------
if { $is_saved3==1 } {
	
#-----------------
for {set i $ab} {$i<$len} {incr i} {
	set f_ho_date1 $hol_date($i)
	set f_ho_name $hol_name($i)
	if { $op_fix=="yes" } {
	set f_ho_type $hol_type($i)
	}
	set f_ho_comment $hol_comment($i)
	#set f_hol_date_old $hol_date_old($i)
	#set f_hol_name_old $hol_name_old($i)
	#ad_return_complaint 1 "$today"
if { $f_ho_date1!="" } {
	
	set d [lindex [split $f_ho_date1 "-"] 0]
	set m [lindex [split $f_ho_date1 "-"] 1]
	set y [lindex [split $f_ho_date1 "-"] 2]
	set f_ho_date "$y-$m-$d"
	
	set holiday_id [db_string hol "select category_id from im_categories where category='Holiday'" -default ""]
	
# ===========================================================
#	GETTING THE USERS BELONGING TO THE PARTICULAR LOCATION TO LINK THEIR TIMESHEET
# ===========================================================	
	set state [db_string stt "select category from im_categories where category_id=$location_id" -default ""]
	set office_ids [db_list off "select office_id from im_offices where address_state='$state'"]
	set office_ids [join $office_ids ","]
#mukesh@vmpl@07-feb2012 added code below to set office_ids to zero if null
	if {$office_ids==""} {
		set office_ids 0
	}
	set user_ids [db_list usd "select distinct object_id_two from acs_rels where object_id_one in ($office_ids)"]
	set user_ids [join $user_ids ","]
	set user_ids [split $user_ids ","]
	#Mukesh@vmcpl07-feb2012 added code below to change the date format for compairing
	if {[regexp {[0-3][0-9]\-[0-1][0-9]\-[0-9][0-9][0-9][0-9]} $f_ho_date] } {
		set day11 [lindex [split $f_ho_date "-"] 0]
		set month11 [lindex [split $f_ho_date "-"] 1]
		set year11 [lindex [split $f_ho_date "-"] 2]
		ad_return_complaint 1 "$day11-$month11-$year11"
		set f_ho_date "$year11-$month11-$day11"
	} 
	set holi_en_p [db_string sel "select count(*) from im_vmc_holiday_list where location_id=$location_id and date=:f_ho_date" -default 0]
	if { $f_ho_date<$today || ![regexp {[0-9][0-9][0-9][0-9]\-[0-1][0-9]\-[0-3][0-9]} $f_ho_date] } {
	ad_return_complaint 1 "The date $f_ho_date1 you have entered is already past or should be in DD-MM-YYYY format, Please go back and re-enter only the dates after $f_ho_date1"
	} elseif {$holi_en_p} {
		ad_return_complaint 1 "A holiday on same date is available please add holiday with other dates"
	} else {
	
	if { $op_fix=="yes" } {
		
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_ho_date',
											'$f_ho_name',
											'$f_ho_type',
											'$f_ho_comment'
										)
		"
		if { $f_ho_type=="Optional" } {
			set f_h "\(optional\)"
		} else {
			set f_h ""
		}
		foreach user $user_ids {
		
		set absence_id [db_nextval "acs_object_id_seq"]
		db_dml acs_object_insert "
			insert into acs_objects (
								object_id,
								object_type,
								creation_date,
								creation_user,
								security_inherit_p,
								last_modified
							) values (
								$absence_id,
								'im_user_absence',
								'$todays_date',
								'$user',
								'f',
								'$todays_date'
							)
		"

		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_ho_date',
										'$f_ho_date',
										'$f_ho_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_ho_name $f_h',
										1
									)
		"
		}
		} else {
		db_dml hol_insert "
				insert into im_vmc_holiday_list (
											location_id,
											date,
											holiday_name,
											type,
											comment
										) values (
											$location_id,
											'$f_ho_date',
											'$f_ho_name',
											'',
											'$f_ho_comment'
										)
		"
		
		foreach user $user_ids {
		
		set absence_id [db_nextval "acs_object_id_seq"]
		db_dml acs_object_insert "
			insert into acs_objects (
								object_id,
								object_type,
								creation_date,
								creation_user,
								security_inherit_p,
								last_modified
							) values (
								$absence_id,
								'im_user_absence',
								'$todays_date',
								'$user',
								'f',
								'$todays_date'
							)
		"
		db_dml holiday_insert "
			insert into im_user_absences (
										absence_id,
										owner_id,
										start_date,
										end_date,
										description,
										last_modified,
										absence_type_id,
										absence_status_id,
										absence_name,
										duration_days
									) values (
										$absence_id,
										$user,
										'$f_ho_date',
										'$f_ho_date',
										'$f_ho_comment',
										'$todays_date',
										$holiday_id,
										16000,
										'$f_ho_name ',
										1
									)
		"
		}
		}
}
}
}
ad_returnredirect "/intranet/users/holiday_configuration?yr1=$yr1&location_id=$location_id"
}
#-----------------------------End of is_save3()--------------------------------------

append holiday_list_html "
	</form>
"

