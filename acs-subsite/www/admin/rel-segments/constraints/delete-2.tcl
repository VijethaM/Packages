# /packages/mbryzek-subsite/www/admin/rel-segments/constraints/delete-2.tcl

ad_page_contract {

    Deletes the specified constraint

    @author mbryzek@arsdigita.com
    @creation-date Fri Dec 15 11:27:27 2000
    @cvs-id $Id: delete-2.tcl,v 1.2 2010/10/19 20:12:29 po34demo Exp $

} {
    constraint_id:naturalnum,notnull
    { operation "" }
    { return_url "" }
}

ad_require_permission $constraint_id delete

set package_id [ad_conn package_id]

if {$operation eq "Yes, I really want to delete this constraint"} {

    if { $return_url eq "" } {
	# Redirect to the rel-segment page by default. 
	if { [db_0or1row select_segment_id {
	    select c.rel_segment as segment_id from rel_constraints c where c.constraint_id = :constraint_id
	}] } {
	    set return_url "../one?[ad_export_vars {segment_id}]"
	}
    }

    if { ![db_0or1row select_constraint_props {
	select 1
        from rel_constraints c, application_group_segments s,
             application_group_segments s2
	where c.rel_segment = s.segment_id
          and c.constraint_id = :constraint_id
          and s.package_id = :package_id
          and s2.segment_id = c.required_rel_segment
          and s2.package_id = :package_id
    }] } {
	# The constraint is already deleted or not in scope
	ad_returnredirect $return_url
        ad_script_abort
    }
    
    db_exec_plsql delete_constraint {
	begin rel_constraint.del(constraint_id => :constraint_id); end;
    }
    db_release_unused_handles

} elseif { $return_url eq "" } {
    # if we're not deleting, redirect to the constraint page
    set return_url one?[ad_export_vars constraint_id]
}


ad_returnredirect $return_url
