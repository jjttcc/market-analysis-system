<HTML>
<HEAD>
<META NAME="GENERATOR" Content="NetObjects ScriptBuilder 2.01">
<TITLE>Counter Page</TITLE>
</HEAD>
<BODY>

<jsp:useBean ID="ssb" SCOPE="session" CLASS="jsp.beans.samples.SuperSimpleBean"/>
<jsp:setProperty NAME="ssb" PROPERTY="counter" VALUE="2"/>

<h2>Counter: <jsp:getProperty NAME="ssb" PROPERTY="counter"/></h2>
