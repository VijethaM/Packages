# /packages/calendar/www/cal-item.tcl

ad_page_contract {
    
    Output an item as ics for Outlook
    
    @author Ben Adida (ben@openforce.net)
    @creation-date May 28, 2002
    @cvs-id $Id: cal-item-outlook.tcl,v 1.3 2010/10/21 13:06:51 po34demo Exp $
} {
    cal_item_id:integer
}

ad_returnredirect "ics/${cal_item_id}.ics"
