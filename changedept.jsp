<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ include file="Connections/IDBGIS05_SUPPORT.jsp" %>
<%

String prpUpdateDept__newdept = null;
if(request.getParameter("department") != null){ prpUpdateDept__newdept = (String)request.getParameter("department");}

String prpUpdateDept__userid = null;
if(session.getAttribute("MM_Username") != null){ prpUpdateDept__userid = (String)session.getAttribute("MM_Username");}

%>
<%
Driver DriverprpUpdateDept = (Driver)Class.forName(MM_IDBGIS05_SUPPORT_DRIVER).newInstance();
Connection ConnprpUpdateDept = DriverManager.getConnection(MM_IDBGIS05_SUPPORT_STRING,MM_IDBGIS05_SUPPORT_USERNAME,MM_IDBGIS05_SUPPORT_PASSWORD);
PreparedStatement prpUpdateDept = ConnprpUpdateDept.prepareStatement("UPDATE users SET department = ? WHERE usid = ?");
prpUpdateDept.setObject(1, prpUpdateDept__newdept);
prpUpdateDept.setObject(2, prpUpdateDept__userid);
prpUpdateDept.executeUpdate();
%>
<%
session.removeAttribute("department");
session.setAttribute("department", prpUpdateDept__newdept);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>

<body>cakes
</body>
</html>
<%
ConnprpUpdateDept.close();
%>
<jsp:forward page="pref.jsp">
<jsp:param name="message" value="Your department changed"></jsp:param>
</jsp:forward>