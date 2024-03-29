ad_library {
    Provides methods for communicating between load-balanced servers.
    
    @cvs-id $Id: server-cluster-procs.tcl,v 1.2 2010/10/19 20:12:57 po34demo Exp $
    @author Jon Salz <jsalz@mit.edu>
    @creation-date 7 Mar 2000
}    

ad_proc server_cluster_enabled_p {} { Returns true if clustering is enabled. } {
    return [parameter::get -package_id [ad_acs_kernel_id] -parameter ClusterEnabledP -default 0]
}

ad_proc server_cluster_all_hosts {} { Returns a list of all hosts, possibly including this host, in the server cluster. } {
    if { ![server_cluster_enabled_p] } {
	return [list]
    }
    return [parameter::get -package_id [ad_acs_kernel_id] -parameter ClusterPeerIP]
}

ad_proc server_cluster_peer_hosts {} { Returns a list of all hosts, excluding this host, in the server cluster. } {
    set peer_hosts [list]
    set my_ip [ns_config ns/server/[ns_info server]/module/nssock Address]

    foreach host [server_cluster_all_hosts] {
       #AGUSTIN
       if { ![regexp {(.*):(.*)} $host match myhost myport] } {
            set myport 80
            set myhost $host
       }
       if { $myhost ne $my_ip } {
	    lappend peer_hosts $host
	}
    }

    return $peer_hosts
}

ad_proc server_cluster_authorized_p { ip } { Can a request coming from $ip be a valid cluster request, i.e., matches some value in ClusterIPMask or is 127.0.0.1? } {
    if { ![server_cluster_enabled_p] } {
	return 0
    }

    if { $ip == "127.0.0.1" } {
	return 1
    }
    # lsearch -glob appears to crash AOLserver 2. Oh well.
    foreach glob [parameter::get -package_id [ad_acs_kernel_id] -parameter ClusterAuthorizedIP] {
	if { [string match $glob $ip] } {
	    return 1
	}
    }
    return 0
}

proc server_cluster_do_httpget { url timeout } {
    if { [catch {
	set page [ns_httpget $url $timeout 0]
	if { ![regexp -nocase successful $page] } {
	    ns_log "Error" "Clustering: ns_httpget $url returned unexpected value. Is /SYSTEM/flush-memoized-statement.tcl set up on this host?"
	}
    } error] } {
	ns_log "Error" "Clustering: Unable to ns_httpget $url (with timeout $timeout): $error"
    }
}

ad_proc -private server_cluster_logging_p {} { Returns true if we're logging cluster requests. } {
    return [parameter::get -package_id [ad_acs_kernel_id] -parameter EnableLoggingP -default 0]
}

ad_proc -private server_cluster_httpget_from_peers {
    { -timeout 5 }
    url
} { Schedules an HTTP GET request to be issued immediately to all peer hosts (using ad_schedule_proc -once t -thread f -debug t 0). } {
    if { ![string match "/*" $url] } {
	set url "/$url"
    }
    foreach host [server_cluster_peer_hosts] {
	# Schedule the request. Don't actually issue the request in this thread, since
	# (a) we want to parallelize the requests, and (b) we want this procedure to
	# return immediately.
	ad_schedule_proc -once t -thread f -debug t -all_servers t 0 server_cluster_do_httpget "http://$host$url" $timeout
    }
}

ad_proc -private ad_canonical_server_p {} { 
    Returns true if this is the primary server, false otherwise. 

    we're using IP:port to uniquely identify the canonical server, since
    hostname or IP does not always uniquely identify an instance of
    aolserver (for instance, if we have the aolservers sitting behind a
    load balancer).
} {
    set canonical_server [parameter::get -package_id [ad_acs_kernel_id] -parameter CanonicalServer]
    if { $canonical_server eq "" } {
	ns_log Error "Your configuration is not correct for server clustering. Please ensure that you have the CanonicalServer parameter set correctly."
	return 1
    }

    if { ![regexp {(.*):(.*)} $canonical_server match canonical_ip canonical_port] } {
	set canonical_port 80
	set canonical_ip $canonical_server
    }
   
    if { [ns_config ns/server/[ns_info server]/module/nssock Address] == $canonical_ip && \
	    [ns_config ns/server/[ns_info server]/module/nssock Port 80] == $canonical_port } {
	return 1
    }

    return 0
}
