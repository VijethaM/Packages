ad_page_contract {

    Main Index page for reference data. 

    @author Jon Griffin (jon@jongriffin.com)
    @creation-date 2001-08-26
    @cvs-id $Id: index.tcl,v 1.2 2010/10/19 20:12:03 po34demo Exp $
} {
} -properties {
  context_bar:onevalue
  package_id:onevalue
  user_id:onevalue
  title:onevalue
}

set title "Reference Data"
set package_id [ad_conn package_id]
set context_bar [list $title]
set user_id [ad_conn user_id]

set admin_p [ad_permission_p $package_id admin]

ad_return_template
