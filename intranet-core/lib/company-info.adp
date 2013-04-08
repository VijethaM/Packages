
<table border=0 width="100%">
  <tr><td width="50%">
  <table>
    <tr class=rowodd>
      <td>#intranet-core.Name#</td>
      <td>@company_name;noquote@</td>
    </tr>
     <tr class=roweven>
      <td>#intranet-core.Status#</td>
      <td>@company_status;noquote@</td>
    </tr>
    <if @see_details@>
      <tr class=rowodd>
        <td>#intranet-core.Client_Type#</td>
        <td>@company_type;noquote@</td>
      </tr>
      <tr class=roweven>
        <td>#intranet-core.Phone#</td>
        <td>@phone;noquote@</td>
      </tr>
      <tr class=rowodd>
        <td>#intranet-core.Fax#</td>
        <td>@fax;noquote@</td>
      </tr>
      <tr class=roweven>
        <td>#intranet-core.Address1#</td>
        <td>@address_line1;noquote@</td>
      </tr>
      <tr class=rowodd>
        <td>#intranet-core.Address2#</td>
        <td>@address_line2;noquote@</td>
      </tr>
      <tr class=roweven>
        <td>#intranet-core.City#</td>
        <td>@address_city;noquote@</td>
      </tr>
     
      <if @some_american_readers_p@>
        <tr class=rowodd>
          <td>#intranet-core.State#</td>
          <td>@address_state;noquote@</td>
        </tr>
      </if>  

      <tr class=roweven>
        <td>#intranet-core.Postal_Code#</td>
        <td>@address_postal_code;noquote@</td>
      </tr>
      <tr class=rowodd>
        <td>#intranet-core.Country#</td>
        <td>@country_name;noquote@</td>
      </tr>
    </if>
    <if @site_concept@ not nil>
      <tr class=roweven>
        <td>#intranet-core.Web_Site#</td>
        <td><a href="@site_concept@">@site_concept;noquote@</a></td>
      </tr>
    </if>
    

    
    
    <tr class="rowodd">
      <td>#intranet-core.Start_Date#</td>
      <td>@start_date;noquote@</td>
    </tr>

    <if @note_p@>
      <tr @bgcolor@>
        <td>#intranet-core.Description#</td>
        <td><font size=-1>@note;noquote@</font></td>
      </tr>
    </if>
   



    <if @admin@>
      <tr>
        <td>&nbsp;</td>
        <td>
          <form action=new method=POST>
  	  <input type="hidden" name="company_id" value="@company_id@">
  	  <input type="hidden" name="return_url" value="@return_url@">
      <input type="hidden" name="flag" value=0>
            <input type="submit" value="#intranet-core.Edit#">
          </form>
        </td>
      </tr>
    </if>
  </table>
</td>
  <td rowspan=12  width="50%" align="center">
      <a href=  "/intranet/companies/new?company_id=@company_id@&form_mode=edit&flag=1"><img border="2px" width="150" height="150" src="/company_logo@company_logo@" alt="@company_name@" title="Change Logo" onmouseover="image_name.width='230';image_name.height='230';" onmouseout="image_name.width='150';image_name.height='150';image_name.border='2px';" name="image_name">
    </a>
  </td>
</tr>
</table>
