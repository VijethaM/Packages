ad_library {

    Tcl procs for the acs permissioning system.

    @author rhs@mit.edu
    @creation-date 2000-08-17
    @cvs-id $Id: acs-permissions-procs.tcl,v 1.2 2010/10/19 20:12:52 po34demo Exp $

}

namespace eval permission {}

# define cache_p to be 0 here.  Note that it is redefined
# to return the value of the PermissionCacheP kernel parameter
# on the first call.  also the namespace eval is needed to 
# make the redefinition work for ttrace.

ad_proc -private permission::cache_p {} {
    returns 0 or 1 depending if permission_p caching is enabled or disabled.
    by default caching is disabled.
} {
    set cache_p [parameter::get -package_id [ad_acs_kernel_id] -parameter PermissionCacheP -default 0]
    namespace eval ::permission [list proc cache_p {} "return $cache_p"]
    return $cache_p
}

ad_proc -public permission::grant {
    {-party_id:required}
    {-object_id:required}
    {-privilege:required}
} {
    grant privilege Y to party X on object Z
} {
    db_exec_plsql grant_permission {}
    util_memoize_flush "permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege"
    permission::permission_thread_cache_flush
}

ad_proc -public permission::revoke {
    {-party_id:required}
    {-object_id:required}
    {-privilege:required}
} {
    revoke privilege Y from party X on object Z
} {
    db_exec_plsql revoke_permission {}
    util_memoize_flush [list permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege]
    permission::permission_thread_cache_flush
}

# args to permission_p and permission_p_no_cache must match
ad_proc -public permission::permission_p {
    {-no_login:boolean}
    {-no_cache:boolean}
    {-party_id ""}
    {-object_id:required}
    {-privilege:required}
} {
    does party X have privilege Y on object Z
    
    @param no_cache force loading from db even if cached (flushes cache as well)
    
    @param no_login Don't bump to registration to refresh authentication, if the user's authentication is expired.
                    This is specifically required in the case where you're calling this from the proc that gets
                    the login page.
    
    @param party_id if null then it is the current user_id

    @param object_id The object you want to check permissions on.
    
    @param privilege The privilege you want to check for.
} {
    if { $party_id eq "" } {
        set party_id [ad_conn user_id]
    }    

    if { $no_cache_p } {
        permission::permission_thread_cache_flush
    }

    if { $no_cache_p || ![permission::cache_p] } {
        util_memoize_flush [list permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege]
        set permission_p [permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege]
    } else { 
        set permission_p [util_memoize \
                              [list permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege] \
                              [parameter::get -package_id [ad_acs_kernel_id] -parameter PermissionCacheTimeout -default 300]]
    }

    if { 
        !$no_login_p
        && $party_id == 0 
        && [ad_conn user_id] == 0 
        && [ad_conn untrusted_user_id] != 0 
        && ![template::util::is_true $permission_p] 
    } {
        set untrusted_permission_p [permission_p_not_cached \
                                        -party_id [ad_conn untrusted_user_id] \
                                        -object_id $object_id \
                                        -privilege $privilege]
        if { $permission_p != $untrusted_permission_p } {
            # Bump to registration page
            ns_log Debug "permission_p: party_id=$party_id ([acs_object_name $party_id]), object_id=$object_id ([acs_object_name $object_id]), privilege=$privilege. Result=>$permission_p. Untrusted-Result=>$untrusted_permission_p\n[ad_get_tcl_call_stack]"
            if { ![ad_login_page] } {
                auth::require_login
            }
        }
    }

    return $permission_p
}


# accepts nocache to match permission_p arguments 
# since we alias it to permission::permission_p if
# caching disabled.
ad_proc -private permission::permission_p_not_cached {
    {-no_cache:boolean}
    {-party_id ""}
    {-object_id:required}
    {-privilege:required}
} {
    does party X have privilege Y on object Z

    @see permission::permission_p
} {
    if { $party_id eq "" } {
        set party_id [ad_conn user_id]
    }

    # We have a thread-local cache here
    global permission__permission_p__cache
    if { ![info exists permission__permission_p__cache($party_id,$object_id,$privilege)] } {
        set permission__permission_p__cache($party_id,$object_id,$privilege) [db_0or1row select_permission_p {}]
    }
    return $permission__permission_p__cache($party_id,$object_id,$privilege)
}


ad_proc -private permission::permission_thread_cache_flush {} {
    Flush thread cache
} {
    global permission__permission_p__cache
    array unset permission__permission_p__cache
}

ad_proc -public permission::require_permission {
    {-party_id ""}
    {-object_id:required}
    {-privilege:required}
} {
    require that party X have privilege Y on object Z
} {
    if {$party_id eq ""} {
        set party_id [ad_conn user_id]
    }

    if {![permission_p -party_id $party_id -object_id $object_id -privilege $privilege]} {
        if {!${party_id}} {
            auth::require_login
        } else {
            ns_log notice "permission::require_permission: $party_id doesn't have $privilege on object $object_id"
            ad_return_forbidden \
                "Permission Denied" \
                "You don't have permission to $privilege [db_string name {}]."
        }

        ad_script_abort
    }
}

ad_proc -public permission::inherit_p {
    {-object_id:required}
} {
    does this object inherit permissions
} {
    return [db_string select_inherit_p {} -default 0]
}

ad_proc -public permission::toggle_inherit {
    {-object_id:required}
} {
    toggle whether or not this object inherits permissions from it's parent
} {
    db_dml toggle_inherit {}
    permission::permission_thread_cache_flush
}

ad_proc -public permission::set_inherit {
    {-object_id:required}
} {
    set inherit to true
} {
    db_dml set_inherit {}
    permission::permission_thread_cache_flush
}

ad_proc -public permission::set_not_inherit {
    {-object_id:required}
} {
    set inherit to false
} {
    db_dml set_not_inherit {}
    permission::permission_thread_cache_flush
}

ad_proc -public permission::write_permission_p {
    {-object_id:required}
    {-party_id ""}
    {-creation_user ""}
} {
    Returns whether a user is allowed to edit an object.
    The logic is that you must have either write permission, 
    or you must be the one who created the object.

    @param object_id     The object you want to check write permissions for

    @param party_id      The party to have or not have write permission.

    @param creation_user Optionally specify creation_user directly as an optimization. 
                         Otherwise a query will be executed.

    @return True (1) if user has permission to edit the object, 0 otherwise.

    @see permission::require_write_permission
} {
    if { [permission::permission_p -privilege write -object_id $object_id -party_id $party_id] } {
        return 1
    }
    if { $creation_user eq "" } {
        set creation_user [acs_object::get_element -object_id $object_id -element creation_user]
    }
    if { [ad_conn user_id] == $creation_user } {
        return 1
    }
    return 0
}

ad_proc -public permission::require_write_permission {
    {-object_id:required}
    {-creation_user ""}
    {-party_id ""}
    {-action "edit"}
} {
    If the user is not allowed to edit this object, returns a permission denied page.

    @param creation_user Optionally specify creation_user directly as an optimization. 
                         Otherwise a query will be executed.

    @param party_id      The party to have or not have write permission.

    @see permission::write_permission_p
} {
    if { ![permission::write_permission_p -object_id $object_id -party_id $party_id] } {
        ad_return_forbidden  "Permission Denied"  "You don't have permission to $action this object."
        ad_script_abort
    } 
}



ad_proc -deprecated ad_permission_grant {
    user_id
    object_id
    privilege
} {
    Grant a permission

    @author ben@openforce.net

    @see permission::grant
} {
    permission::grant -party_id $user_id -object_id $object_id -privilege $privilege
}

ad_proc -deprecated ad_permission_revoke {
    user_id
    object_id
    privilege
} {
    Revoke a permission

    @author ben@openforce.net

    @see permission::revoke
} {
    permission::revoke -party_id $user_id -object_id $object_id -privilege $privilege
}

ad_proc -deprecated ad_permission_p {
    {-user_id ""}
    object_id
    privilege
} { 
    @see permission::permission_p
} {
    return [permission::permission_p -party_id $user_id -object_id $object_id -privilege $privilege]
}

ad_proc -deprecated ad_require_permission {
  object_id
  privilege
} {
    @see permission::require_permission
} { 
    permission::require_permission -object_id $object_id -privilege $privilege
}

ad_proc -private ad_admin_filter {} {
    permission::require_permission -object_id [ad_conn object_id] -privilege "admin"
    return filter_ok
}

ad_proc -private ad_user_filter {} {
    permission::require_permission -object_id [ad_conn object_id] -privilege "read"
    return filter_ok
}
