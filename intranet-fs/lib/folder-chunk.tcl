# intranet-fs/lib/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id: folder-chunk.tcl,v 1.48 2009/06/09 12:37:14 emmar Exp $
} -query {
    {orderby:optional}
} -properties {
    project_id:onevalue
    folder_name:onevalue
    contents:multirow
    content_size_total:onevalue
    page_num
}


set return_url [util_get_current_url]
if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
    ad_script_abort
}
if {![exists_and_not_null allow_bulk_actions]} {
    set allow_bulk_actions "0"
}
if { ![exists_and_not_null category_id] } {
    set category_id ""
}
set viewing_user_id [ad_conn user_id]

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

set admin_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "admin"]

set write_p $admin_p

if {!$write_p} {
    set write_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "write"]
}

set delete_p $admin_p

if {!$delete_p} {
    set delete_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "delete"]
}

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

if {![exists_and_not_null fs_url]} {
    set fs_url "/file-storage/"
}

set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

set content_size_total 0

if {![exists_and_not_null format]} {
    set format table
}

#AG: We're an include file, and we may be included from outside file-storage.
#So we need to query for the package_id rather than getting it from ad_conn.
# ad_return_complaint 1 "$folder_id"
 set package_and_root [fs::get_folder_package_and_root $folder_id]

# set pack_id [db_string ds "select package_id from fs_root_folders"]
# set root_folder_id1 [db_string ds "select folder_id from fs_root_folders"]

# set package_and_root [list $pack_id $root_folder_id1]
# ad_return_complaint 1 "$package_and_root"

set package_id [lindex $package_and_root 0]
if {![exists_and_not_null root_folder_id]} {
    set root_folder_id [lindex $package_and_root 1]
}

if { $root_folder_id ne $folder_id } {
    set folder_path "[db_exec_plsql get_folder_path {}]/"
} else {
    set folder_path ""
}

set actions [list]

# for now, invite users to upload, and then they will be asked to
# login if they are not.

set cancel_url "[ad_conn url]?[ad_conn query]"
set add_url [export_vars -base "${fs_url}file-add" {folder_id return_url}]

lappend actions "#file-storage.Add_File#" [export_vars -base "${fs_url}file-upload-confirm" {folder_id cancel_url {return_url $add_url}}] "[_ file-storage.lt_Upload_a_file_in_this]" 
#vijetha@vmc 29/03/2013 commented below code. Except Add File Buton All should disable.
#lappend actions
#    "#file-storage.Create_a_URL#" [export_vars -base "${fs_url}simple-add" {folder_id return_url}] "[_ file-storage.lt_Add_a_link_to_a_web_p]" \
#    "#file-storage.New_Folder#" [export_vars -base "${fs_url}folder-create" {{parent_id $folder_id} return_url}] "#file-storage.Create_a_new_folder#" \
#    "[_ file-storage.lt_Upload_compressed_fol]" [export_vars -base "${fs_url}folder-zip-add" {folder_id return_url}] "[_ file-storage.lt_Upload_a_compressed_f]"

set expose_rss_p [parameter::get -parameter ExposeRssP -package_id $package_id -default 0]
set like_filesystem_p [parameter::get -parameter BehaveLikeFilesystemP -package_id $package_id -default 1]

set target_window_name [parameter::get -parameter DownloadTargetWindowName -package_id $package_id -default ""]
if { [string equal $target_window_name ""] } {
    set target_attr ""
} else {
    set target_attr "target=\"$target_window_name\""
}

#vijetha@vmc 29/03/2013 commented below code. Except Add File Buton All should disable.
#if {$delete_p} {
#    lappend actions "#file-storage.Delete_this_folder#" [export_vars -base "${fs_url}folder-delete" {folder_id return_url}] "#file-storage.Delete_this_folder#"
#}

#if {$admin_p} {
#    lappend actions "#file-storage.Edit_Folder#" [export_vars -base "${fs_url}folder-edit" {folder_id return_url}] "#file-storage.Rename_this_folder#"
#    lappend actions "#file-storage.lt_Modify_permissions_on_1#" [export_vars -base "${fs_url}permissions" -override {{object_id $folder_id}} {{return_url "[util_get_current_url]"}}] "#file-storage.lt_Modify_permissions_on_1#"
#    if { $expose_rss_p } {
#        lappend actions "Configure RSS" [export_vars -base "${fs_url}admin/rss-subscrs" {folder_id}] "Configure RSS"
#    }
#}
set categories_p [parameter::get -parameter CategoriesP -package_id $package_id -default 0]
if { $categories_p } {
    if { [permission::permission_p -party_id $viewing_user_id -object_id $package_id -privilege "admin"] } {
        lappend actions [_ categories.cadmin] [export_vars -base "/categories/cadmin/object-map" -url {{object_id $package_id}}] [_ categories.cadmin]
    }
    set category_links [fs::category_links -object_id $folder_id -folder_id $folder_id -selected_category_id $category_id -fs_url $fs_url]
}

#set n_past_filter_values [list [list "Yesterday" 1] [list [_ file-storage.last_week] 7] [list [_ file-storage.last_month] 30]]
set elements [list \
                  type \
                  [list label [_ file-storage.Type] \
                             display_template {<center><img src="@contents.icon@"  style="border: 0;" alt="@contents.alt_icon@"><!--@contents.pretty_type@-->} \
                             orderby_desc {sort_key_desc,fs_objects.pretty_type desc} \
                             orderby_asc {fs_objects.sort_key, fs_objects.pretty_type asc}] \
                  document_type \
                   [list label [_ intranet-fs.doc_ype] \
                    display_template { @contents.document_type;noquote@} \
                    orderby_desc {sort_key_desc,document_type desc} \
                    orderby_asc {fs_objects.sort_key, document_type asc}] \
                  name \
                  [list label [_ file-storage.Name] \
                       display_template {<center><a @target_attr@ href="@contents.file_url@" title="\#file-storage.view_contents\#"><if @contents.title@ nil>@contents.name@</a></if><else>@contents.title@</a><br><!--<if @contents.name@ ne @contents.title@>@contents.name@</if>--></else>} \
                       orderby_desc {fs_objects.name desc} \
                       orderby_asc {fs_objects.name asc}] \
                  short_name \
                  [list label [_ file-storage.Name] \
                       hide_p 1 \
                       display_template {<a href="@contents.download_url@" title="\#file-storage.Download\#">@contents.title@</a>} \
                       orderby_desc {fs_objects.name desc} \
                       orderby_asc {fs_objects.name asc}] \
                  content_size_pretty \
                  [list label [_ file-storage.Size] \
                       display_template {@contents.content_size_pretty;noquote@} \
                       orderby_desc {content_size desc} \
                       orderby_asc {content_size asc}] \
                  last_modified_pretty \
                  [list label [_ file-storage.Last_Modified] \
                       orderby_desc {last_modified_ansi desc} \
                       orderby_asc {last_modified_ansi asc}] \
		  file_state \
		  [list label [_ intranet-fs.State] \
		       display_template { @contents.file_state_pretty;noquote@}] \
                  download_link \
                  [list label "" \
                       link_url_col download_url \
                       link_html { title "[_ file-storage.Download]" }] \
		 properties_link \
		  [list label "" \
		       link_url_col properties_url \
		       link_html { title "[_ file-storage.properties]" }] \
		 file_state_change \
		  [list label "[_ file-storage.Actions]" \
		       display_template {
			   <table>
			<!--   <tr>
			     <if @contents.approve_url@ not nil>
			       <td><a href='@contents.approve_url@' class='button'>#intranet-fs.Approve#</a></td> 
			     </if>
			     <if @contents.disapprove_url@ not nil>
			       <td><a href='@contents.disapprove_url@' class='button'>#intranet-fs.Disapprove#</a></td>
			     </if></tr> -->
			     <tr>
  			     <if @contents.publish_url@ not nil>
			       <td><a href='@contents.publish_url@' class='button'>#intranet-fs.Check_Out#</a></td>
			     </if>
			     </tr>
			     <tr>
		             <if @contents.unpublish_url@ not nil>
			       <td><a href='@contents.unpublish_url@' class='button'>#intranet-fs.Check_In#</a></td>
			     </if>
			   </tr></table>
		       }] \
	     ] 

##vijetha@vmc 01/04/2013 commented below  code which is has removed from above elements . So that New Link will not display. Every one cant upload new file except the one who has checked out the file

#  new_version_link \
#		  [list label "" \
#		       link_url_col new_version_url \
#		       link_html { title "[_ file-storage.Upload_a_new_version]" }] \

if { $categories_p } {
    lappend elements categories [list label [_ file-storage.Categories] display_col "categories;noquote"]
}

#lappend elements views [list label "Views" ]



#if {[apm_package_installed_p views]} {
#    concat $elements [list views [list label "Views"]]
#}

if {[exists_and_not_null return_url]} {
    set return_url [export_vars -base "index" {folder_id}]
}
set vars_to_export [list return_url]

if {$allow_bulk_actions} {
#    set bulk_actions [list "[_ file-storage.Move]" "${fs_url}move" "[_ file-storage.lt_Move_Checked_Items_to]" "[_ file-storage.Copy]" "${fs_url}copy" "[_ file-storage.lt_Copy_Checked_Items_to]" "[_ file-storage.Delete]" "${fs_url}delete" "[_ file-storage.Delete_Checked_Items]" "[_ file-storage.Download_ZIP]" "${fs_url}download-zip" "[_ file-storage.Download_ZIP_Checked_Items]"]
set bulk_actions [list "[_ file-storage.Download_ZIP]" "${fs_url}download-zip" "[_ file-storage.Download_ZIP_Checked_Items]"]

#    callback fs::folder_chunk::add_bulk_actions \
#        -bulk_variable "bulk_actions" \
#        -folder_id $folder_id \
#        -var_export_list "vars_to_export"
} else {
    set bulk_actions ""
}

if {$format eq "list"} { 
    set actions {}
} 

template::list::create \
    -name contents_${folder_id} \
    -multirow contents \
    -key object_id \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars $vars_to_export \
    -selected_format $format \
    -formats {
        table {
            label Table
            layout table
        }
        list {
            label List
            layout list
            template {
                <listelement name="short_name"> - <listelement name="last_modified_pretty">  
            }
        }
    } \
    -pass_properties [list target_attr] \
    -filters {
	project_id {}
        folder_id {hide_p 1}
        page_num
    } \
    -elements $elements

set orderby [template::list::orderby_clause -orderby -name contents_${folder_id}]

if {[string equal $orderby ""]} {
    set orderby " order by fs_objects.sort_key, fs_objects.name asc"
}

if { $categories_p && [exists_and_not_null category_id] } {
    set categories_limitation [db_map categories_limitation]
} else {
    set categories_limitation {}
}


db_multirow -extend {label alt_icon icon last_modified_pretty content_size_pretty properties_link properties_url download_link download_url new_version_link new_version_url views categories approve_url disapprove_url publish_url unpublish_url file_state_pretty} contents select_folder_contents {} {
    
	   #vijetha@vmc 01/04/2013 added below  URL to download file If the Click On Ckeck-IN
	set change_item_url "/file-storage/download-zip"
	set change_item_url1 "/file-storage/file-add"
	
    set file_state_pretty $file_state
    set flag 1
#    set change_item_url "/file-storage/change-file-state"
    set return_url [util_get_current_url]
	 set file_state_pretty ""
	if {$file_state=="ready"} {
	set file_state_pretty "Document Ready"
	}
#vijetha@vmc 01/04/2013 added below  condition if File is already Checked Out No one else Can Checkin the Document Excpet by the person Who has Checked Out.
	if {$file_state=="chekd_out"} {
	set file_state_pretty "Document CheckedOut"
	}

	

    switch $file_state {
	ready { 
		 set publish_url [export_vars -base "$change_item_url" {{object_id} {status chekd_out} {flag}}]
#	    set disapprove_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status production} {return_url}}]
#	    set publish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status live} {return_url}}]
#	    set unpublish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status expired} {return_url}}]
	}
	production {
	    set approve_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status ready} {return_url}}]
	    set publish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status live} {return_url}}]
	    set unpublish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status expired} {return_url}}]
	}
	expired {
	    set disapprove_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status production} {return_url}}]
	    set approve_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status ready} {return_url}}]
	    set publish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status live} {return_url}}]
	}
	live {
	    set disapprove_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status production} {return_url}}]
	    set approve_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status ready} {return_url}}]
	    set unpublish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status expired} {return_url}}]
	    
	}
	chekd_out {
		set checked_out_user_id [db_string u_id "select status_updated_by from cr_items where item_id=$object_id and publish_status='chekd_out'" -default ""]
		if {$checked_out_user_id==$viewing_user_id} {
			set file_id $object_id
			set unpublish_url [export_vars -base "$change_item_url1" {{file_id} {status chekd_in} {flag}}]
		}
	}
    }
    #if user is not Ben Bigboss revoke all actions
    #Error SWA has no actions buttons
    set po_admin_p [group::party_member_p -party_id [ad_conn user_id -group_name "P/O Admin"]]
    set admin_p [acs_user::site_wide_admin_p -user_id [ad_conn user_id]]
#    if {!$admin_p && !$po_admin_p} {
#	set approve_url ""
#	set disapprove_url ""
#	set publish_url ""
#	set unpublish_url ""
#    }

    #if user is project manager and not po admin grant publish privilege
    set p_manager_p [group::party_member_p -party_id [ad_conn user_id] -group_name "Project Managers"]
    if {$p_manager_p && !$po_admin_p} {
	set publish_url [export_vars -base "$change_item_url" {{item_id} {live_revision} {status live} {return_url}}]
    }

    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
    
    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    if {[string equal $type "folder"]} {
        set content_size_pretty [lc_numeric $content_size]
        append content_size_pretty "&nbsp;[_ file-storage.items]"
        set pretty_type "#file-storage.Folder#"
    } else {
        if { $content_size eq "" } {
            set content_size_pretty ""
        } elseif {$content_size < 1024} {
            set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.bytes]"
        } else {
            set content_size_pretty "[lc_numeric [expr $content_size / 1024 ]]&nbsp;[_ file-storage.kb]"
        }

    }

    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]

    if { ![empty_string_p $content_size] } {
        incr content_size_total $content_size
    }

    set views ""
    if {[apm_package_installed_p views]} {
        array set views_arr [views::get -object_id $object_id] 
        if {$views_arr(views_count) ne ""} {
            set views " $views_arr(views_count) / $views_arr(unique_views)"
        }
    }

    set name [lang::util::localize $name]
    switch -- $type {
        folder {
            set properties_link ""
            set properties_url ""
            set new_version_link {}
            set new_version_url {}
            set icon "/resources/file-storage/folder.gif"
            set alt_icon #file-storage.folder#
            set file_url [export_vars -base "/intranet-fs/index" {{folder_id $object_id} {project_id $project_id} return_url}]
            set download_link [_ file-storage.Download]
            set download_url "[export_vars -base "${fs_url}download-zip" -url {object_id}]"
        }
        url {
	    #set owner_p [permission::write_permission_p -object_id $item_id -party_id [ad_conn user_id]]
	    set owner_p [acs_object::get_element -object_id $item_id -element creation_user]
	    if {$owner_p eq [ad_conn user_id] || $admin_p } {
		set properties_link [_ file-storage.properties]
		set properties_url [export_vars -base "${fs_url}simple" {object_id}]
		set new_version_link [_ acs-kernel.common_New]
		set new_version_url [export_vars -base "${fs_url}file-add" {{file_id $object_id}}]
	    } else {
		set properties_link ""
		set properties_url ""
		set new_version_link ""
		set new_version_url ""
	    }
            set icon "/resources/acs-subsite/url-button.gif"
            # DRB: This alt text somewhat sucks, but the message key already exists in
            # the language catalog files we care most about and we want to avoid a new
            # round of translation work for this minor release if possible ...
            set alt_icon #file-storage.link#
            set file_url ${url}
            set download_url {}
            set download_link {}
            
        }
        symlink {
            # save the original object_id to set it later back (see below)
            set original_object_id $object_id
            set target_object_id [content::symlink::resolve -item_id $object_id]
            db_1row file_info {select * from fs_objects where object_id = :target_object_id}
            # because of the side effect that SQL sets TCL variables, set object_id back to the original value
            set object_id $original_object_id
            if {[string equal $type "folder"]} {
                set content_size_pretty [lc_numeric $content_size]
                append content_size_pretty "&nbsp;[_ file-storage.items]"
                set pretty_type "#file-storage.Folder#"
            } else {
                if {$content_size < 1024} {
                    set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.bytes]"
                } else {
                    set content_size_pretty "[lc_numeric [expr $content_size / 1024 ]]&nbsp;[_ file-storage.kb]"
                }
                
            }

	    #set owner_p [permission::write_permission_p -object_id $item_id -party_id [ad_conn user_id]]
	    set owner_p [acs_object::get_element -object_id $item_id -element creation_user]
	    if {$owner_p eq [ad_conn user_id] || $admin_p} {
	    	set properties_link [_ file-storage.properties]
		set properties_url [export_vars -base "${fs_url}file" {{file_id $object_id}}]
		set new_version_link [_ acs-kernel.common_New]
		set new_version_url [export_vars -base "${fs_url}file-add" {{file_id $object_id}}]
	    } else {
		set properties_link ""
		set properties_url ""
		set new_version_link ""
		set new_version_url ""
	    }

            set icon "/resources/file-storage/file.gif"
            set alt_icon #file-storage.file#
            set file_url "${fs_url}view/${file_url}"
            set download_link [_ file-storage.Download]
            if {$like_filesystem_p} {
                set download_url [export_vars -base "${fs_url}download/$title" {{file_id $target_object_id}}]
                set file_url $download_url
            } else {
                set download_url [export_vars -base "${fs_url}download/$name" {{file_id $target_object_id}}]
            }
        }
        default {
	    #set owner_p [permission::write_permission_p -object_id $item_id -party_id [ad_conn user_id]]
	    set owner_p [acs_object::get_element -object_id $item_id -element creation_user]
	    if {$owner_p eq [ad_conn user_id] || $admin_p} {
		set properties_link [_ file-storage.properties]
		set properties_url [export_vars -base "${fs_url}file" {{file_id $object_id} return_url}]
		set new_version_link [_ acs-kernel.common_New]
		set new_version_url [export_vars -base "${fs_url}file-add" {{file_id $object_id} return_url}]
	    } else { 
		set properties_link ""
		set properties_url ""
		set new_version_link ""
		set new_version_url ""
	    }
            set icon "/resources/file-storage/file.gif"
            set alt_icon "#file-storage.file#"
            set file_url "${fs_url}view/${folder_path}[ad_urlencode ${name}]"
            set download_link [_ file-storage.Download]
            if {$like_filesystem_p} {
                set file_url [export_vars -base "${fs_url}download/[ad_urlencode $title]" {{file_id $object_id}}]
                set download_url "/file/$object_id/[ad_urlencode $title][file extension $name]"
            } else {
                set download_url "/file/$object_id/[ad_urlencode $name]"
		set file_url $download_url
            }
        }

    }
    if { $categories_p } {
        if { $type eq "folder" } {
            set cat_folder_id $object_id
        } else {
            set cat_folder_id $folder_id
        }
        set categories [fs::category_links -object_id $object_id -folder_id $cat_folder_id -selected_category_id $category_id -fs_url $fs_url -joinwith "<br>"]
    }

}

if { $expose_rss_p } {
    db_multirow feeds select_subscrs {}
}

if {$format eq "list"} {
    set content_size_total 0
}

if { $expose_rss_p } {
    db_multirow feeds select_subscrs {}
}

if {$content_size_total > 0} {
    set compressed_url [export_vars -base "${fs_url}download-zip" -url {{object_id $folder_id}}]
}
ad_return_template
