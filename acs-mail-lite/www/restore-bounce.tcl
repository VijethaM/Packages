ad_page_contract {
    The page restores a user from the deleted state.
    @cvs-id $Id: restore-bounce.tcl,v 1.2 2010/10/19 23:55:15 po34demo Exp $
} {
    {return_url {[ad_pvt_home]}}
}

set page_title [_ acs-mail-lite.Restore_bounce]
set context [list [list [ad_pvt_home] [ad_pvt_home_name]] $page_title]

# We do require authentication, though their account will be closed
set user_id [auth::require_login]

db_dml unbounce_user "update users set email_bouncing_p = 'f' where user_id = :user_id"
# Used in a message key
set system_name [ad_system_name]
