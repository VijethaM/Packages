ad_page_contract {
    @cvs-id $Id: testcase.tcl,v 1.2 2010/10/19 20:10:29 po34demo Exp $
} {
    testcase_id:nohtml
    package_key:nohtml
    {showsource 0}
    {quiet 1}
} -properties {
    title:onevalue
    context_bar:onevalue
    tests:multirow
    showsource:onevalue
    testcase_desc:onevalue
    testcase_file:onevalue
    testcase_on_error:onevalue
    bodys:multirow
    quiet:onevalue
    fails:onevalue
}
set title "Test case $testcase_id"
set context [list $title]

if {$quiet} {
    set filter { and result = 'fail'}
} else {
    set filter {}
}

db_multirow tests_quiet summary {
    select result, count(*) as count
    from aa_test_results
    where testcase_id = :testcase_id
    and package_key = :package_key
    group by result
}


db_multirow tests acs-automated-testing.testcase_query {}

if {![db_0or1row acs-automated-testing.get_testcase_fails_count {
    select fails
    from aa_test_final_results
    where testcase_id = :testcase_id
}]} {
    set fails -1
}

set testcase_bodys {}
foreach testcase [nsv_get aa_test cases] {
    if {$testcase_id == [lindex $testcase 0] &&
        $package_key == [lindex $testcase 3]} {
        set testcase_desc     [lindex $testcase 1]
        set testcase_file     [lindex $testcase 2]
        set package_key       [lindex $testcase 3]
        set testcase_cats     [join [lindex $testcase 4] ", "]
        set testcase_inits    [join [lindex $testcase 5] ", "]
        set testcase_on_error [lindex $testcase 6]
        set testcase_bodys    [lindex $testcase 7]
        set testcase_error_level [lindex $testcase 8]
        set testcase_bugs     [lindex $testcase 9]
        set testcase_procs    [lindex $testcase 10]
    }
}

set bug_list [list]
foreach bug $testcase_bugs {
    lappend bug_list "<a href=\"[export_vars -base "http://openacs.org/bugtracker/openacs/bug" [list [list bug_number $bug]]]\">$bug</a>"
}
set bug_blurb [join $bug_list ", "]

set proc_list [list]
foreach proc $testcase_procs {                             
                              lappend proc_list "<a href=\"[export_vars -base "/api-doc/proc-view" { proc }]\">$proc</a>"
                          }
set proc_blurb [join $proc_list ", "]


template::multirow create bodys body_number body
if {[llength $testcase_bodys] == 0} {
    set testcase_desc ""
    set testcase_file ""
} else {
    set body_count 0

    #
    # Work out the URL for this directory (stripping off the file element).
    #
    set url "[ad_conn url]"
    regexp {(.*)/[^/]*} $url {\\1} url
    append url "/component?package_key=${package_key}"

    foreach body $testcase_bodys {
        #
        # This regsub changes any "aa_call_component <component_id>" so that the
        # <component_id> element is a link.
        #
        regsub -all {aa_call_component\s+(["]?)([^\s]*)(["]?)} $body \
            "aa_call_component <a href=\"${url}\\&component_id=\\2\">\\1\\2\\3</a>" body
        template::multirow append bodys $body_count $body
        incr body_count
    }
}

set resource_file_url "init-file-resource?[export_vars -url { {return_url {[ad_return_url]} } {absolute_file_path $testcase_file}}]"

set return_url [export_vars -base . { { view_by testcase } quiet { by_package_key $package_key } }]

set quiet_url "[export_vars -base testcase -entire_form -exclude {quiet}]&quiet=1"
set verbose_url "[export_vars -base testcase -entire_form -exclude {quiet}]&quiet=0"
template::head::add_style \
    -style "
.description h2 { 1.5em; }
.fail {
      font-weight: bold;
      color: red;
}
.ok {
      font-weight: bold;
      color: green;
}
dt {
      font-weight: bold
}
th {
      background: #c0c0c0;
}
"

ad_return_template
