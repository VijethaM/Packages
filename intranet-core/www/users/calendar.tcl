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
   { date "" }
   {user_id  0}
}

#     if  {![info exists tot_d($user_id-$x)] } {
#         
#      }
#     # set html "Notifications for You..................====$user_id"
#     ns_log Notice "vijetha123 ======= $user_id"
#    # set return_url [im_url_with_query]
#     # set date [db_string sel "select to_char(current_date,'YYYY-MM-DD') from dual" -default ""]
#    set params ""
#    set result [ad_parse_template -params $params "/packages/intranet-core/www/users/calendar"]
#    return $result
 # set user_id1 [ad_get_user_id]
if {$user_id==0} {
    set user_id [ad_get_user_id]
}
if {$date==""} {
    set date [db_string dt "select to_char(sysdate,'YYYY-MM-DD') from dual"]
}
set date_j [db_string dt "select to_char($date,'J') from dual"]

calendar_get_info_from_db $date

set calendar_html "
<style type=\"text/css\">
.overdue {
    background: none repeat scroll 0 0 #D2141E;
    border: 1px solid #FFFFFF;
    color: #FFFFFF;
    
    padding: 2px;
    text-align: left;
}
.inprogress {
    background: none repeat scroll 0 0 #4BC33C;
    border: 1px solid #FFFFFF;
    color: #000000;
   
    padding: 2px;
    text-align: left;
}
.completed {
    background: none repeat scroll 0 0 #CCCCCC;
    border: 1px solid #FFFFFF;
    
    color: #000000;
    padding: 2px;
    text-align: left;
}
.notasks {
   height:70px;
   width:100%;
    padding: 3px;
    text-align: right;
    vertical-align: top;;
}
.yettostart {
    background: none repeat scroll 0 0 #98FB98;
    border: 1px solid #FFFFFF;
    color: #000000;
    
    padding: 2px;
    text-align: left;
}
</style>



"






set calendar_details [ns_set create calendar_details]

for { set current_date $first_julian_date} { $current_date <= $last_julian_date } { incr current_date } {
 

set crt_date [db_string ds "select to_date(:current_date,'J') from dual"]
# ns_log Notice "nikhil123456:$crt_date ---------- "
set task_list_sql "
    select p.start_date, p.end_date, 
        im_name_from_id(r.object_id_two),
        im_project_name_from_id(r.object_id_one) as project_name, 
        substring(im_project_name_from_id(r.object_id_one),1,10) as sub_name,
        im_category_from_id(p.project_status_id) as status,
        to_char(p.end_date,'J') as end_date,
        im_project_name_from_id(p.parent_id) as parent_name
    from 
        acs_rels r,im_projects p
    where 
        p.project_id =r.object_id_one 
        and r.rel_type='im_biz_object_member' 
        and r.object_id_two=$user_id 
        and im_project_name_from_id(r.object_id_one) is not null and (to_timestamp('$crt_date','yyyy-mm-dd') between p.start_date and p.end_date)
        and p.parent_id is not null    
 "
 # ad_return_complaint 1 "nikhil123456: $task_list_sql "

set count 0
set count1 0
set shw_html ""
set shw_html1 ""
set task_lit  ""
db_foreach tsk_lst $task_list_sql {
    ns_log Notice "nikhil123456:$crt_date ---------- $project_name $status"
    set task_tip "$project_name--$parent_name"
    # sad_return_complaint 1 "$status . . $project_name"
    if {$status=="Closed"} {
        set class "completed"
    } elseif {$status=="Work In Progress" ||$status=="Open"} {
        set class "inprogress"
    } elseif {$status=="Work In Progress" && {$end_date>=$current_date} } {
        set class "overdue"
    } elseif {$status=="Yet To Start"} {
        set class "yettostart"
    }
    if {$count<=3} {
        append shw_html "
            <div class=\"$class\" title=\"$task_tip\"> <b>$sub_name..</b></div>\n

        "
        incr count
    } else {
        append task_lit "$task_tip\n"
        incr count1
        # ns_log Notice "nikhil123:$task_list"

    }
}

if {$count1>=1} {
    append shw_html1 "
        <div class=\"completed\" title=\"$task_lit\"> <b>$count1 more..</b></div>

    "
}

if {$shw_html1!=""} {
    set show_html "$shw_html $shw_html1"
} else {
    set show_html "$shw_html"
}
    
if {$show_html==""} {
    set show_html "<div class=\"notasks\"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></div>"
}





    set current_date_ansi [db_string julian_date_select "select to_char( to_date(:current_date,'J'), 'YYYY-MM-DD') from dual"]

    # ns_set put $calendar_details $current_date "<div class=\"overdue\" title=\"Client Briefing..$user_id\"> <b>Client Br..</b> </div>\n<div class=\"inprogress\" title=\"Client Briefing\"><b> Client Br..</b></div>\n<div class=\"completed\" title=\"Client Briefing\"> <b>Client Br.. </b></div>\n<div class=\"completed\" title=\"Client Briefing\"><b> Client Bri..</b> </div>\n<div class=\"completed\" title=\"Client Briefing\nTask001\nTask1002\nTask003\nTask004\nTask006\"><b>2 more.. </b></div>"
    ns_set put $calendar_details $current_date "$show_html"

}






set prev_month_template "
<font color=#414042>&lt;</font> 
<a href=\"?user_id=$user_id&date=\$ansi_date\">
  <font color=#414042>\$prev_month_name</font>
</a>"
set next_month_template "
<a href=\"?user_id=$user_id&date=\$ansi_date&\">
  <font color=#414042>\$next_month_name</font>
</a> 
<font color=#414042>&gt;</font>"
set day_bgcolor "#F0F5F7"
set day_number_template "<!--\$julian_date--><span class='day_number'>\$day_number</span>"

set page_body [calendar_basic_month \
    -calendar_details $calendar_details \
    -days_of_week "[_ intranet-timesheet2.Monday] [_ intranet-timesheet2.Tuesday] [_ intranet-timesheet2.Wednesday] [_ intranet-timesheet2.Thursday] [_ intranet-timesheet2.Friday] [_ intranet-timesheet2.Saturday] [_ intranet-timesheet2.Sunday] " \
    -next_month_template $next_month_template \
    -prev_month_template $prev_month_template \
    -day_number_template $day_number_template \
    -day_bgcolor $day_bgcolor \
    -header_bgcolor "#FFF8DC"\
    -master_bgcolor "#FAEBD7"\
    -today_bgcolor "#DEF1F8"\
    -date $date \
    -prev_next_links_in_title 1 \
    -fill_all_days 1 \
    -empty_bgcolor "#cccccc" \
    -flag 1]


set cal_info "
<br>
<table >
<tbody>
<tr>
<td width=\"10\"> </td>
<td nowrap=\"nowrap\" style=\"background-color:#d2141e\"> &nbsp;&nbsp;   </td>
<td width=\"65\" nowrap=\"nowrap\">
<b>Overdue </b>
</td>
<td nowrap=\"nowrap\" style=\"background-color:#4bc33c\">&nbsp;&nbsp;    </td>
<td width=\"75\" nowrap=\"nowrap\">
<b>In Progress </b>
</td>
<td nowrap=\"nowrap\" style=\"background-color:#ccc\">&nbsp;&nbsp;    </td>
<td width=\"75\" nowrap=\"nowrap\">
<b>Completed </b>
</td>
<td nowrap=\"nowrap\" style=\"background-color:#98FB98\">&nbsp;&nbsp;    </td>
<td width=\"75\" nowrap=\"nowrap\">
<b>Yet To Start </b>
</td>
</tr>
</tbody>
</table>

"

