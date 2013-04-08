ad_page_contract {
    Enables user to see a .sql file without encountering the 
    AOLserver's db module magic (offering to load the SQL into a database)
    or without returning the SQL as content-type application/x-sql.

    Patched by philg at Jeff Banks's request on 12/5/99
    to close the security hole whereby a client adds extra form
    vars.

    Patched on 07/06/2000 by deison to restrict access to only
    .sql files and only files in /doc or /pageroot.

    2000 August 8 Updated for ACS4 packages - richardl@arsdigita.com.

    @param url The full relative path of the file to display the source for.
    @param package_key The key of the package the file is part of.

    @creation-date 12/19/98
    @author philg@mit.edu
    @cvs-id $Id: display-sql.tcl,v 1.2 2010/10/19 20:10:17 po34demo Exp $
} {
    url:notnull
    { version_id "" }
    { package_key ""}
} -properties {
    title:onevalue
    context:onevalue
    sql:onevalue
}

set context [list]
if {[exists_and_not_null version_id]} {
    db_0or1row package_info_from_package_id {
        select pretty_name, package_key, version_name
          from apm_package_version_info
         where version_id = :version_id
    }
    lappend context [list "package-view?version_id=$version_id&amp;kind=sql_files" "$pretty_name $version_name"]
}
lappend context [file tail $url]

set title "[file tail $url]"

# This is normally a password-protected page, but to be safe let's
# check the incoming URL for ".." to make sure that someone isn't
# doing
# https://photo.net/doc/sql/display-sql.tcl?url=/../../../../etc/passwd
# for example

if { [string match "*..*" $url] || [string match "*..*" $package_key] } {
    ad_return_error "Can't back up beyond the pageroot" "You can't use 
    display-sql.tcl to look at files underneath the pageroot."
    return
}

if {[exists_and_not_null package_key]} {
    set safe_p [regexp {/?(.*)} $url package_url]
}

if { $safe_p } {
    if [catch {
        set sql [ad_quotehtml [read [open "[acs_package_root_dir $package_key]/sql/$url"]]]
    }] {
        ad_return_error "Problem reading file" "There was a problem reading $url"
    }
} else {
    ad_return_error "Invalid file location" "Can only display files in package or doc directory"
}
