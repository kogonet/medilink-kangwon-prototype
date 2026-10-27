<%@ page import="java.io.*" %>
<%
	String filePath = request.getParameter("filepath");

	File image = new File(filePath);
    if (image.exists()) {
        image.delete();
    }

    String absolutePath = image.getAbsolutePath();
    String thumbPath = absolutePath.substring(0, absolutePath.lastIndexOf(File.separator)+1);
    String thumbName = "thumb_" + absolutePath.substring(absolutePath.lastIndexOf(File.separator)+1);

	File thumb = new File(thumbPath+thumbName);
    if (thumb.exists()) {
        thumb.delete();
    }
%>