<%= [im_header $title $header_stuff] %>
<div id="ajax-status-message" style="display: none;"> </div>
<if @user_feedback_txt@ ne "">
        <script type="text/javascript"><!--
	<if @user_feedback_link@ ne "">
		  $('#ajax-status-message').html('<a href=\'@user_feedback_link@\'>@user_feedback_txt@</a>').removeClass('success-notice').addClass('error-notice').show().delay(8000).fadeOut();
	</if>
	<else>
		  $('#ajax-status-message').html('@user_feedback_txt@').removeClass('success-notice').addClass('error-notice').show().delay(8000).fadeOut();
	</else>
	// --></script>
</if>

<%= [im_navbar -show_context_help_p $show_context_help_p $main_navbar_label] %>
<%= $sub_navbar %>


<if @show_left_navbar_p@>
	<div id="slave">
	<div id="slave_content">
	<div class="filter-list" id="filter-list">
		<a id="sideBarTab" href="#"><img id="sideBarTabImage" border="0" title="sideBar" alt="sideBar" src="/intranet/images/navbar_saltnpepper/slide-button-active.gif"/></a>
		<div class="filter" id="sidebar">
			<div id="sideBarContentsInner">
				<!-- Left Navigation Bar -->
				
				<!-- End Left Navigation Bar -->
				<%= [im_box_header Mintifications\ ] %>
						@mintification_html;noquote@
					<%= [im_box_footer] %>

				<if @show_filter@ >	
					<table width=245>
						<tr><td>
							<%= [im_box_header Filter\ ] %>
								 <%= $left_navbar %>
							<%= [im_box_footer] %>
						</td></tr>
					</table>
				</if>
					


					<%= [im_box_header Loudmouth\ ] %>
						@Loudmouth;noquote@
					<%= [im_box_footer] %>
					
						@quick_note;noquote@
						<br>

			</div>
		</div>
		<div class="fullwidth-list" id="fullwidth-list">
			<slave>
		</div>
	</div>
	</div>
	</div>
</if>
<else>
	<div class="fullwidth-list-no-side-bar" id="fullwidth-list">
		<slave>
	</div>
</else>

<%= [im_footer] %>
