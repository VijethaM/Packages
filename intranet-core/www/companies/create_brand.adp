<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<master src="../master">
<property name="title">@page_title@</property>
<property name="context">@context_bar@</property>
<property name="main_navbar_label">companies</property>



<%= [im_box_header @page_title@ ] %>
<table border=0><tr><td width=500>
<formtemplate id="brand"></formtemplate>
</td><td width=500 align=center>
<table><tr><td>
@display_logo_html;noquote@
</td></tr></table>

<%= [im_box_footer] %>
<if @is_display_mode@ >
<%= [im_box_header Products ] %>
@show_products_html;noquote@
<%= [im_box_footer] %>
</if>