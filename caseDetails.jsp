<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*,javazoom.upload.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.util.Calendar" errorPage="" %>
<%@ include file="Connections/IDBGIS05_SUPPORT.jsp" %>
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
<%
// *** Edit Operations: declare variables

// set the form action variable
String MM_editAction = request.getRequestURI();
if (request.getQueryString() != null && request.getQueryString().length() > 0) {
  String queryString = request.getQueryString();
  String tempStr = "";
  for (int i=0; i < queryString.length(); i++) {
    if (queryString.charAt(i) == '<') tempStr = tempStr + "&lt;";
    else if (queryString.charAt(i) == '>') tempStr = tempStr + "&gt;";
    else if (queryString.charAt(i) == '"') tempStr = tempStr +  "&quot;";
    else tempStr = tempStr + queryString.charAt(i);
  }
  MM_editAction += "?" + tempStr;
}

// connection information
String MM_editDriver = null, MM_editConnection = null, MM_editUserName = null, MM_editPassword = null;

// redirect information
String MM_editRedirectUrl = null;

// query string to execute
StringBuffer MM_editQuery = null;

// boolean to abort record edit
boolean MM_abortEdit = false;

// table information
String MM_editTable = null, MM_editColumn = null, MM_recordId = null;

// form field information
String[] MM_fields = null, MM_columns = null;
%>
<%
// *** Update Record: set variables

if (request.getParameter("MM_update") != null &&
    request.getParameter("MM_update").toString().equals("frmSubmittedBy") &&
    request.getParameter("MM_recordId") != null) {

  MM_editDriver     = MM_IDBGIS05_SUPPORT_DRIVER;
  MM_editConnection = MM_IDBGIS05_SUPPORT_STRING;
  MM_editUserName   = MM_IDBGIS05_SUPPORT_USERNAME;
  MM_editPassword   = MM_IDBGIS05_SUPPORT_PASSWORD;
  MM_editTable  = "dbo.incident";
  MM_editColumn = "issue_number";
  MM_recordId   = "" + request.getParameter("MM_recordId") + "";
  MM_editRedirectUrl = "caseDetails.jsp";
  String MM_fieldsStr = "submittedby|value";
  String MM_columnsStr = "submittedBy|',none,''";

  // create the MM_fields and MM_columns arrays
  java.util.StringTokenizer tokens = new java.util.StringTokenizer(MM_fieldsStr,"|");
  MM_fields = new String[tokens.countTokens()];
  for (int i=0; tokens.hasMoreTokens(); i++) MM_fields[i] = tokens.nextToken();

  tokens = new java.util.StringTokenizer(MM_columnsStr,"|");
  MM_columns = new String[tokens.countTokens()];
  for (int i=0; tokens.hasMoreTokens(); i++) MM_columns[i] = tokens.nextToken();

  // set the form values
  for (int i=0; i+1 < MM_fields.length; i+=2) {
    MM_fields[i+1] = ((request.getParameter(MM_fields[i])!=null)?(String)request.getParameter(MM_fields[i]):"");
  }

  // append the query string to the redirect URL
  if (MM_editRedirectUrl.length() != 0 && request.getQueryString() != null) {
    MM_editRedirectUrl += ((MM_editRedirectUrl.indexOf('?') == -1)?"?":"&") + request.getQueryString();
  }
}
%>
<%
// *** Update Record: construct a sql update statement and execute it

if (request.getParameter("MM_update") != null &&
    request.getParameter("MM_recordId") != null) {

  // create the update sql statement
  MM_editQuery = new StringBuffer("update ").append(MM_editTable).append(" set ");
  String[] MM_dbValues_prep = new String[MM_fields.length/2];
  for (int i=0; i+1 < MM_fields.length; i+=2) {
    String formVal = MM_fields[i+1];
    String elem;
    java.util.StringTokenizer tokens = new java.util.StringTokenizer(MM_columns[i+1],",");
    elem = (String)tokens.nextToken(); // consume the delim
    String altVal   = ((elem = (String)tokens.nextToken()) != null && elem.compareTo("none")!=0)?elem:"";
    String emptyVal = ((elem = (String)tokens.nextToken()) != null && elem.compareTo("none")!=0)?elem:"";
    if (formVal.length() == 0) {
        if(emptyVal.equals("NULL")) {
            formVal = null;
        } else if(emptyVal.charAt(0) == '\'') {
            formVal = emptyVal.substring(1, emptyVal.length()-1);
        } else {
            formVal = emptyVal;
        }
    } else if (altVal.length() != 0) {
        if(altVal.charAt(0) == '\'') {
            formVal = altVal.substring(1, altVal.length()-1);
        } else {
            formVal = altVal;
        }
    }
    MM_dbValues_prep[i/2] = formVal;
    MM_editQuery.append((i!=0)?",":"").append(MM_columns[i]).append(" = ?");
  }
  MM_editQuery.append(" where ").append(MM_editColumn).append(" = ?");
  
  if (!MM_abortEdit) {
    // finish the sql and execute it
    Driver MM_driver = (Driver)Class.forName(MM_editDriver).newInstance();
    Connection MM_connection = DriverManager.getConnection(MM_editConnection,MM_editUserName,MM_editPassword);
    PreparedStatement MM_editStatement = MM_connection.prepareStatement(MM_editQuery.toString());
    for(int i=0; i<MM_dbValues_prep.length; i++) {
        MM_editStatement.setObject(i+1, MM_dbValues_prep[i]);
    }
    MM_editStatement.setObject(MM_dbValues_prep.length+1, MM_recordId);
    MM_editStatement.executeUpdate();
    MM_connection.close();

    // redirect with URL parameters
    if (MM_editRedirectUrl.length() != 0) {
      response.sendRedirect(response.encodeRedirectURL(MM_editRedirectUrl));
      return;
    }
  }
}
%>
<script LANGUAGE="JavaScript">
<!--
function confirmPost(currentForm)
{
var newstatus = currentForm.newstatus.value;
var agree = true;
if (newstatus=="99") {
agree=confirm("Are you sure you want to reject this case?");
}
if (agree)
return true ;
else
return false ;
}
// -->

function limitText(limitField, limitCount, limitNum) {
	if (limitField.value.length > limitNum) {
		limitField.value = limitField.value.substring(0, limitNum);
	} else {
		limitCount.value = limitNum - limitField.value.length;
	}
}


</script>



<%
SimpleDateFormat s = new SimpleDateFormat("dd-MMM-yyyy");
SimpleDateFormat t = new SimpleDateFormat("HH:mm");
SimpleDateFormat full = new SimpleDateFormat("dd-MMM-yyyy HH:mm");
%>

<%
String no = request.getParameter("no"); if(no==null) no = "";
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
			case 5:  statusDesc = "Case approved ";break;
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
String rsIssueDetail__MMColParm1 = "1";
if (request.getParameter("no") !=null) {rsIssueDetail__MMColParm1 = (String)request.getParameter("no");}
%>
<%
Driver DriverrsIssueDetail = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsIssueDetail = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsIssueDetail = ConnrsIssueDetail.prepareStatement("SELECT type, priority, date_submitted, description, attachment, submittedBy, assignedTo, program, system, casename, issue_number, Charge_PO_Number, status, recreate_steps, UB.firstname, UB.surname, UIT.firstname as ITfirstname, UIT.surname as ITsurname FROM incident left join users as UB on submittedBy = UB.usid left join users as UIT on assignedTo = UIT.usid WHERE issue_number = ?");
StatementrsIssueDetail.setObject(1, rsIssueDetail__MMColParm1);
ResultSet rsIssueDetail = StatementrsIssueDetail.executeQuery();
boolean rsIssueDetail_isEmpty = !rsIssueDetail.next();
boolean rsIssueDetail_hasData = !rsIssueDetail_isEmpty;
Object rsIssueDetail_data;
int rsIssueDetail_numRows = 0;
%>
<%
String rsCaseNotes__MMColParm1 = "1";
if (request.getParameter("no") !=null) {rsCaseNotes__MMColParm1 = (String)request.getParameter("no");}
%>
<%
Driver DriverrsCaseNotes = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsCaseNotes = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsCaseNotes = ConnrsCaseNotes.prepareStatement("SELECT * FROM caseNotes C inner join users U on C.usid = U.usid  WHERE C.issue_no = ? ORDER BY date_submitted desc");
StatementrsCaseNotes.setObject(1, rsCaseNotes__MMColParm1);
ResultSet rsCaseNotes = StatementrsCaseNotes.executeQuery();
boolean rsCaseNotes_isEmpty = !rsCaseNotes.next();
boolean rsCaseNotes_hasData = !rsCaseNotes_isEmpty;
Object rsCaseNotes_data;
int rsCaseNotes_numRows = 0;
%>
<%
int Repeat1__numRows = -1;
int Repeat1__index = 0;
rsCaseNotes_numRows += Repeat1__numRows;
%>
<%
String rsTime__MMColParm1 = "1";
if (request.getParameter("no") !=null) {rsTime__MMColParm1 = (String)request.getParameter("no");}
%>
<%
Driver DriverrsTime = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsTime = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsTime = ConnrsTime.prepareStatement("SELECT W.work_code, sum(W.hours) as ALLHOURS, WT.worktype_desc FROM worksheet as W inner join worktype as WT on W.work_code = WT.worktype_code WHERE W.issue_number = ? group by W.work_code, WT.worktype_desc having sum(W.hours) > 0");
StatementrsTime.setObject(1, rsTime__MMColParm1);
ResultSet rsTime = StatementrsTime.executeQuery();
boolean rsTime_isEmpty = !rsTime.next();
boolean rsTime_hasData = !rsTime_isEmpty;
Object rsTime_data;
int rsTime_numRows = 0;
%>
<%
int Rep__numRows = -1;
int Rep__index = 0;
rsTime_numRows += Rep__numRows;
%>
<%
Driver DriverrsWorkTypes = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsWorkTypes = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsWorkTypes = ConnrsWorkTypes.prepareStatement("select * from worktype order by worktype_desc asc");
ResultSet rsWorkTypes = StatementrsWorkTypes.executeQuery();
boolean rsWorkTypes_isEmpty = !rsWorkTypes.next();
boolean rsWorkTypes_hasData = !rsWorkTypes_isEmpty;
Object rsWorkTypes_data;
int rsWorkTypes_numRows = 0;
%>
<%
Driver DriverrsITUsers = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsITUsers = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsITUsers = ConnrsITUsers.prepareStatement("select firstname, surname, usid from users where authority = 'IT'");
ResultSet rsITUsers = StatementrsITUsers.executeQuery();
boolean rsITUsers_isEmpty = !rsITUsers.next();
boolean rsITUsers_hasData = !rsITUsers_isEmpty;
Object rsITUsers_data;
int rsITUsers_numRows = 0;
%>
<%
String rsExternalSupport__MMColParm1 = "1";
if (request.getParameter("no") !=null) {rsExternalSupport__MMColParm1 = (String)request.getParameter("no");}
%>
<%
Driver DriverrsExternalSupport = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsExternalSupport = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsExternalSupport = ConnrsExternalSupport.prepareStatement("SELECT * FROM external_support as EX inner join incident as I on EX.support_agency = I.support_agency WHERE I.issue_number = ? order by EX.default1 desc");
StatementrsExternalSupport.setObject(1, rsExternalSupport__MMColParm1);
ResultSet rsExternalSupport = StatementrsExternalSupport.executeQuery();
boolean rsExternalSupport_isEmpty = !rsExternalSupport.next();
boolean rsExternalSupport_hasData = !rsExternalSupport_isEmpty;
Object rsExternalSupport_data;
int rsExternalSupport_numRows = 0;
%>
<%
Driver DriverrsExtSupport = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsExtSupport = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsExtSupport = ConnrsExtSupport.prepareStatement("select support_agency from external_support");
ResultSet rsExtSupport = StatementrsExtSupport.executeQuery();
boolean rsExtSupport_isEmpty = !rsExtSupport.next();
boolean rsExtSupport_hasData = !rsExtSupport_isEmpty;
Object rsExtSupport_data;
int rsExtSupport_numRows = 0;
%>
<%
String rsSub__isno = "1";
if (request.getParameter("no") !=null) {rsSub__isno = (String)request.getParameter("no");}
%>
<%
Driver DriverrsSub = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsSub = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsSub = ConnrsSub.prepareStatement("select * from subscribers where issue_no = ?");
StatementrsSub.setObject(1, rsSub__isno);
ResultSet rsSub = StatementrsSub.executeQuery();
boolean rsSub_isEmpty = !rsSub.next();
boolean rsSub_hasData = !rsSub_isEmpty;
Object rsSub_data;
int rsSub_numRows = 0;
%>
<%
int Repeat3__numRows = -1;
int Repeat3__index = 0;
rsSub_numRows += Repeat3__numRows;
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
<%
Driver DriverrsUsers = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnrsUsers = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement StatementrsUsers = ConnrsUsers.prepareStatement("select * from users");
ResultSet rsUsers = StatementrsUsers.executeQuery();
boolean rsUsers_isEmpty = !rsUsers.next();
boolean rsUsers_hasData = !rsUsers_isEmpty;
Object rsUsers_data;
int rsUsers_numRows = 0;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><!-- InstanceBegin template="/Templates/support.dwt" codeOutsideHTMLIsLocked="false" -->
<%
String auth = (String)session.getAttribute("authority"); if(auth==null) auth = "";
auth = auth.trim();
%>
<!-- DW6 --> 
<head>
<!-- Copyright 2005 Macromedia, Inc. All rights reserved. -->

<!-- InstanceBeginEditable name="doctitle" -->
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
<script src="SpryAssets/SpryTabbedPanels.js" type="text/javascript"></script>
<script src="SpryAssets/SpryValidationTextField.js" type="text/javascript"></script>
<script src="SpryAssets/SpryValidationSelect.js" type="text/javascript"></script>
<script src="SpryAssets/SpryValidationTextarea.js" type="text/javascript"></script>
<link href="SpryAssets/SpryTabbedPanels.css" rel="stylesheet" type="text/css" />
<link href="SpryAssets/SpryValidationTextField.css" rel="stylesheet" type="text/css" />
<link href="SpryAssets/SpryValidationSelect.css" rel="stylesheet" type="text/css" />
<link href="SpryAssets/SpryValidationTextarea.css" rel="stylesheet" type="text/css" />
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
            <p class="bodyText"><span class="pagename"><%= ((request.getParameter("message")!=null)?request.getParameter("message"):"") %></span>              Details for Case <%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %> <a href="caseDetailsClassic.jsp?<%= MM_keepBoth %>">&lt;classic view&gt;</a></p>
              <div id="TabbedPanels1" class="TabbedPanels">
                <ul class="TabbedPanelsTabGroup">
                  <li class="TabbedPanelsTab" tabindex="0">Case details</li>
                  <li class="TabbedPanelsTab" tabindex="0">Attachments</li>
                  <li class="TabbedPanelsTab" tabindex="0">Update case</li>
                  <li class="TabbedPanelsTab" tabindex="0">Time required</li>
                  <li class="TabbedPanelsTab" tabindex="0">External Agency</li>
                  <li class="TabbedPanelsTab" tabindex="0">Conversation</li>
                  <li class="TabbedPanelsTab" tabindex="0">Subscribers</li>
                </ul>
                <div class="TabbedPanelsContentGroup">
            <div class="TabbedPanelsContent">
                  






<table border="0" class="BD">
                <tr>
                  <td><strong>Issue Headline</strong></td>
                  <td><strong><%=(((rsIssueDetail_data = rsIssueDetail.getObject("casename"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%></strong></td>
                </tr>
                <tr>
                  <td>Submitted</td>
                  <td>               
				  <%= s.format(rsIssueDetail.getDate("date_submitted")) %>
<%= t.format(rsIssueDetail.getTime("date_submitted")) %>
                  
                   by  <%=(((rsIssueDetail_data = rsIssueDetail.getObject("firstname"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%> <%=(((rsIssueDetail_data = rsIssueDetail.getObject("surname"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%> 
                   
<% if( (auth.equals("IT")) || (auth.equals("K")) ) { %>
                   
                   <form ACTION="<%=MM_editAction%>" METHOD="POST" id="frmSubmittedBy" name="frmSubmittedBy">
                     <label>
                     change to 
                     <select name="submittedby" id="submittedby">
                       <%
while (rsUsers_hasData) {
%><option value="<%=((rsUsers.getObject("usid")!=null)?rsUsers.getObject("usid"):"")%>" <%=(((rsUsers.getObject("usid")).toString().equals(((((rsIssueDetail_data = rsIssueDetail.getObject("submittedBy"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)).toString()))?"selected=\"selected\"":"")%>><%=((rsUsers.getObject("firstname")!=null)?rsUsers.getObject("firstname"):"")%>  <%=((rsUsers.getObject("surname")!=null)?rsUsers.getObject("surname"):"")%></option>
                       <%
  rsUsers_hasData = rsUsers.next();
}
rsUsers.close();
rsUsers = StatementrsUsers.executeQuery();
rsUsers_hasData = rsUsers.next();
rsUsers_isEmpty = !rsUsers_hasData;
%>
                     </select>
                     </label>
                     <input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" />
                     <input name="origsubby" type="hidden" id="origsubby" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("submittedBy"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                     <input name="stat" type="hidden" id="stat" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("status"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                     <label>
                     <input type="submit" name="submit" id="submit" value="Change user" />
                     </label>
                     <input type="hidden" name="MM_update" value="frmSubmittedBy" />
                     <input type="hidden" name="MM_recordId" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("issue_number"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
</form>
                    <% } // end if IT show change submit %>                  </td>
                   
                   <% System.out.print("did the names XX"); %>
                </tr>
                <tr>
                  <td><strong>Priority</strong></td>
                  <td><strong><%= getPriority(rsIssueDetail.getString("priority")) %></strong></td>
                </tr>
                <tr>
                  <td>Detail Description</td>
                  <td><%=(((rsIssueDetail_data = rsIssueDetail.getObject("description"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%></td>
                </tr>
                <tr>
                  <td>Steps to recreate</td>
                  <td><%=(((rsIssueDetail_data = rsIssueDetail.getObject("recreate_steps"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%></td>
                </tr>
                
                
                <% if(rsIssueDetail.getInt("status")!=1) { %>
                
                
                <tr>
                  <td>Change Priority</td>
                  <td><form id="frmPriority" name="frmPriority" method="post" action="changeprior.jsp">
                    <select name="priority" id="priority">
                      <option value="1" <% if(rsIssueDetail.getString("priority").trim().equals("1")) out.print("selected=\"selected\""); %> > 1 - Urgent </option>
                      <option value="2" <% if(rsIssueDetail.getString("priority").trim().equals("2")) out.print("selected=\"selected\""); %> > 2 - High Priority </option>
                      <option value="3" <% if(rsIssueDetail.getString("priority").trim().equals("3")) out.print("selected=\"selected\""); %> > 3 - Normal Case </option>
                      <option value="4" <% if(rsIssueDetail.getString("priority").trim().equals("4")) out.print("selected=\"selected\""); %> > 4 - Low Priority </option>
                      <option value="5" <% if(rsIssueDetail.getString("priority").trim().equals("5")) out.print("selected=\"selected\""); %> > 5 - On hold </option>
                    </select> 
                    <label>
                    <input type="submit" name="Change Priority" id="Change Priority" value="Change Priority" />
                    </label>
                    <input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" />
                    <input name="stat" type="hidden" id="stat" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("status"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                    <input name="oldpriority" type="hidden" id="oldpriority" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("priority"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                  </form>                  </td>
                </tr>
                
                
                <% } %>
                
                
                <tr>
                  <td><strong>Status</strong></td>
                  <td><strong><%= getStatusDesc(rsIssueDetail.getString("status"))%></strong></td>
                </tr>
                
<tr>
                  <td><strong>Assigned To </strong></td>
                  <td><%
				  if( (rsIssueDetail.getString("ITsurname")!=null)  && (auth.equals("IT")) && (!rsIssueDetail.getString("status").equals("1")) ){
				  %>
                    <form id="frmReassign" name="frmReassign" method="POST" action="reassign.jsp">
                      <label>
                        <select name="reassign" id="reassign">
                          <%
while (rsITUsers_hasData) {
%>
                          <option value="<%=((rsITUsers.getObject("usid")!=null)?rsITUsers.getObject("usid"):"")%>" 
                          
                          <% if(rsITUsers.getString("usid").trim().equals(rsIssueDetail.getString("assignedTo"))) { %> selected="selected" <% } %>
						  

                          
                          ><%=((rsITUsers.getObject("firstname")!=null)?rsITUsers.getObject("firstname"):"")%> <%=((rsITUsers.getObject("surname")!=null)?rsITUsers.getObject("surname"):"")%></option>
                          <%
  rsITUsers_hasData = rsITUsers.next();
}
rsITUsers.close();
rsITUsers = StatementrsITUsers.executeQuery();
rsITUsers_hasData = rsITUsers.next();
rsITUsers_isEmpty = !rsITUsers_hasData;
%>
                          </select>
                        </label>
                      <label>
                        <input type="submit" name="reassign" id="reassign" value="Re-assign" />
                        </label>
                      <input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" />
                      <input name="stat" type="hidden" id="stat" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("status"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                      <input name="origreassign" type="hidden" id="origreassign" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("assignedTo"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                    </form>
                    <%
				  }				  
				  %></td>
                  </tr>
              </table>
            </div>
                             
      <div class="TabbedPanelsContent">
                  
                  
        

     
     
     
     
     
                  
<table>
                <tr class="BD">
                  <td>Attachment(s)</td>
                  <td><%
File dir = new File(uploadFol + rsIssueDetail.getString("issue_number")); 
String[] children = dir.list();
File[] filess = dir.listFiles();
if (children == null) { out.print("&nbsp;"); } else {
%> <table> <tr> <td>Filename </td><td> Last modified</td></tr><%
	for (int i=0; i<children.length; i++) { %>
                      <tr><td><a href="uploads/<%= rsIssueDetail.getString("issue_number").trim() %>/<%= children[i].trim() %>"> <%= children[i] %> </a> </td><td>
<%            
java.util.Date date = new java.util.Date(filess[i].lastModified());
out.println(full.format(date));
%>
                      
                       </td></tr>
                  <% } %>
                  </table> <%
} 
					
					%>
                  <%
String folder1 = uploadFol + no + "/";
%>


<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
<jsp:setProperty name="upBean" property="folderstore" value="<%= folder1 %>"></jsp:setProperty>
</jsp:useBean></td>
                  <td>
                    <%
	String uploadfile = request.getParameter("uploadfile");
	if(uploadfile==null) uploadfile = "";
	
      if (MultipartFormDataRequest.isMultipartFormData(request))
      {
         // Im using MultipartFormDataRequest to parse the HTTP request (safest!)
         MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
         String todo = null;
         if (mrequest != null) todo = mrequest.getParameter("todo");
	     if ( (todo != null) && (todo.equalsIgnoreCase("upload")) )
	     {
                Hashtable files = mrequest.getFiles();
                if ( (files != null) && (!files.isEmpty()) )
                {
                    UploadFile file = (UploadFile) files.get("uploadfile");
                    //if (file != null) {
	                  if (file.getFileName() == null)
	               	  	out.println("<li> <b> Note: </b> File must be a valid IDB file");
	               	  else if (file.getFileSize()==0)
	               	  	out.print("<li> <b> Note: </b> File must contain some content");
	                  else if (file.getFileName() != null) {
	                   	out.print("Uploaded file : "+file.getFileName()+" ("+file.getFileSize()+" bytes)"+"<BR> Content Type : "+file.getContentType());
	                   	upBean.store(mrequest, "uploadfile");
                    }
	                  else out.println("<li>Please select a file to upload");
                } else {
                  out.println("<li>No uploaded files");
                }
	     }
         else out.println("<BR> todo="+todo);
      }
%></td>
</tr>
</table>
          
          
          
          
          
                  <table width="100%" border="0">
                        <tr>
                          <td><form action="caseDetails.jsp?&amp;no=<%= no %>" method="post" enctype="multipart/form-data" name="upform" id="upform">
                              <table border="0" cellspacing="1" cellpadding="1" class="style1">
                                <tr>
                                  <td align="left">Select a file to attach to this case and then press upload</td>
                                </tr>
                                <tr>
                                  <td align="left"><input type="file" name="uploadfile" size="50" />                                  </td>
                                </tr>
                                <tr>
                                  <td align="left"><input type="hidden" name="todo" value="upload" />
                                    <input type="submit" name="Submit" value="Upload" />
                                      <input type="reset" name="Reset" value="Cancel" />
                                      <input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" /></td>
                                </tr>
                              </table>
                          </form></td>
                        </tr>
                  </table>
            </div>
                  
                  
                  
                  
                  
                  
                  
                  
                  <div class="TabbedPanelsContent">
                  
                    <a name="changecase" id="changecase"></a>
                 <table>
                  
                  <tr>
                  <td>Change Status</td>
                  <td colspan="2"><form id="frmChange" name="frmChange" method="post" <% if( (rsIssueDetail.getString("status").equals("5")) || (rsIssueDetail.getString("status").equals("7")) ) out.print("onClick=\"confirmPost(this.form);\""); %> action="changestat.jsp">
                  
                  
                  
                  
<textarea name="text" id="text" cols="100" rows="10" onKeyDown="limitText(this.form.text,this.form.countdown,1499);" 
onKeyUp="limitText(this.form.text,this.form.countdown,1499);" >

<% if(rsIssueDetail.getString("status").equals("5")) {

if(auth.equals("IT")) 
	out.print("Please examine this quote");
	else out.print(""); 
} else if(rsIssueDetail.getString("status").equals("7")) out.print("I accept this quote"); else out.print("Add text here"); %></textarea>
<% if(rsIssueDetail.getString("status").equals("7")) { %>
A Customer PO is required.

<% } %>
                                                                                                            
                                                                                                            <br />
        
        <% if(rsIssueDetail.getString("status").equals("4")) { // manager approve %>
        
 <% if(!auth.equals("U")) { %>
            
Authorise Case
<input type="radio" name="newstatus" id="approval" value="5" checked="checked" />
Reject Case
<input type="radio" name="newstatus" id="approval" value="33" />
            
            <% } else { %>
            
            Your key user (or any key user) can authorise this case
            
            <% } %>
            
        <% } else if( (rsIssueDetail.getString("status").equals("33")) || (rsIssueDetail.getString("status").equals("5")) ) { // IT quote %>
        <select name="newstatus" id="newstatus">
  <% if(auth.equals("IT")) { %>
  	<% if(rsTime_isEmpty) { %>
         <option value="0" selected="selected">Send Quote (automatic approval)</option>
    <% } else { %>
    	<option value="7" selected="selected">Send Quote (will need approval)</option>
  <% }} %>
         <option value="1">Close Case</option>
         <option value="2">Send to QA</option>
         </select>
        <% } else if(rsIssueDetail.getString("status").equals("7")) { // IT quote %>
         
Approve Quote
<input type="radio" name="newstatus" id="approval" value="0" checked="checked" />
Reject Quote
<input type="radio" name="newstatus" id="approval" value="33" />
         
         
         
         
        <% } else { %>
        <select name="newstatus" id="newstatus">
        <option value="x" selected="selected">Select status</option>
        <option value="0">Put In Work</option>
         <option value="1">Close Case</option>
         <option value="2">Send to QA</option>
         <option value="3">Return from QA</option>
         <option value="<%= rsIssueDetail.getString("status") %>">Add a note</option>
         </select>
        <% } %>

      <br />
<font size="1">(Maximum characters: 100)<br>
You have <input readonly type="text" name="countdown" size="4" value="1499"> characters left.</font>
<label>
 <input type="submit" name="Submit" id="Submit" value="Update Case" />
</label>

                  <input name="issue_number" type="hidden" id="issue_number" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" />
                  <input name="Case" type="hidden" id="Case" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("casename"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                  <input name="Description" type="hidden" id="Description" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("description"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                  <input name="surname" type="hidden" id="surname" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("surname"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                  <input name="firstname" type="hidden" id="firstname" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("firstname"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                
           
                  </form>                  </td>
                </tr>
                </table>
                </div>
                
                  <div class="TabbedPanelsContent">
                    <table>
<tr>
                  <td><strong>
                  <% if(rsIssueDetail.getString("status").equals("5")) { %>
                  Please provide quote
				<% } else if(rsIssueDetail.getString("status").equals("7")) { %>
                  Please review quote
                  <% } else { %>
                  Estimated Hours
                  <% } %>
                  
                  </strong></td>
                  <td colspan="2">&nbsp;
                    <% if (!rsTime_isEmpty ) { %>
                <table border="0" class="BD">
                        <% double hours = 0; %>
                        <% while ((rsTime_hasData)&&(Rep__numRows-- != 0)) { %>
<% hours = hours + rsTime.getDouble("ALLHOURS"); %>
                          <tr>
                            <td><%=(((rsTime_data = rsTime.getObject("worktype_desc"))==null || rsTime.wasNull())?"":rsTime_data)%></td>
                            <td><%=(((rsTime_data = rsTime.getObject("ALLHOURS"))==null || rsTime.wasNull())?"":rsTime_data)%> hours</td>
                          </tr>
<%
  Rep__index++;
  rsTime_hasData = rsTime.next();
}
%>
                                              <tr>
                            <td><strong>Total</strong></td>
                            <td><%= hours %> hours</td>
                          </tr>
                    </table>
                      <% } /* end !rsTime_isEmpty */ %>
<% if (rsTime_isEmpty ) { %>
                          <strong>0 Hours (No time Entered)                          </strong>
                          <% } /* end rsTime_isEmpty */ %>
                          
      <% if(auth.equals("IT")) { %>
              <form action="updtime.jsp" name="frmAddTime" id="frmAddTime" method="post">
                 <input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" />
                        <table width="100%" border="0" class="BD">

                          <tr>
                            <td><span id="spryworktype">
                              <label><span id="spryWorkType">
                              <select name="worktype" id="worktype">
                                <%
while (rsWorkTypes_hasData) {
%>
                                <option value="<%=((rsWorkTypes.getObject("worktype_code")!=null)?rsWorkTypes.getObject("worktype_code"):"")%>"><%=((rsWorkTypes.getObject("worktype_desc")!=null)?rsWorkTypes.getObject("worktype_desc"):"")%></option>
                                <%
  rsWorkTypes_hasData = rsWorkTypes.next();
}
rsWorkTypes.close();
rsWorkTypes = StatementrsWorkTypes.executeQuery();
rsWorkTypes_hasData = rsWorkTypes.next();
rsWorkTypes_isEmpty = !rsWorkTypes_hasData;
%>
                              </select>
                              <span class="selectRequiredMsg">Please select an item.</span></span></label>
                            <span class="selectRequiredMsg">Please select a work area.</span>
                            </span></td>
                          </tr>
                          <tr>
                            <td><span id="spryworknotes"><label><span id="spryWorkNotes">
                              <textarea name="worknotes" id="worknotes" cols="45" rows="5"></textarea>
                              </span></label>
                            </span></td>
                          </tr>
                          <tr>
                            <td><span id="spryhours">
                          <label><span id="spryHours">
                          <input type="text" name="hours" id="hours" />
                          <span class="textfieldInvalidFormatMsg">Invalid format.</span><span class="textfieldMaxValueMsg">The entered value is greater than the maximum allowed.</span><span class="textfieldMinValueMsg">The entered value is less than the minimum required.</span></span></label>
                          <span class="textfieldRequiredMsg">A value is required.</span><span class="textfieldInvalidFormatMsg">Invalid format.</span></span></td>
                          </tr>
                          <tr>
                            <td><label>
                              <input type="submit" name="Submit" id="Submit" value="Update Hours" />
                            </label></td>
                          </tr>
                        </table>
              </form> 

<% } // end if auth IT show time %>                 </td>
                </tr>
</table>
</div>
                  <div class="TabbedPanelsContent">
                  
                  







<% if (!rsExternalSupport_isEmpty ) { %>

                  <table border="0" class="BD">
                    <tr>
                      <td>Agency</td>
                      <td>
					  
                      <a href="<%= rsExternalSupport.getString("url") %>">
				
					<%= rsExternalSupport.getString("support_agency") %>                      </a>                      </td>
                    </tr>
                    <tr>
                      <td>Case Reference</td>
                      <td><%=(((rsExternalSupport_data = rsExternalSupport.getObject("external_case_id"))==null || rsExternalSupport.wasNull())?"":rsExternalSupport_data)%></td>
                    </tr>
                    <tr>
                      <td>Engineer</td>
                      <td><%=(((rsExternalSupport_data = rsExternalSupport.getObject("engineer"))==null || rsExternalSupport.wasNull())?"":rsExternalSupport_data)%></td>
                    </tr>
                    <tr>
                      <td>Phone</td>
                      <td><%=(((rsExternalSupport_data = rsExternalSupport.getObject("phone"))==null || rsExternalSupport.wasNull())?"":rsExternalSupport_data)%></td>
                    </tr>
                  </table>
<% } /* end !rsExternalSupport_isEmpty */ %>








        
        
        
        
        
<% if (rsExternalSupport_isEmpty ) { %>
                    	<% if(auth.equals("IT")) { %>
                          
                    <form id="frmExternalSupport" name="frmExternalSupport" action="updateExtStatus.jsp">
                      <table border="0" class="BD">
                        <tr>
                                <td>Support Agency</td>
                                <td><span id="spryExtAgency">
                                <label>
                                <select name="extSupport" id="extSupport">
                                  <%
while (rsExtSupport_hasData) {
%>
                                  <option value="<%=((rsExtSupport.getObject("support_agency")!=null)?rsExtSupport.getObject("support_agency"):"")%>"><%=((rsExtSupport.getObject("support_agency")!=null)?rsExtSupport.getObject("support_agency"):"")%></option>
                                  <%
  rsExtSupport_hasData = rsExtSupport.next();
}
rsExtSupport.close();
rsExtSupport = StatementrsExtSupport.executeQuery();
rsExtSupport_hasData = rsExtSupport.next();
rsExtSupport_isEmpty = !rsExtSupport_hasData;
%>
                                </select>
                                </label>
                                <span class="selectRequiredMsg">Please select an item.</span></span></td>
                        </tr>
                              <tr>
                                <td>Case Reference</td>
                                <td><span id="spryExtRef">
                                <label>
                                <input type="text" name="extCaseRef" id="extCaseRef" />
                                </label>
                                <span class="textfieldRequiredMsg">A value is required.</span></span></td>
                              </tr>
                              <tr>
                                <td><label>
                                <input type="submit" name="ExternalSupport" id="ExternalSupport" value="Submit" />
                                </label></td>
                                <td><input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" /></td>
                              </tr>
                      </table>
</form>
            
            
            
                      
                  <% }} %>
                  </div>
                  <div class="TabbedPanelsContent">
                  
                  
              <p class="fbinfobox">Conversation for Case <%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %></p>
              
              <form id="frmAddNote" name="frmAddNote" action="changestat.jsp">
                                          <span id="spryAddNote">
                                          <label>
                                          <textarea name="textAddNote" id="textAddNote" cols="100" rows="5"></textarea>
                                          <span id="countspryAddNote">&nbsp;</span>                                                                                    </label>
                                          <span class="textareaRequiredMsg">A value is required.</span><span class="textareaMinCharsMsg">Minimum number of characters not met.</span><span class="textareaMaxCharsMsg">Exceeded maximum number of characters.</span></span>
<input name="newstatus" type="hidden" id="newstatus" value="<%=(((rsIssueDetail_data = rsIssueDetail.getObject("status"))==null || rsIssueDetail.wasNull())?"":rsIssueDetail_data)%>" />
                                          <input name="issue_number" type="hidden" id="issue_number" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" />
                                          <input name="next_action" type="hidden" id="next_action" value="6" />
                                          <br />
                                          <label>
                                          <input type="submit" name="SubmitNote" id="SubmitNote" value="Add a note" />
                                          </label>
</form>
              <% if (!rsCaseNotes_isEmpty ) { %>
                  <table border="0" class="BD">
                <tr>
                  <td><strong>User</strong></td>
                  <td><strong>Date</strong></td>
                  <td><strong>Current status</strong></td>
                  <td><strong>Notes</strong></td>
                </tr>
                
                <% while ((rsCaseNotes_hasData)&&(Repeat1__numRows-- != 0)) { %>
                  <tr>
                    <td>
					<%= rsCaseNotes.getString("firstname") %>
                    <%= rsCaseNotes.getString("surname") %></td>
                    <td>
					<%= s.format(rsCaseNotes.getDate("date_submitted")) %>
                    <%= t.format(rsCaseNotes.getTime("date_submitted")) %>					</td>
                    <td><%= getStatusDesc(rsCaseNotes.getString("status"))%></td>
                    <td><%=(((rsCaseNotes_data = rsCaseNotes.getObject("text"))==null || rsCaseNotes.wasNull())?"":rsCaseNotes_data)%></td>
                  </tr>
                  <%
  Repeat1__index++;
  rsCaseNotes_hasData = rsCaseNotes.next();
}
%>
              </table>
              <br />
              
              <% } /* end !rsCaseNotes_isEmpty */ %>
      <% if (rsCaseNotes_isEmpty ) { %>
                No case notes for this issue as yet
  <% } /* end rsCaseNotes_isEmpty */ %>                  
                  </div>
                  
                  
                  
                  <div class="TabbedPanelsContent"><a name="subs" id="subs"></a>

                          <table border="0" class="BD">
                          <% int county = 0; %>

                            <% while ((rsSub_hasData)&&(Repeat3__numRows-- != 0)) { %>
                            
                            <tr>
                              <td><%=(((rsSub_data = rsSub.getObject("email"))==null || rsSub.wasNull())?"":rsSub_data)%></td>
                                <td>
<% if(county!=0) { %>                                
<a href="delsub.jsp?&amp;no=<%= request.getParameter("no") %>&amp;subid=<%= rsSub.getString("subscriber_id") %>">x</a>
<% } else { %>
&nbsp;
<% } %>
<% county++; %></td>
                            </tr>
                              <%
  Repeat3__index++;
  rsSub_hasData = rsSub.next();
}
%>
                    </table>
                          
 <table>
      <form id="frmAddSub" name="frmAddSub" method="post" action="addSub.jsp">
      <tr>
      <td><span id="spryEmal">
      <label>
      <input type="text" name="emal" id="emal" />
      </label>
      <span class="textfieldRequiredMsg">A value is required.</span><span class="textfieldInvalidFormatMsg">Invalid format.</span></span>
<label>
                                                                                                        <input type="submit" name="AddSub" id="AddSub" value="Add Subscriber" />
                          </label>
                        <input name="no" type="hidden" id="no" value="<%= ((request.getParameter("no")!=null)?request.getParameter("no"):"") %>" /> </td></tr>
                    </form>
                    </table>              
                  </div>
            </div>
            </div>
            <p class="bodyText">&nbsp;</p>
              <script type="text/javascript">
<!--
var TabbedPanels1 = new Spry.Widget.TabbedPanels("TabbedPanels1");
var sprytextfield1 = new Spry.Widget.ValidationTextField("spryExtRef");
var spryExtAgency = new Spry.Widget.ValidationSelect("spryExtAgency");
var sprytextfield2 = new Spry.Widget.ValidationTextField("spryEmal", "email");
var sprytextarea1 = new Spry.Widget.ValidationTextarea("spryWorkNotes", {isRequired:false, hint:"Enter work notes (optional)"});
var spryselect1 = new Spry.Widget.ValidationSelect("spryWorkType");
var sprytextfield3 = new Spry.Widget.ValidationTextField("spryHours", "real", {minValue:-10000, maxValue:10000, isRequired:false});
var sprytextarea2 = new Spry.Widget.ValidationTextarea("spryAddNote", {hint:"Add a note to the case", minChars:1, maxChars:1000, counterId:"countspryAddNote", counterType:"chars_remaining"});
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
rsIssueDetail.close();
StatementrsIssueDetail.close();
ConnrsIssueDetail.close();
%>
<%
rsCaseNotes.close();
StatementrsCaseNotes.close();
ConnrsCaseNotes.close();
%>
<%
rsTime.close();
StatementrsTime.close();
ConnrsTime.close();
%>
<%
rsWorkTypes.close();
StatementrsWorkTypes.close();
ConnrsWorkTypes.close();
%>
<%
rsITUsers.close();
StatementrsITUsers.close();
ConnrsITUsers.close();
%>
<%
rsExternalSupport.close();
StatementrsExternalSupport.close();
ConnrsExternalSupport.close();
%>
<%
rsExtSupport.close();
StatementrsExtSupport.close();
ConnrsExtSupport.close();
%>
<%
rsSub.close();
StatementrsSub.close();
ConnrsSub.close();
%>
<%
rsUsers.close();
StatementrsUsers.close();
ConnrsUsers.close();
%>
