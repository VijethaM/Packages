ad_library {

    Notification Intervals Utilities.

    @creation-date 2002-05-24
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id: interval-procs.tcl,v 1.2 2010/10/20 02:08:12 po34demo Exp $

}

namespace eval notification::interval {

    ad_proc -public get_id_from_name {
        -name:required
    } {

        Returns the interval_id for a given interval_name

        @param name The name of interval (weekly, etc)
        @author Don Baccus (dhogaza@pacifier.com)

    } {

        return [db_string get_interval_id {}]

    }

}
