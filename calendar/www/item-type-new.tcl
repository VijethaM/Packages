
ad_page_contract {

    Add an item type
    
    @author Ben Adida (ben@openforce.net)
    
    @creation-date Mar 16, 2002
    @cvs-id $Id: item-type-new.tcl,v 1.3 2010/10/21 13:06:52 po34demo Exp $
} {
    calendar_id:notnull
    type:notnull
}

# Permission check
ad_require_permission $calendar_id calendar_admin

# Add the type
calendar::item_type_new -calendar_id $calendar_id -type $type

ad_returnredirect "calendar-item-types?calendar_id=$calendar_id"


