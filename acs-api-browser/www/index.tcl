ad_page_contract {
    
    Offers links to other pages, and lets the user type the name of a specific procedure.
    If about_package_key is set to an installed package, then this page will automatically
    return /package-view page for the package-key, which is a handy way of integrating
    static docs with evolving api, especially for core packages.

    @about_package_key a package-key
    @author Jon Salz (jsalz@mit.edu)
    @author Lars Pind (lars@pinds.com)
    @cvs-id $Id: index.tcl,v 1.2 2010/10/19 20:10:17 po34demo Exp $
} {
    about_package_key:optional
} -properties {
    title:onevalue
    context:onevalue
    installed_packages:multirow
    disabled_packages:multirow
    uninstalled_packages:multirow
}

set title "API Browser"
set context [list]

if  { [info exists about_package_key] } {

    if { [db_0or1row get_local_package_version_id {} ] } {
        rp_form_put version_id $version_id
        rp_internal_redirect package-view
    }

} else {

    db_multirow installed_packages installed_packages_select {
        select version_id, pretty_name, version_name
          from apm_package_version_info
        where installed_p = 't'
          and enabled_p = 't'
      order by upper(pretty_name)
    }

    db_multirow disabled_packages disabled_packages_select {
        select version_id, pretty_name, version_name
          from apm_package_version_info
         where installed_p = 't'
           and enabled_p = 'f'
      order by upper(pretty_name)
    }

    db_multirow uninstalled_packages uninstalled_packages_select {
        select version_id, pretty_name, version_name
          from apm_package_version_info
         where installed_p = 'f'
           and enabled_p = 'f'
      order by upper(pretty_name)
    }

}
