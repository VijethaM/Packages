# packages/notes/www/delete.tcl

ad_page_contract {

  @author rhs@mit.edu
  @creation-date 2000-10-23
  @cvs-id $Id: delete.tcl,v 1.3 2012/02/10 19:50:14 po34demo Exp $
} {
  template_demo_note_id:integer,notnull,multiple
}

foreach template_demo_note_id $template_demo_note_id {
    ad_require_permission $template_demo_note_id delete

    package_exec_plsql \
	-var_list [list [list template_demo_note_id $template_demo_note_id]] \
	template_demo_note \
	del
}

ad_returnredirect "./"
