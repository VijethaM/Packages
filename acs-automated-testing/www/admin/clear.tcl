ad_page_contract {
  @cvs-id $Id: clear.tcl,v 1.2 2010/10/19 20:10:28 po34demo Exp $
} {
  {package_key ""}
  {category:aa_test_category ""}
  {view_by:aa_test_view_by "package"}
  {testcase_id:nohtml ""}
  {quiet "0"}
} -properties {
}

set sql "delete from aa_test_results"
db_dml delete_testcase_tests_sql $sql
set sql "delete from aa_test_final_results"
db_dml delete_testcase_tests_sql $sql

ad_returnredirect "index"

ad_returnredirect "index?by_package_key=$package_key&by_category=$category&view_by=$view_by&quiet=$quiet"
