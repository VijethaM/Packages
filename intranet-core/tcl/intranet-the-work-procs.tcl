# /packages/intranet-core/tcl/intranet-the-work-procs.tcl
#
# Copyright (c) 2007 ]project-open[
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

ad_library {
    Library related to Notifications

    @author Vijetha M (vijeth.m@venkatmangudi.com)
}

ad_proc -public im_the_work_component {
    {-user_id 0}
} {
    Returns a formatted HTML showing task list
    for the current user.
} {
    if {0 == $user_id} { set user_id [ad_get_user_id] }
    set return_url [im_url_with_query]
    set comp "my_tasks"
    set params [list \
		    [list comp $comp] \
		    
    ]
    # set params ""
  
    set result [ad_parse_template -params $params "/packages/notifications/www/proken_notifications/index"]
    return $result
}


ad_proc -public im_tasks_assigned_by_me_component {
    {-user_id 0}
} {
    Returns a formatted HTML showing task list
    for the current user.
} {
    if {0 == $user_id} { set user_id [ad_get_user_id] }
    set return_url [im_url_with_query]
    set comp "tasks_by_me"
    set params [list \
            [list comp $comp] \
            
    ]
  
    set result [ad_parse_template -params $params "/packages/notifications/www/proken_notifications/index"]
    return $result
}
