# /packages/mbryzek-subsite/www/admin/rel-segments/constraints/index.tcl

ad_page_contract {

    Shows all constraints on which the user has read permission

    @author mbryzek@arsdigita.com
    @creation-date Fri Dec 15 11:30:52 2000
    @cvs-id $Id: index.tcl,v 1.2 2010/10/19 20:12:29 po34demo Exp $

}

set context [list [list ../ "Relational segments"] "Constraints"]

set user_id [ad_conn user_id]

set package_id [ad_conn package_id]

# Select out basic information about all the constraints on which the
# user has read permission

db_multirow constraints select_rel_constraints {
    select c.constraint_id, c.constraint_name
      from rel_constraints c, acs_object_party_privilege_map perm,
           application_group_segments s1, application_group_segments s2
     where perm.object_id = c.constraint_id
       and perm.party_id = :user_id
       and perm.privilege = 'read'
       and s1.segment_id = c.rel_segment
       and s1.package_id = :package_id
       and s2.segment_id = c.required_rel_segment
       and s2.package_id = :package_id
     order by lower(c.constraint_name)
}

ad_return_template
