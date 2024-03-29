ad_page_contract {
    Page for users to register themselves on the site.

    @cvs-id $Id: home.tcl,v 1.2 2010/10/19 20:12:41 po34demo Exp $
} {

}

set user_id [auth::require_login -account_status closed]
set page_title [ad_pvt_home_name]
set context [list $page_title]

set subsite_id [ad_conn subsite_id]
set user_home_template [parameter::get -parameter "UserHomeTemplate" -package_id $subsite_id]

if {$user_home_template eq ""} {
    set user_home_template "/packages/acs-subsite/lib/home"
}