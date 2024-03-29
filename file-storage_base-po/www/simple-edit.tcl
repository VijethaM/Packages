ad_page_contract {
    page to edit a new nonversioned object

    @author Ben Adida
    @creation-date 01 April 2002
    @cvs-id $Id: simple-edit.tcl,v 1.1.1.1 2010/10/20 02:03:00 po34demo Exp $
} {
    object_id:notnull
}

# check for write permission on the item
ad_require_permission $object_id write

# Message lookup uses variable pretty_name

ad_form -name simple-edit -form {
    object_id:key
    {name:text {label "#file-storage.Title_#"} {html {size 40} } }
    {url:text {label "#file-storage.URL#"} {html {size 50} } }
    {description:text(textarea),optional {label "#file-storage.Description#" } {html { rows 5 cols 50 } } }
    {folder_id:text(hidden)}
}

set package_id [ad_conn package_id]
if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
    category::ad_form::add_widgets \
	 -container_object_id $package_id \
	 -categorized_object_id $object_id \
	 -form_name simple-edit
}

ad_form -extend -edit_request {
    db_1row extlink_data ""
} -edit_data {
    content::extlink::edit -extlink_id $object_id -url $url -label $name -description $description
    if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
	category::map_object -remove_old -object_id $object_id [category::ad_form::get_categories \
								       -container_object_id $package_id \
								       -element_name category_id]
    }
    ad_returnredirect "?[export_vars folder_id]"
}

set pretty_name "$name"
set context [fs_context_bar_list -final "[_ file-storage.Edit_URL]" $folder_id]
set page_title [_ file-storage.file_edit_page_title_1]

ad_return_template
