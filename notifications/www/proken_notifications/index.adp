

<if @comp@ eq "my_tasks">

<TABLE border=\"5\" frame=\"border\" rules=\"all\" width='100%'>

	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	      
	<meta http-equiv="Content-Style-Type" content="text/css">
	<meta http-equiv="Content-Script-Type" content="text/javascript">
	<title>
	Google Visualization API Sample
	</title>
    
    
    
    <script type="text/javascript">
	    var runCount = 0;
	    var runCount1 = 0;
		$(document).ready(function() {
			drawVisualization8();



			// tabs3
				$(".tab_content3").hide(); //Hide all content
				$("ul.tabs3 li:first").addClass("active").show(); //Activate first tab
				$(".tab_content3:first").show(); //Show first tab content

				//On Click Event
				$("ul.tabs3 li").click(function() {

					$("ul.tabs3 li").removeClass("active"); //Remove any "active" class
					$(this).addClass("active"); //Add "active" class to selected tab
					$(".tab_content3").hide(); //Hide all tab content

					var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
					if (($(this).find("a").attr("href")) == "#tab7") {
						runCount1=0;
						drawVisualization7();
					}
					if (($(this).find("a").attr("href")) == "#tab8") {
						runCount1=0;
						drawVisualization8();
					}
					if (($(this).find("a").attr("href")) == "#tab9") {
						runCount1=0;
						drawVisualization9();
					}
					if (($(this).find("a").attr("href")) == "#tab10") {
						runCount1=0;
						drawVisualization10();
					}
					$(activeTab).fadeIn(); //Fade in the active ID content
					return false;
				});


		});
    </script>
        
        
    <link rel="stylesheet" href="jquery.tabs.css" type="text/css" media="print, projection, screen">
    <style type="text/css" media="screen, projection">


		/* tabs3 */
			ul.tabs3 {
				margin: 0;
				padding: 0;
				float: left;
				list-style: none;
				height: 32px; /*--Set height of tabs3--*/
				border-bottom: 1px solid #f4f9fb;
				border-left: 1px solid #f4f9fb;
				width: 100%;
			}
			ul.tabs3 li {
				float: left;
				margin: 0;
				padding: 0;
				height: 31px; /*--Subtract 1px from the height of the unordered list--*/
				line-height: 31px; /*--Vertically aligns the text within the tab--*/
				border: 1px solid #999;
				border-left: none;
				margin-bottom: -1px; /*--Pull the list item down 1px--*/
				overflow: hidden;
				position: relative;
				background: #f4f9fb;
			}
			ul.tabs3 li a {
				text-decoration: none;
				color: #000;
				display: block;
				font-size: 1.2em;
				padding: 0 20px;
				border: 1px solid #f4f9fb; /*--Gives the bevel look with a 1px white border inside the list item--*/
				outline: none;
			}
			ul.tabs3 li a:hover {
				background: #ccc;
			}
			html ul.tabs3 li.active, html ul.tabs3 li.active a:hover  { /*--Makes sure that the active tab does not listen to the hover properties--*/
				background: #A3D6FA;
				border-bottom: 1px solid #f4f9fb; /*--Makes the active tab look like it's connected with its content--*/
			}
			.tab_content3 {
				padding: 20px;
				font-size: 1.2em;
			}


		/* Tab Container */
			.tab_container {
				border: 1px solid #999;
				border-top: none;
				overflow: hidden;
				clear: both;
				float: left; width: 100%;
				background: #f4f9fb;
				width:100%
			}

    </style>


	<tr>
		<td style="background: #dcf2f9;" align='center'><b>My Tasks</b></td>
		
	</tr>

	<tr>
		<!-- My Tasks -->
			<td style="background: #dcf2f9;" width=100%>        
				<ul class="tabs3">
					<li><a href="#tab7">Due Today</a></li>
				    <li><a href="#tab8">Over Due</a></li>
				    <li><a href="#tab9">ForthComing</a></li>
				    <li><a href="#tab10">All Tasks</a></li>
				</ul>
				<div class="tab_container">
					<div id="tab7" class="tab_content3" style="background: #f4f9fb;">
				       	<div id="visual_top_profit" style="width: 550px; height: 150px;">
				       		@out_table7;noquote@
				       	</div>
				       	<p align=right><a href="/intranet-reporting/project-profitability?flag2=1"  >See more ....</a></p>
				    </div>
				    <div id="tab8" class="tab_content3" style="background: #f4f9fb;">
				       <div id="visual_bottom_profit" style="width: 550px; height: 150px;">
				       	@out_table8;noquote@
				       </div>
				       <p align=right><a href="/intranet-reporting/project-profitability?flag2=1"  >See more ....</a></p>
				    </div>
				    <div id="tab9" class="tab_content3" style="background: #f4f9fb;">
					       <div id="visual_task9" style="width: 550px; height: 150px;">
					       	@out_table9;noquote@
					       </div>
					       <p align=right><a href="/intranet-reporting/project-profitability?flag2=1"  >See more ....</a></p>
					</div>
				    <div id="tab10" class="tab_content3" style="background: #f4f9fb;">
					       <div id="visual_task10" style="width: 550px; height: 150px;">
					       	@out_table10;noquote@
					       </div>
					      <p align=right><a href="/intranet-reporting/project-profitability?flag2=1&flag3=1"  >See more ....</a></p>
				    </div>
				</div>
			</td>
	</tr>
	</TABLE>




<script type="text/javascript">
      google.load('assigned_tasks_1', '1', 
        {packages: ['columnchart']});
    </script>
    <script type="text/javascript">
      function drawVisualization1() {
    
      }
//      google.setOnLoadCallback(drawVisualization);
    </script>


    <script type="text/javascript">
      google.load('assigned_tasks_2', '1', 
        {packages: ['columnchart']});
    </script>
    <script type="text/javascript">
      function drawVisualization2() {
    
      }
//      google.setOnLoadCallback(drawVisualization);
    </script>




    <script type="text/javascript">
      google.load('assigned_tasks_3', '1', 
        {packages: ['columnchart']});
    </script>
    <script type="text/javascript">
      function drawVisualization3() {
    
      }
//      google.setOnLoadCallback(drawVisualization);
    </script>

    <!--  PROFITABILITY BOTTOM 5  -->
    <script type="text/javascript">
      google.load('assigned_tasks_4', '1', 
        {packages: ['columnchart']});
    </script>
    <script type="text/javascript">
      function drawVisualization4() {
    
      }
//      google.setOnLoadCallback(drawVisualization);
    </script>







</if>

<if @comp@ eq "tasks_by_me">


<TABLE border=\"5\" frame=\"border\" rules=\"all\" width='100%'>

	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	      
	<meta http-equiv="Content-Style-Type" content="text/css">
	<meta http-equiv="Content-Script-Type" content="text/javascript">
	<title>
	Google Visualization API Sample
	</title>
    
    
    
    <script type="text/javascript">
	    var runCount = 0;
	    var runCount1 = 0;
		$(document).ready(function() {
			drawVisualization1();



			// tabs2
				$(".tab_content2").hide(); //Hide all content
				$("ul.tabs2 li:first").addClass("active").show(); //Activate first tab
				$(".tab_content2:first").show(); //Show first tab content

				//On Click Event
				$("ul.tabs2 li").click(function() {

					$("ul.tabs2 li").removeClass("active"); //Remove any "active" class
					$(this).addClass("active"); //Add "active" class to selected tab
					$(".tab_content2").hide(); //Hide all tab content

					var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
					if (($(this).find("a").attr("href")) == "#tab1") {
						runCount1=0;
						drawVisualization1();
					}
					if (($(this).find("a").attr("href")) == "#tab2") {
						runCount1=0;
						drawVisualization2();
					}
					if (($(this).find("a").attr("href")) == "#tab3") {
						runCount1=0;
						drawVisualization3();
					}
					if (($(this).find("a").attr("href")) == "#tab4") {
						runCount1=0;
						drawVisualization4();
					}
					$(activeTab).fadeIn(); //Fade in the active ID content
					return false;
				});



		});
    </script>
        
        
    <link rel="stylesheet" href="jquery.tabs.css" type="text/css" media="print, projection, screen">
    <style type="text/css" media="screen, projection">


		


		/* tabs2 */
			ul.tabs2 {
				margin: 0;
				padding: 0;
				float: left;
				list-style: none;
				height: 32px; /*--Set height of tabs2--*/
				border-bottom: 1px solid #f4f9fb;
				border-left: 1px solid #f4f9fb;
				width: 100%;
				
			}
			ul.tabs2 li {
				float: left;
				margin: 0;
				padding: 0;
				height: 31px; /*--Subtract 1px from the height of the unordered list--*/
				line-height: 31px; /*--Vertically aligns the text within the tab--*/
				border: 1px solid #f4f9fb;
				border-left: none;
				margin-bottom: -1px; /*--Pull the list item down 1px--*/
				overflow: hidden;
				position: relative;
				background: #f4f9fb;
			}
			ul.tabs2 li a {
				text-decoration: none;
				color: #000;
				display: block;
				font-size: 1.2em;
				padding: 0 20px;
				border: 1px solid #f4f9fb; /*--Gives the bevel look with a 1px white border inside the list item--*/
				outline: none;
				color: black;
				-webkit-border-top-left-radius: 15px;
		  -webkit-border-top-right-radius: 15px;
		  -moz-border-radius-topleft: 15px;
		  -moz-border-radius-topright: 15px;
		  border-top-left-radius: 15px;
		  border-top-right-radius: 15px; 
			}
			ul.tabs2 li a:hover {
				background: #ccc;
			}
			html ul.tabs2 li.active, html ul.tabs2 li.active a:hover  { /*--Makes sure that the active tab does not listen to the hover properties--*/
				background: #A3D6FA;
				border-bottom: 1px solid #f4f9fb; /*--Makes the active tab look like it's connected with its content--*/
			}
			.tab_content2 {
				padding: 20px;
				font-size: 1.2em;
			}




		/* Tab Container */
			.tab_container {
				border: 1px solid #999;
				border-top: none;
				overflow: hidden;
				clear: both;
				float: left; width: 100%;
				background: #f4f9fb;
				width:100%

			}

    </style>

<tr>
		
		<td style="background: #dcf2f9;" align='center'><b>Tasks Assigned By Me</b></td>
	</tr>
	<tr>

		<!-- Tasks Assigned By Me -->
			<td style="background: #dcf2f9;" width=100%>        
				<ul class="tabs2">
					<li><a href="#tab1">Due Today</a></li>
				     <li><a href="#tab2">Over Due</a></li>
				    <li><a href="#tab3">ForthComing</a></li>
				    <li><a href="#tab4">All Tasks</a></li>
				</ul>
				<div class="tab_container">
					<div id="tab1" class="tab_content2" style="background: #f4f9fb;">
				       <div id="assigned_tasks_1" style="width: 550px; height: 150px;">
				       	@out_table1;noquote@
				       </div>
				       <p align=right><a href="/intranet-reporting/project-profitability?flag2=1"  >See more ....</a></p>
				    </div>
				    <div id="tab2" class="tab_content2" style="background: #f4f9fb;">
				       <div id="assigned_tasks_2" style="width: 550px; height: 150px;">
				       	@out_table2;noquote@
				       </div>
				       <p align=right><a href="/intranet-reporting/project-profitability?flag2=1"  >See more ....</a></p>
				    </div>
				    <div id="tab3" class="tab_content2" style="background: #f4f9fb;">
					       <div id="assigned_tasks_3" style="width: 550px; height: 150px;">
					       	@out_table3;noquote@
					       </div>
					       <p align=right><a href="/intranet-reporting/project-profitability?flag2=1"  >See more ....</a></p>
					</div>
				    <div id="tab4" class="tab_content2" style="background: #f4f9fb;">
					       <div id="assigned_tasks_4" style="width: 550px; height: 150px;">
					       	@out_table4;noquote@
					       </div>
					      <p align=right><a href="/intranet-reporting/project-profitability?flag2=1&flag3=1"  >See more ....</a></p>
				    </div>
				</div>
			</td>
	</tr>
</TABLE>



<script type="text/javascript" 
     src="http://www.google.com/jsapi">
</script>
  
<script type="text/javascript">
      google.load('visual_top_profit', '1', 
        {packages: ['columnchart']});
</script>
<script type="text/javascript">
      function drawVisualization7() {
    	}    
</script>
<script type="text/javascript">
      google.load('visual_bottom_profit', '1', 
        {packages: ['columnchart']});
    </script>
    <script type="text/javascript">
      function drawVisualization8() {
    
      }
</script>
<script type="text/javascript">
      google.load('visual_task9', '1', 
        {packages: ['columnchart']});
</script>
<script type="text/javascript">
      function drawVisualization9() {
    
      }
</script>
<script type="text/javascript">
      google.load('visual_task10', '1', 
        {packages: ['columnchart']});
</script>
<script type="text/javascript">
      function drawVisualization10() {
    
      }
</script>
</if>
















    

