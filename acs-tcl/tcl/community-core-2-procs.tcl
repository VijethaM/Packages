ad_library {

    Community routines (dealing with users, parties, etc.).
    Redone with scoping and nice abstraction (Ben)

    @author Ben Adida (ben@openforce.net)
    @creation-date May 29th, 2002
    @cvs-id $Id: community-core-2-procs.tcl,v 1.2 2010/10/19 20:12:54 po34demo Exp $

}

# The User Namespace
namespace eval oacs::user {

    ad_proc -public get {
        {-user_id:required}
        {-array:required}
    } {
        Load up user information
    } {
        # Upvar the Tcl Array
        upvar $array row
        db_1row select_user {} -column_array row
    }

}
