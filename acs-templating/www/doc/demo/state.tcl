ad_page_contract {
  $Id: state.tcl,v 1.3 2012/02/10 19:50:12 po34demo Exp $
} -query {
  state_abbrev
} -properties {}

request create

request set_param state_abbrev -datatype keyword -validate {
  { regexp {CA|HI|NV} $value } 
  { Invalid state abbreviation $value. }
}

# demonstrate the separate error page

if { [ns_queryexists errorpage] } {

  if { [request is_valid] } { return }

} else {

  request is_valid self
}

set query "select 
             first_name, last_name, state
           from
             ad_template_sample_users
           where
             state = :state_abbrev
           order by last_name"


db_multirow users state_query $query