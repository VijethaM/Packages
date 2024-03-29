ad_page_contract {
    go to a URL

    @author Ben Adida (ben@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id: url-goto.tcl,v 1.1.1.1 2010/10/20 02:02:59 po34demo Exp $
} {
    url_id:notnull
} 

# Check for read permission on this url
ad_require_permission $url_id read

# Check the URL
set url [db_string select_url {} -default {}]

if {![empty_string_p $url]} {
    ad_returnredirect $url
} else {
    return -code error [_ file-storage.no_such_URL]
}
