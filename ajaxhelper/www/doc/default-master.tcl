ad_page_contract {
  This is the highest level site specific master template.

  @author Lee Denison (lee@xarg.co.uk)

  $Id: default-master.tcl,v 1.1 2010/10/21 13:17:23 po34demo Exp $
}

#
# Set some basic variables
#
set system_name [ad_system_name]

if { [string equal [ad_conn url] "/"] } {
    set system_url ""
} else {
    set system_url [ad_url]
}

if {[template::util::is_nil title]} {
    # TODO: decide how best to set the lang attribute for the title
    set title [ad_conn instance_name]
}

if {![template::multirow exists link]} {
    template::multirow create link rel type href title lang media
}

#
# Create standard top level navigation
#
if {![info exists navigation_groups]} {
    # set navigation_groups [list]
    set navigation_groups [list]
}

if {![template::multirow exists navigation]} {
    template::multirow create navigation \
        group \
        label \
        href \
        target \
        title \
        lang \
        accesskey \
        class \
        id \
        tabindex 
}
for {set i 1} {$i <= [template::multirow size navigation]} {incr i} {
    template::multirow get navigation $i
    if {[lsearch $navigation_groups $navigation(group)] < 0} {
        lappend navigation_groups $navigation(group)
    }
}

#
# Add standard css
#
template::multirow append link \
    stylesheet \
    "text/css" \
    "/resources/acs-subsite/default-master.css" \
    "" \
    en \
    "all"

# 
# User information and top level navigation links
#
set user_id [ad_conn user_id]
set untrusted_user_id [ad_conn untrusted_user_id]
set sw_admin_p 0

if { $untrusted_user_id == 0 } {
    # The browser does NOT claim to represent a user that we know about
    set login_url [ad_get_login_url -return]
} else {
    # The browser claims to represent a user that we know about
    set user_name [person::name -person_id $untrusted_user_id]
    set pvt_home_url [ad_pvt_home]
    set pvt_home_name [_ acs-subsite.Your_Account]
    set logout_url [ad_get_logout_url]

    # Site-wide admin link
    set admin_url {}

    set sw_admin_p [acs_user::site_wide_admin_p -user_id $untrusted_user_id]

    if { $sw_admin_p } {
        set admin_url "/acs-admin/"
        set devhome_url "/acs-admin/developer"
        set locale_admin_url "/acs-lang/admin"
    } else {
        set subsite_admin_p [permission::permission_p \
            -object_id [subsite::get_element -element object_id] \
            -privilege admin \
            -party_id $untrusted_user_id]

        if { $subsite_admin_p  } {
            set admin_url "[subsite::get_element -element url]admin/"
        }
    }
}

#
# User messages
#
util_get_user_messages -multirow user_messages

# 
# Set acs-lang urls
#
set acs_lang_url [apm_package_url_from_key "acs-lang"]
set num_of_locales [llength [lang::system::get_locales]]

if {[empty_string_p $acs_lang_url]} {
    set lang_admin_p 0
} else {
    set lang_admin_p [permission::permission_p \
        -object_id [site_node::get_element \
            -url $acs_lang_url \
            -element object_id] \
        -privilege admin \
        -party_id [ad_conn untrusted_user_id]]
}

set toggle_translator_mode_url [export_vars \
    -base ${acs_lang_url}admin/translator-mode-toggle \
    {{return_url [ad_return_url]}}]

set package_id [ad_conn package_id]
if { $num_of_locales > 1 } {
    set change_locale_url [export_vars -base $acs_lang_url {package_id}]
}

#
# Change locale link
#
if {[llength [lang::system::get_locales]] > 1} {
    set change_locale_url [export_vars -base "/acs-lang/" {package_id}]
}

#
# Who's Online
#
set num_users_online [lc_numeric [whos_online::num_users]]
set whos_online_url "[subsite::get_element -element url]shared/whos-online"

#
# Context bar
#
if {[info exists context]} {
    set context_tmp $context
    unset context
} else {
    set context_tmp {}
}

ad_context_bar_multirow -- $context_tmp

#
# Curriculum specific bar
#   TODO: remove this and add a more systematic / package independent way 
#   TODO  of getting this content here
#
set curriculum_bar_p [expr {
    [site_node::get_package_url -package_key curriculum] ne ""
}]

