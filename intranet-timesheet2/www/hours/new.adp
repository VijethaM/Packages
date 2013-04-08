
<if @is_from_home_page@ eq 0>
	<%= [im_header -loginpage $page_title] %>
<%= [im_navbar -loginpage "home"] %>
</if>
<elseif @is_from_home_page@ eq 1>
<master> 
 <property name="title">@page_title@</property>
 <property name="context">#intranet-timesheet2.context#</property>
<!-- <property name="main_navbar_label">timesheet2_timesheet</property>-->
 <property name="left_navbar">@left_navbar_html;noquote@</property>
<!-- <property name="show_context_help_p">@show_context_help_p;noquote@</property> -->
</elseif>
<%= [im_box_header $page_title] %>
<form name=timesheet method=POST action=new-2.tcl>
@grand_tot_function;noquote@
@export_form_vars;noquote@

<table>

	  <if @edit_hours_p@ eq "f">
	  <tr>
		<td colspan=7>
		<font color=red>
		<h3>@edit_hours_closed_message;noquote@</h3>
		</font>
		</td>
	  </tr>
	  </if>

	  @forward_backward_buttons;noquote@

<if @ctr@>

	    <tr class=rowtitle>
		<td class=rowtitle><h3>#intranet-timesheet2.Project_name#</h3></td>
		<td class=rowtitle></td>

		<if @show_week_p@ eq 0>
		<th>#intranet-timesheet2.Hours#	</th>
		<th>#intranet-timesheet2.Work_done#</th>
<if @internal_note_exists_p@>
		<th><%= [lang::message::lookup "" intranet-timesheet2.Internal_Comment "Internal Comment"] %></th>
</if>
<if @materials_p@>
		<th><%= [lang::message::lookup "" intranet-timesheet2.Service_Type "Service Type"] %></th>
</if>
		</if>
		<else>
		@week_header_html;noquote@
		</else>
	    </tr> 
	    @results;noquote@
	    <tr>
		<td></td>
		<td colspan=99>
		
		<if @edit_hours_p@ eq "t">

		    <INPUT TYPE=Submit name=save VALUE="Save">
	    	<INPUT TYPE=Submit name=submit VALUE="Submit">
	    	
		</if>
		</td></tr>
		
	   

</if>
<else>
	<tr>
	<td>
	<%= [lang::message::lookup "" intranet-timesheet2.Not_Member_of_Projects "
	    You are not a member of any project where you could log your hours.<p>
	    Please contact the project manager of your project(s) to include you in 
	    the list of project members.
	"] %>
	</td>
	</tr>
</else>


</table>
</form>
<table><tr><td></td><td>@add_adhoc_html;noquote@</td></tr></table>

<%= [im_box_footer] %>
