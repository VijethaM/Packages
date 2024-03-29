ad_page_contract {
    Redirect page for adding users to the permissions list.
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-06-13
    @cvs-id $Id: permissions-user-add.tcl,v 1.2 2010/10/19 20:12:22 po34demo Exp $
} {
    object_id:integer
}

set page_title "Add User"

set context [list [list "." "Applications"] [list "permissions" "[apm_instance_name_from_id $object_id] Permissions"] $page_title]

