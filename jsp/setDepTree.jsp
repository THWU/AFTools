<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<c:set var="ParentDepID" value="${param.ParentDepID}"/>
<!-- 建立預設 Dep Root: company -->
<c:if test="${ParentDepID == null}">
	<c:set var="ParentDepID" value="company"/>
</c:if>

<c:set var="TreeLevel" value="${param.TreeLevel}"/>
<c:if test="${TreeLevel == null}">
	<c:set var="TreeLevel" value="0"/>
</c:if>
<c:set var="NextTreeLevel" value="0"/>

<!-- 轉換為數字，讓資料可以相加  -->
<fmt:parseNumber var="intTreeLevel" integerOnly="true" type="number" value="${TreeLevel}" />
<fmt:parseNumber var="intNextTreeLevel" integerOnly="true" type="number" value="${NextTreeLevel}" />

<!-- dataSource 使用 Tomcat JDBC Connection Pool  -->
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
		-- 排除不想顯示的部門
		-- 利用部門的某個欄位(此例用 "部門權責")內的資料(isActive=1)來判斷
		And PATINDEX ('%isActive=1%',Respon) > 0
	ORDER BY
		SiblingOrder		
	<sql:param value="${ParentDepID}"/>
</sql:query>

<c:forEach var="row" items="${DepList.rows}">
	
	<!-- intTreeLevel < 10 用來限制遞迴數為 9 次 -->
	<c:if test="${DepList.rowCount != 0 && intTreeLevel < 10}">
		
		<!-- 預設情況是建立在 Select 元素 內的 Option 項目，可根據需要變更元素類型 -->
		<option value="${row.DepID}" style="font-weight:bold;">
			<!-- 將部門名稱縮排，模擬出階層 -->
			<c:forEach var="i" begin="1" end="${intTreeLevel}">
				&nbsp;&nbsp;
			</c:forEach>
			${row.Name}
		</option>
		<c:set var="intNextTreeLevel" value="${intTreeLevel + 1}"/>
		<!-- 利用 jsp:include 達到遞迴查詢 -->
		<jsp:include page="setDepTree.jsp?ParentDepID=${row.DepID}&TreeLevel=${intNextTreeLevel}"/>
	</c:if>	
</c:forEach>