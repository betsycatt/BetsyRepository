<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*,java.io.*,java.text.SimpleDateFormat,java.util.Calendar" %>
<%
// *** Restrict Access To Page: Grant or deny access to this page
String MM_authorizedUsers="";
String MM_authFailedURL="logout.jsp?&message=session%20expired";
boolean MM_grantAccess=false;
if (session.getValue("MM_Username") != null && !session.getValue("MM_Username").equals("")) {
  if (true || (session.getValue("MM_UserAuthorization")=="") || 
          (MM_authorizedUsers.indexOf((String)session.getValue("MM_UserAuthorization")) >=0)) {
    MM_grantAccess = true;
  }
}
if (!MM_grantAccess) {
  String MM_qsChar = "?";
  if (MM_authFailedURL.indexOf("?") >= 0) MM_qsChar = "&";
  String MM_referrer = request.getRequestURI();
  if (request.getQueryString() != null) MM_referrer = MM_referrer + "?" + request.getQueryString();
  MM_authFailedURL = MM_authFailedURL + MM_qsChar + "accessdenied=" + java.net.URLEncoder.encode(MM_referrer);
  response.sendRedirect(response.encodeRedirectURL(MM_authFailedURL));
  return;
}
%>
<%@ include file="Connections/IDBGIS05_SUPPORT.jsp" %>
<%
SimpleDateFormat s = new SimpleDateFormat("dd-MMM-yyyy");
SimpleDateFormat t = new SimpleDateFormat("HH:mm");
%>
<%
session.setAttribute("isItDone", "1");
%>
<%
String stat = "";
stat = request.getParameter("stat");
if(stat==null) stat = "";
//if(stat.equals("0")) stat = " and I.status <> 1 ";
if(stat.equals("0")) stat = " and I.status = 0 ";
else if(stat.equals("")) stat = "";
else stat = " and I.status = " + stat;

String ku = request.getParameter("ku");
if(ku==null) ku = "";
if(!ku.equals("")) ku = " and KU.usid = '" + ku + "'";
%>
<%!
private static String getStatusDesc (String statusCode) {
	String statusDesc = statusCode;
	int stat = Integer.parseInt(statusCode);
    switch (stat) {
			case 0:  statusDesc = "In Work"; break;
            case 1:  statusDesc = "Closed"; break;
            case 2:  statusDesc = "Sent to QA"; break;
            case 3:  statusDesc = "Returned from QA"; break; 
			case 4:  statusDesc = "Case submitted";break;
			case 5:  statusDesc = "Awaiting IT quote ";break;
			case 7:  statusDesc = "IT Quote Issued";break; 
case 8:  statusDesc = "Investment approved";break; 
case 33: statusDesc = "IT Quote rejected";break;
			case 99:  statusDesc = "Case rejected";break;
            default: statusDesc = statusCode;break;
        }
	return statusDesc;
	}
%>
<%!
private static String getPriority (String priority) {
	String priorityDesc = priority;
	int stat = Integer.parseInt(priorityDesc);
    switch (stat) {
			case 1:  priorityDesc = "Urgent"; break;
            case 2:  priorityDesc = "High Priority"; break;
            case 3:  priorityDesc = "Normal case"; break;
            case 4:  priorityDesc = "Low Priority"; break;
			case 5:  priorityDesc = "On hold"; break;
            default: priorityDesc = priority;break;
        }
	return priorityDesc;
	}
%>
<%
String dept = request.getParameter("dept");
if(dept==null) dept = "";
if(!dept.equals("")) dept = " and I.department = '" + dept + "'";
%>
<%
String rsMyCases__MMColParm1 = "1";
if (session.getAttribute("MM_Username") !=null) {rsMyCases__MMColParm1 = (String)session.getAttribute("MM_Username");}
%>
<%
String rsMyCases__MMColParm2 = "1";
if (session.getAttribute("MM_Username")  !=null) {rsMyCases__MMColParm2 = (String)session.getAttribute("MM_Username") ;}
%>
<%
String rsMyCases__MMColParm3 = "1";
if (session.getAttribute("MM_Username")  !=null) {rsMyCases__MMColParm3 = (String)session.getAttribute("MM_Username") ;}
%>
<%
String rsMyCases__MMColParm4 = "1";
if (session.getAttribute("KeyUserGroup")  !=null) {rsMyCases__MMColParm4 = (String)session.getAttribute("authority") ;}
%>
<%
Driver DriverrsMyCases = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsMyCases = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);

PreparedStatement StatementrsMyCases = null;

String auth1 = (String)session.getAttribute("authority"); if(auth1==null) auth1 = "";
auth1 = auth1.trim();



String viewtype = (String)session.getAttribute("viewtype");
if(viewtype==null) viewtype = request.getParameter("viewtype");
if(viewtype==null) viewtype = "0";

String caseno = request.getParameter("caseno");
if(caseno==null) caseno = "";
String casename = request.getParameter("txtSearch");
if(casename==null) casename = "";
if(casename.equals("Search by case name")) casename = "";
casename = casename.toLowerCase().trim();
if(!casename.equals("")) {
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname, KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid left join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE lower(I.casename) like '%" + casename + "%' order by I.status, I.priority, I.issue_number desc");
}
else if(!caseno.equals("")) {
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname, KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid left join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE I.issue_number = " + caseno + " order by I.status, I.priority, I.issue_number desc");
}
else if(!dept.equals("")) {
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname,KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid left join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE 1 = 1 " + stat + dept + " order by I.status, I.priority, I.issue_number desc");
} else if(!ku.equals("")) {
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname,KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid inner join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE 1 = 1 " + stat + ku + " order by I.status, I.priority, I.issue_number desc");
}
else if (viewtype.equals("2") ) { // All Cases
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname,KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid left join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE 1 = 1 " + stat + " order by I.status, I.priority, I.issue_number desc");
}
else if(viewtype.equals("1")) { // My dept (key user dept) + anything they did themselves
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname,KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid left join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE (U.keyuser = ? or I.assignedTo = ? or U.usid = ? or U.department = ?) " + stat + " order by I.status, I.priority, I.issue_number desc");
StatementrsMyCases.setObject(1, rsMyCases__MMColParm1);
StatementrsMyCases.setObject(2, rsMyCases__MMColParm2);
StatementrsMyCases.setObject(3, rsMyCases__MMColParm3);
StatementrsMyCases.setObject(4, rsMyCases__MMColParm4);
} else { // just stuff they did themselves - default
StatementrsMyCases = ConnrsMyCases.prepareStatement("SELECT *, ITU.firstname as ITfirstname, ITU.surname as ITsurname,KU.firstname as KUfirstname, KU.surname as KUsurname FROM incident as I inner join users as U on I.submittedBy = U.usid left join users as KU on U.keyuser = KU.usid inner join Status as S on I.status = S.status left join users as ITU on I.assignedTo = ITU.usid WHERE (U.keyuser = ? or I.assignedTo = ? or U.usid = ?) " + stat + " order by I.status, I.priority, I.issue_number desc");
StatementrsMyCases.setObject(1, rsMyCases__MMColParm1);
StatementrsMyCases.setObject(2, rsMyCases__MMColParm2);
StatementrsMyCases.setObject(3, rsMyCases__MMColParm3);
}
ResultSet rsMyCases = StatementrsMyCases.executeQuery();
//System.out.print("we executed the query");
boolean rsMyCases_isEmpty = !rsMyCases.next();
boolean rsMyCases_hasData = !rsMyCases_isEmpty;
Object rsMyCases_data;
int rsMyCases_numRows = 0;
%>
<%
int Repeat1__numRows = 100;
int Repeat1__index = 0;
rsMyCases_numRows += Repeat1__numRows;
%>
<% String MM_paramName = ""; %>
<%
// *** Go To Record and Move To Record: create strings for maintaining URL and Form parameters

String MM_keepBoth,MM_keepURL="",MM_keepForm="",MM_keepNone="";
String[] MM_removeList = { "index", MM_paramName };

// create the MM_keepURL string
if (request.getQueryString() != null) {
  MM_keepURL = '&' + request.getQueryString();
  for (int i=0; i < MM_removeList.length && MM_removeList[i].length() != 0; i++) {
  int start = MM_keepURL.indexOf(MM_removeList[i]) - 1;
    if (start >= 0 && MM_keepURL.charAt(start) == '&' &&
        MM_keepURL.charAt(start + MM_removeList[i].length() + 1) == '=') {
      int stop = MM_keepURL.indexOf('&', start + 1);
      if (stop == -1) stop = MM_keepURL.length();
      MM_keepURL = MM_keepURL.substring(0,start) + MM_keepURL.substring(stop);
    }
  }
}

// add the Form variables to the MM_keepForm string
if (request.getParameterNames().hasMoreElements()) {
  java.util.Enumeration items = request.getParameterNames();
  while (items.hasMoreElements()) {
    String nextItem = (String)items.nextElement();
    boolean found = false;
    for (int i=0; !found && i < MM_removeList.length; i++) {
      if (MM_removeList[i].equals(nextItem)) found = true;
    }
    if (!found && MM_keepURL.indexOf('&' + nextItem + '=') == -1) {
      MM_keepForm = MM_keepForm + '&' + nextItem + '=' + java.net.URLEncoder.encode(request.getParameter(nextItem));
    }
  }
}

String tempStr = "";
for (int i=0; i < MM_keepURL.length(); i++) {
  if (MM_keepURL.charAt(i) == '<') tempStr = tempStr + "&lt;";
  else if (MM_keepURL.charAt(i) == '>') tempStr = tempStr + "&gt;";
  else if (MM_keepURL.charAt(i) == '"') tempStr = tempStr +  "&quot;";
  else tempStr = tempStr + MM_keepURL.charAt(i);
}
MM_keepURL = tempStr;

tempStr = "";
for (int i=0; i < MM_keepForm.length(); i++) {
  if (MM_keepForm.charAt(i) == '<') tempStr = tempStr + "&lt;";
  else if (MM_keepForm.charAt(i) == '>') tempStr = tempStr + "&gt;";
  else if (MM_keepForm.charAt(i) == '"') tempStr = tempStr +  "&quot;";
  else tempStr = tempStr + MM_keepForm.charAt(i);
}
MM_keepForm = tempStr;

// create the Form + URL string and remove the intial '&' from each of the strings
MM_keepBoth = MM_keepURL + MM_keepForm;
if (MM_keepBoth.length() > 0) MM_keepBoth = MM_keepBoth.substring(1);
if (MM_keepURL.length() > 0)  MM_keepURL = MM_keepURL.substring(1);
if (MM_keepForm.length() > 0) MM_keepForm = MM_keepForm.substring(1);
%>
<% //System.out.print("we executed the query xxx"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><!-- InstanceBegin template="/Templates/support.dwt" codeOutsideHTMLIsLocked="false" -->
<%
String auth = (String)session.getAttribute("authority"); if(auth==null) auth = "";
auth = auth.trim();
%>
<!-- DW6 --> 
<head>
<!-- Copyright 2005 Macromedia, Inc. All rights reserved. -->

<!-- InstanceBeginEditable name="doctitle" -->
<% //System.out.print("we executed the query ttt"); %>
<title>IDB Support Centre</title>
<!-- InstanceEndEditable -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script language="JavaScript" type="text/javascript">
//--------------- LOCALIZEABLE GLOBALS ---------------
var d=new Date();
var monthname=new Array("January","February","March","April","May","June","July","August","September","October","November","December");
//Ensure correct for language. English is "January 1, 2004"
var TODAY = monthname[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear();
//---------------   END LOCALIZEABLE   ---------------
</script>
<!-- InstanceBeginEditable name="head" -->
<script src="SpryAssets/SpryValidationTextField.js" type="text/javascript"></script>
		<style type="text/css" media="screen">
			body {
				font: 11px arial;
			}
			.suggest_link {
				background-color: #FFFFFF;
				padding: 2px 6px 2px 6px;
			}
			.suggest_link_over {
				background-color: #3366CC;
				padding: 2px 6px 2px 6px;
			}
			#search_suggest {
				position: absolute; 
				background-color: #FFFFFF; 
				text-align: left; 
				border: 1px solid #000000;			
			}		
		</style>
		<script language="JavaScript" type="text/javascript" src="ajax_search.js"></script>

<style type="text/css">
<!--
.style2 {font-weight: bold}
-->
</style>
<link href="SpryAssets/SpryValidationTextField.css" rel="stylesheet" type="text/css" />
<!-- InstanceEndEditable -->

<style type="text/css">
<!--
body {
	background-image: url();
	background-repeat: repeat;
	background-color: #E5E7F3;
	margin-top: 10px;
}
body,td,th {
	color: #303356;
	font-size: 14px;
}
.style1 {	color: #FFFFFF;
	font-weight: bold;
}
-->
</style>
<link rel="stylesheet" href="Styles/CSI.css" type="text/css" />
<link rel="stylesheet" href="Styles/fidb/fidb.css" />
<link rel="stylesheet" href="Styles/bluedream.css" />
<style type="text/css">
<!--
.style2 {font-size: 18px}
-->
</style>
</head>
<body>
<!-- InstanceBeginEditable name="HEADeditable" --><!-- InstanceEndEditable -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr bgcolor="#3366CC">
    <td colspan="3" rowspan="2" bgcolor="#3B5998"></td>
    <td height="63" align="center" valign="bottom" nowrap="nowrap" bgcolor="#3B5998" id="logo"><div align="center"><span class="style1"><br />
        <span class="style2">ISACC - <%= session.getAttribute("department") %> (Key User <%= session.getAttribute("keyuser") %></span></span> )</div></td>
  </tr>
  <tr bgcolor="#3366CC">
    <td height="37" align="center" valign="top" bgcolor="#3B5998" class="style2" id="tagline"><div align="center">IDB Support and Control Centre
      </div>
      <div align="center"><font color="#FFFFFF">
        <strong>
        
        <%= session.getAttribute("sn") %>
        <%= session.getAttribute("givenName") %>
        <%= session.getAttribute("company") + " - " + session.getAttribute("division") %>
        <% System.out.print("did the company"); %>
        <script language="JavaScript" type="text/javascript">
      document.write(TODAY);	</script>
      </font> <span class="style1"> </span></div></td>
  </tr>
  <tr>
    <td colspan="4" bgcolor="#303356"><img src="images/mm_spacer.gif" alt="" width="1" height="1" border="0" /></td>
  </tr>
  <tr>
    <td colspan="4" bgcolor="#303356"><img src="images/mm_spacer.gif" alt="" width="1" height="1" border="0" /></td>
  </tr>
  <tr>
    <td width="15"><br/></td>
    <td colspan="3"><img src="images/mm_spacer.gif" alt="" width = "*" height="1" border="0" /><br />
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td class="bodyText">
              <div align="center">
                <%
            String stat1 = request.getParameter("stat");
            if(stat1==null) stat1 = "";
            %>
          
 <a href="newcase.jsp" class="fbtab<% if(request.getRequestURI().endsWith("newcase.jsp")) out.print("2"); %>">Report new case</a> 
                                         
      
   <% if(auth.equals("IT")) { %>
                             <a href="customerforum.jsp" class="fbtab<% if(request.getRequestURI().endsWith("customerforum.jsp")) out.print("2"); %>">Customer forum (<%= session.getAttribute("custForumTot") %>) </a>
                             <a href="admin.jsp" class="fbtab">Admin</a>
                <% } %>
                
                                                   
                <a href="cases.jsp?&amp;stat=0" class="fbtab<% if(stat1.equals("0")) out.print("2"); %>">In Work
                <% if(session.getAttribute("totOpen")!=null) out.print("(" + session.getAttribute("stat0") + ")"); %>
                </a>
                <% System.out.print("did totopen"); %>

                

                
                
                <a href="cases.jsp?&amp;stat=4" class="fbtab<% if(stat1.equals("4")) out.print("2"); %>">Awaiting Key User 
                <% if(session.getAttribute("stat4")!=null) out.print("(" + session.getAttribute("stat4") + ")"); %>
                </a>
                
                <a href="cases.jsp?&amp;stat=7" class="fbtab<% if(stat1.equals("7")) out.print("2"); %>">Awaiting Investment 
                <% if(session.getAttribute("stat7")!=null) out.print("(" + session.getAttribute("stat7") + ")"); %>
                </a>
                
                <a href="cases.jsp?&amp;stat=5" class="fbtab<% if(stat1.equals("5")) out.print("2"); %>">Awaiting IT quote 
                <% if(session.getAttribute("stat5")!=null) out.print("(" + session.getAttribute("stat5") + ")"); %>
                </a>
           
                
                <a href="cases.jsp?&stat=2" class="fbtab<% if(stat1.equals("2")) out.print("2"); %>">Sent to QA 
                <% if(session.getAttribute("stat2")!=null) out.print("(" + session.getAttribute("stat2") + ")"); %>
                </a>
                
                <a href="cases.jsp?&stat=3" class="fbtab<% if(stat1.equals("3")) out.print("2"); %>">Returned from QA 
                <% if(session.getAttribute("stat3")!=null) out.print("(" + session.getAttribute("stat3") + ")"); %>
                </a>
                
                
                <% System.out.print("did stat3"); %>
                
                             <a href="cases.jsp?&stat=1" class="fbtab<% if(stat1.equals("1")) out.print("2"); %>">Closed cases 
                             <% if(session.getAttribute("stat1")!=null) out.print("(" + session.getAttribute("stat1") + ")"); %>
                </a>
                
                             <a href="kpibar.jsp" class="fbtab<% if(request.getRequestURI().endsWith("kpi.jsp")) out.print("2"); %>">KPIs</a>
                
                            <a href="pref.jsp" class="fbtab<% if(request.getRequestURI().endsWith("pref.jsp")) out.print("2"); %>">Preferences</a>
                
                <a href="logout.jsp" class="fbtab">Logout</a><br />
                <% System.out.print("did logotu"); %>
                <br />
            </div></td>
          </tr>
          <tr>
            <td class="bodyText">&nbsp;<!-- InstanceBeginEditable name="MainSection" -->
        <form id="frmFilter" name="frmFilter" method="post" action="setup2.jsp">
        
                                                  <span id="spryCasename">
                                          <label>
				<input name="txtSearch" type="text" id="txtSearch" onkeyup="searchSuggest();" size="40"  alt="Search Criteria" width="40" autocomplete="off"/>
				<div id="search_suggest">
				</div>
                                          </label>
              <span class="textfieldMaxCharsMsg">Exceeded maximum number of characters.</span></span>
              
              
        <label>
                    <select name="viewtype" id="viewtype">
                      <option value="0" selected="selected" <%=(("0".toString().equals(((session.getValue("viewtype")!=null)?session.getValue("viewtype"):"")))?"selected=\"selected\"":"")%>>My Cases</option>
                      <option value="1" <%=(("1".toString().equals(((session.getValue("viewtype")!=null)?session.getValue("viewtype"):"")))?"selected=\"selected\"":"")%>>My Department Cases</option>
                      <option value="2" <%=(("2".toString().equals(((session.getValue("viewtype")!=null)?session.getValue("viewtype"):"")))?"selected=\"selected\"":"")%>>All Cases</option>
                    </select>
              </label>
                    <input name="message" type="hidden" id="message" value="<%= ((request.getParameter("message")!=null)?request.getParameter("message"):"") %>" />
                                          <input name="stat" type="hidden" id="stat" value="<%= ((request.getParameter("stat")!=null)?request.getParameter("stat"):"") %>" />
                                          <input name="dept" type="hidden" id="dept" value="<%= ((request.getParameter("dept")!=null)?request.getParameter("dept"):"") %>" />
                                          <label>
                                          <input name="btnFilter" type="submit" class="smallText" id="btnFilter" value="Search" />
                                          </label>
                                          <label><span id="spryCaseno">
                                          <input name="caseno" type="text" id="caseno" size="20" maxlength="5" />
                                          <span class="textfieldMaxCharsMsg">Exceeded maximum number of characters.</span><span class="textfieldInvalidFormatMsg">Invalid format.</span></span></label>

        </form>
        

            <p class="fbinfobox">
              <% if ( (request.getParameter("stat")==null) || (request.getParameter("stat").equals(""))  ) { %>
              
              All my cases
              
              <% } else { %>
              
               <%= ((request.getParameter("message")!=null)?request.getParameter("message") + " - ":"") %>My 
              
              <%= getStatusDesc(request.getParameter("stat")) %>
              
              
              
               cases
               
<% } %>

              <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
  <script>
         $(document).ready(function() {     $('#search').keyup(function()     {         searchTable($(this).val());     }); });   function searchTable(inputVal) {     var table = $('#tblData');     table.find('tr').each(function(index, row)     {         var allCells = $(row).find('td');         if(allCells.length > 0)         {             var found = false;             allCells.each(function(index, td)             {                 var regExp = new RegExp(inputVal, 'i');                 if(regExp.test($(td).text()))                 {                     found = true;                     return false;                 }             });             if(found == true)$(row).show();else $(row).hide();         }     }); } 
 </script>
          <span class="pageName"><br /></span>
          <label for="search">             <strong>Filter the list below</strong>         </label>         <input type="text" id="search"/>
            </p>
            <% if (!rsMyCases_isEmpty ) { %>
        
              <table id="tblData" width="99%" border="0" class="BD">
              <thead>
                <tr>
                  <td><strong>Case Details</strong></td>
                  <td><strong>Priority</strong></td>
                  <td><strong>Submitted</strong></td>
                  <td><strong>By</strong></td>
                  <td><strong>attachment(s)</strong></td>
                  <td><strong>
                  <%
                  if(stat1.equals("4")) { %>
                  
                  Awaiting Key User Approval
                  <% } else { %>
                  
                  Assigned to IT responsible
                  <% } %>
                  </strong></td>
                  <td><strong>Incident Number</strong></td>
                  <td><strong>Status</strong></td>
                </tr>
               </thead>
               <tbody>
                <% while ((rsMyCases_hasData)&&(Repeat1__numRows-- != 0)) { %>
                  <tr>
                    <td><strong>
                    
                    <a href="caseDetails.jsp?<%= MM_keepNone + ((MM_keepNone!="")?"&":"") + "no=" + (((rsMyCases_data = rsMyCases.getObject("issue_number"))==null || rsMyCases.wasNull())?"":rsMyCases_data) %>"><%=(((rsMyCases_data = rsMyCases.getObject("casename"))==null || rsMyCases.wasNull())?"":rsMyCases_data)%></a>
                    
                    
                    </strong><br />
                        <br />
                    </td>
                    <td><%=(((rsMyCases_data = rsMyCases.getObject("priority"))==null || rsMyCases.wasNull())?"":getPriority(rsMyCases_data.toString()))%></td>
                    <td>

<%= s.format(rsMyCases.getDate("date_submitted")) %> <%= t.format(rsMyCases.getTime("date_submitted")) %>                    </td>
                    <td><%=(((rsMyCases_data = rsMyCases.getObject("firstname"))==null || rsMyCases.wasNull())?"":rsMyCases_data)%> <%=(((rsMyCases_data = rsMyCases.getObject("surname"))==null || rsMyCases.wasNull())?"":rsMyCases_data)%></td>
                    <td><%
File dir = new File(uploadFol + rsMyCases.getString("issue_number")); 
String[] children = dir.list(); 
if (children == null) { out.print("&nbsp;"); } else { 
	for (int i=0; i<children.length; i++) { %>
	 <a href="uploads/<%= rsMyCases.getString("issue_number").trim() %>/<%= children[i].trim() %>" target="_blank">
	 <%= children[i] %>     </a>
     <br/> 
	<% } 
} 
					
					%></td>
                    <td>
                    <%
					if(stat1.equals("4")) { %>
                    
                    <% if(rsMyCases.getString("KUfirstname")!=null) { %> 
					<%= rsMyCases.getString("KUfirstname") %> <%= rsMyCases.getString("KUsurname") %>
					<% } %>
                    <% } else { %>
                  <%

					if ( (rsMyCases.getString("assignedTo")!=null) && (!rsMyCases.getString("assignedTo").trim().equals("unassigned")) ){ %>
                      <%= rsMyCases.getString("ITfirstname") + " " + rsMyCases.getString("ITsurname") %>
                    <% } else { %>
                    Not yet assigned
                    <% } }%>                    </td>
                    <td><%=(((rsMyCases_data = rsMyCases.getObject("issue_number"))==null || rsMyCases.wasNull())?"":rsMyCases_data)%></td>
                    <td>
					<%= getStatusDesc(rsMyCases.getString("status")) %>                    </td>
                  </tr>
                  <%
  Repeat1__index++;
  rsMyCases_hasData = rsMyCases.next();
}
%>
			</tbody>
              </table>
                <% } /* end !rsMyCases_isEmpty */ %>
<% if (rsMyCases_isEmpty ) { %>
                  No 
  <%
			  
			  if( (request.getParameter("stat")!=null) && (request.getParameter("stat").equals("0")) ) 
			  	out.print("Open");
			  else if( (request.getParameter("stat")!=null) && (request.getParameter("stat").equals("2")) ) 
			  	out.print("QA");
				else
			  	out.print("Completed");
			  
			  
			  %>
cases at the moment
  <% } /* end rsMyCases_isEmpty */ %>
                        <script type="text/javascript">
<!--
var sprytextfield1 = new Spry.Widget.ValidationTextField("spryCaseno", "integer", {hint:"Search by Case #", minChars:0, maxChars:5, isRequired:false, useCharacterMasking:true});
var sprytextfield2 = new Spry.Widget.ValidationTextField("spryCasename", "none", {hint:"Search by case name", minChars:0, maxChars:150, isRequired:false});
//-->
</script>
            <!-- InstanceEndEditable --></td>
          </tr>
        </table>
        
      <br />    </td>
  </tr>
</table>
</body>
<!-- InstanceEnd --></html>
<%
rsMyCases.close();
StatementrsMyCases.close();
ConnrsMyCases.close();
%>
<%
System.out.print("dont with cases! i mean done..!");
%>
<%
session.setAttribute("isItDone", "0");
%>