ad_library {
    
    Compatibily procs in case we're not running a version of AOLServer that supports charsets.
    
    @author Rob Mayoff [mayoff@arsdigita.com]
    @author Nada Amin [namin@arsdigita.com]
    @creation-date June 28, 2000
    @cvs-id $Id: 10-charset-compat-procs.tcl,v 1.2 2010/10/19 20:12:51 po34demo Exp $
}

set compat_procs [list ns_startcontent ns_encodingfortype]

foreach one_proc $compat_procs {
    if {[llength [info command $one_proc]] == 0} {
	proc $one_proc {args} { }
    }
}

