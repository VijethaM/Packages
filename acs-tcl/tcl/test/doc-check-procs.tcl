ad_library {
    Check all the proc documentation 

    @author Jeff Davis
    @creation-date 2005-02-28
    @cvs-id $Id: doc-check-procs.tcl,v 1.2 2010/10/19 20:41:45 po34demo Exp $
}

aa_register_case -cats {smoke production_safe} documentation__check_proc_doc {
    checks if documentation exists for public procs.

    @author Jeff Davis davis@xarg.net
} {
    set count 0
    set good 0
    foreach p [lsort -dictionary [nsv_array names api_proc_doc]] {
        array set pa [nsv_get api_proc_doc $p]
        if { $pa(public_p)
             && !($pa(deprecated_p) || $pa(warn_p))
         } {
            incr count
            if { [string is space $pa(main)] } {
                aa_log_result fail "No documentation for public proc $p"
            } else {
                incr good
            }
        }
        array unset pa
    }
    aa_log "Found $good good of $count checked"
}



aa_register_case -cats {smoke production_safe} -error_level warning documentation__check_deprecated_see {
    checks if deprecated procs have an @see clause

    @author Jeff Davis davis@xarg.net
} {
    set count 0
    set good 0
    foreach p [lsort -dictionary [nsv_array names api_proc_doc]] {
        array set pa [nsv_get api_proc_doc $p]
        if { $pa(deprecated_p)||$pa(warn_p) } {
            incr count
            if { ![info exists pa(see)] || [string is space $pa(see)] } {
                aa_log_result fail "No @see for deprecated proc $p"
            } else {
                incr good
            }
        }
        array unset pa
    }
    aa_log "Found $good of $count procs checked"
}

