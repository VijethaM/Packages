# /packages/mbryzek-subsite/www/admin/rel-types/roles/delete-2.tcl

ad_page_contract {

    Deletes a role if there are no relationship types that use it

    @author mbryzek@arsdigita.com
    @creation-date Mon Dec 11 11:30:53 2000
    @cvs-id $Id: delete-2.tcl,v 1.2 2010/10/19 20:12:33 po34demo Exp $

} {
    role:notnull
    { operation "" }
    { return_url "" }
}


if {$operation eq "Yes, I really want to delete this role"} {
    db_transaction {
	if { [catch {db_exec_plsql drop_role {begin acs_rel_type.drop_role(:role);end;}} errmsg] } {
	    if { [db_string role_used_p {
		select case when exists (select 1 from acs_rel_types where role_one = :role or role_two = :role) then 1 else 0 end
		from dual
	    }] } {
		ad_return_complaint 1 "<li> The role \"$role\" is still in use. You must remove all relationship types that use this role before you can remove this role."
		return
	    } else {
		ad_return_error "Error deleting role" $errmsg
		return
	    }
	}
    }
}

ad_returnredirect $return_url
