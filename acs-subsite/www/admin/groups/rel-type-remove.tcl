# /packages/mbryzek-subsite/www/admin/groups/rel-type-remove.tcl

ad_page_contract {

    Confirmation page to remove a given relationship type from the
    list of allowable ones. 

    @author mbryzek@arsdigita.com
    @creation-date Tue Jan  2 12:23:02 2001
    @cvs-id $Id: rel-type-remove.tcl,v 1.2 2010/10/19 20:12:26 po34demo Exp $

} {
    group_rel_id:integer,notnull
    { return_url "" }
} -properties {
    context:onevalue
    rel_pretty_name:onevalue
    group_name:onevalue
    export_vars:onevalue
}

if { ![db_0or1row select_info {
    select g.rel_type, g.group_id, acs_object.name(g.group_id) as group_name,
           t.pretty_name as rel_pretty_name
      from acs_object_types t, group_rels g
     where g.group_rel_id = :group_rel_id
       and t.object_type = g.rel_type
}] } {
    ad_return_error "Relation already removed." "Please back up and reload"
    return
}

ad_require_permission $group_id admin

set export_vars [ad_export_vars -form {group_rel_id return_url}]
set context [list [list "[ad_conn package_url]admin/groups/" "Groups"] [list one?[ad_export_vars {group_id}] "One group"] "Remove relation type"]

ad_return_template
