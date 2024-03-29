ad_page_contract {
    Adding a user by an administrator

    @cvs-id $Id: user-add.tcl,v 1.3 2010/10/19 20:10:15 po34demo Exp $
} -query {
    {referer "/acs-admin/users"}
} -properties {
    context:onevalue
    export_vars:onevalue
}

set context [list [list "." "Users"] "Add user"]

set next_url user-add-2


set subsite_id [ad_conn subsite_id]
set user_new_template [parameter::get -parameter "UserNewTemplate" -package_id $subsite_id]

if {$user_new_template eq ""} {
    set user_new_template "/packages/acs-subsite/lib/user-new"
}
