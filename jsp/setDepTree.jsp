<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<c:set var="ParentDepID" value="${param.ParentDepID}"/>
<c:if test="${ParentDepID == null}">
	<c:set var="ParentDepID" value="company"/>
</c:if>

<c:set var="TreeLevel" value="${param.TreeLevel}"/>
<c:if test="${TreeLevel == null}">
	<c:set var="TreeLevel" value="0"/>
</c:if>
<c:set var="NextTreeLevel" value="0"/>

<fmt:parseNumber var="intTreeLevel" integerOnly="true" type="number" value="${TreeLevel}" />
<fmt:parseNumber var="intNextTreeLevel" integerOnly="true" type="number" value="${NextTreeLevel}" />

<sql:query var="DepList" dataSource="AF_PROD_P">
	DECLARE @ParentDepID varchar(30)
	SET @ParentDepID = ?
	
	SELECT 
		DepID, Name
	FROM 
		Dep_GenInf
	WHERE
		1 = 1
		AND ParentID = @ParentDepID
		And PATINDEX ('%isActive=1%',Respon) > 0
	ORDER BY
		SiblingOrder		
	<sql:param value="${ParentDepID}"/>
</sql:query>

<c:forEach var="row" items="${DepList.rows}">
	
	<c:if test="${DepList.rowCount != 0 && intTreeLevel < 10}">
		
		<option value="${row.DepID}" style="font-weight:bold;">
			<c:forEach var="i" begin="1" end="${intTreeLevel}">
				&nbsp;&nbsp;
			</c:forEach>
			${row.Name}
		</option>		
		<c:set var="intNextTreeLevel" value="${intTreeLevel + 1}"/>
		<jsp:include page="setDepTree.jsp?ParentDepID=${row.DepID}&TreeLevel=${intNextTreeLevel}"/>
	</c:if>	
</c:forEach>