# /packages/acs-subsite/www/admin/groups/elements-display.tcl

ad_page_contract {

    Displays all elements in a group with a specified rel_type

    @author mbryzek@arsdigita.com
    @creation-date Mon Jan  8 14:01:48 2001
    @cvs-id $Id: elements-display.tcl,v 1.2 2010/10/19 20:12:26 po34demo Exp $

} {
    group_id:integer,notnull
    rel_type:notnull
    {member_state ""}
} -properties {
    context:onevalue
    create_p:onevalue
    group_id:onevalue
    group_name:onevalue
    role_pretty_plural:onevalue
    create_p:onevalue
    rel_type_enc:onevalue
    return_url_enc:onevalue
    member_state:onevalue
    possible_member_states:multirow
    ancestor_rel_type:onevalue
} -validate {
    groups_exists_p -requires {group_id:notnull} {
	if { ![group::permission_p $group_id] } {
	    ad_complain "The group either does not exist or you do not have permission to view it"
	}
    }
}

set user_id [ad_conn user_id]
set create_p [ad_permission_p -user_id $user_id $group_id "create"]
set return_url_enc [ad_urlencode "[ad_conn url]?[ad_conn query]"]
set rel_type_enc [ad_urlencode $rel_type]

# Select out the group name and the group's object type. Note we can
# use 1row because the validate filter above will catch missing groups

db_1row group_and_rel_info {
    select acs_group.name(:group_id) as group_name,
           acs_object_type.pretty_name(:rel_type) as rel_type_pretty_name,
           acs_rel_type.role_pretty_plural(rel_types.role_two) as role_pretty_plural,
           acs_rel_type.role_pretty_name(rel_types.role_two) as role_pretty_name
      from acs_rel_types rel_types
     where rel_types.rel_type = :rel_type
}

# The role pretty names can be message catalog keys that need
# to be localized before they are displayed
set role_pretty_name [lang::util::localize $role_pretty_name]
set role_pretty_plural [lang::util::localize $role_pretty_plural]    

set context [list [list "[ad_conn package_url]admin/groups/" "Groups"] [list one?[ad_export_vars group_id] "One Group"] "All $role_pretty_plural"]

ad_return_template
