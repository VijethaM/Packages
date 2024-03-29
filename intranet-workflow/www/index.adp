<master src="../../intranet-core/www/master">
<property name="title">@page_title@</property>
<property name="main_navbar_label">workflow</property>
<property name="left_navbar">@left_navbar_html;noquote@</property>

<!-- left - right - bottom  design -->

<table cellpadding=0 cellspacing=0 border=0 width="100%">
<tr>
  <td colspan=3>
    <%= [im_component_bay top] %>
  </td>
</tr>
<tr>
  <td valign="top" width="50%">

    <%= [im_component_bay left] %>

  </td>
  <td width=2>&nbsp;</td>
  <td valign="top" width="50%">

		<table cellspacing="5" cellpadding="5">
		  <tr class="rowtitle">
		    <th colspan="2">Notifications</th>
		    <th>Subscribe</th>
		  </tr>
		  <multiple name="notifications">
		    <if @notifications.rownum@ odd>
		      <tr class="bt_listing_odd">
		    </if>
		    <else>
		      <tr class="bt_listing_even">
		    </else>
		      <td align="center" class="bt_listing_narrow">
		        <if @notifications.subscribed_p@ true>
		          <b>&raquo;</b>
		        </if>
		        <else>
		          &nbsp;
		        </else>
		      </td>
		      <td class="bt_listing">
		        @notifications.label@
		      </td>
		      <td class="bt_listing">
		        <if @notifications.subscribed_p@ false>
		          <a href="@notifications.url@" title="@notifications.title@">Subscribe</a>
		        </if>
			<else>
		          <a href="@notifications.url@" title="@notifications.title@">Unsubscribe</a>
			</else>
		      </td>
		    </tr>
		  </multiple>
		</table>


<if @admin_html@ ne "">
        <table border=0 cellpadding=1 cellspacing=2>
	    <tr>
	      <td class=rowtitle align=center>
		#intranet-workflow.Admin_workflows#
	      </td>
	    </tr>
	    <tr>
	      <td>
		<ul>
	        @admin_html;noquote@
		</ul>
	      </td>
	    </tr>
	    </table>
</if>

    <%= [im_component_bay right] %>

  </td>
</tr>
<tr>
  <td colspan=3>

    @workflow_home_inbox;noquote@
<!--	@workflow_home_component;noquote@ -->


    <%= [im_component_bay bottom] %>
  </td>
</tr>
</table>

