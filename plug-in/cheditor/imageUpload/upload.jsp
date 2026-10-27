<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="javax.servlet.ServletContext" %>

<%
int fileSizeLimit = 50 * 1000 * 1000;
String encoding = "utf-8";

// 현재 일자 정보 추출
Calendar cal = Calendar.getInstance();
String dateString = "";
dateString = String.format("%04d-%02d-%02d", cal.get(Calendar.YEAR), cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH));
dateString = dateString.replaceAll("-", "\\/");

// 저장 경로 : 초기 매개변수 읽기
ServletContext context = getServletContext();
final String UPLOAD_DIRECTORY = com.ctit.helper.PropertiesUtil.getProperty("Globals.FilePath")+"editor"; //에디터 폴더에 에디터 이미지 저장
final String UPLOAD_URL       = com.ctit.helper.PropertiesUtil.getProperty("Globals.ServerUrl");


System.out.println("----------------업로드 폴더[" + UPLOAD_DIRECTORY + "]");

// 업로드 디렉토리
String SAVE_DIR = UPLOAD_DIRECTORY + "/" + dateString + "/";

// 동적으로 서버 URL 생성
String serverUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
String SAVE_URL = serverUrl + "/commonFile2/loadImage.do?file_path=";

System.out.println("에디터 이미지 경로>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[" + SAVE_DIR + "]");
System.out.println("에디터 이미지 경로>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[" + SAVE_URL + "]");

try {
    File saveDir = new File(SAVE_DIR);
    if (!saveDir.exists()) {
        saveDir.mkdirs();
    }

    long fileSize = 0;
    String saveFileName = null;
    MultipartRequest mRequest = new MultipartRequest(request, SAVE_DIR, fileSizeLimit, encoding, new DefaultFileRenamePolicy());

    saveFileName = mRequest.getFilesystemName("file");

    File file = mRequest.getFile("file");
    if (file == null) {
        throw new Exception("-ERR: No File");
    }

    fileSize = file.length();
    if (fileSize < 1) {
        throw new Exception("-ERR: File Size 0");
    }

    String fileUrl = SAVE_URL + SAVE_DIR + saveFileName;
    String filePath = SAVE_DIR + saveFileName;
    String rData = String.format("{\"fileUrl\":\"%s\", \"filePath\":\"%s\",  \"fileName\":\"%s\", \"fileSize\":\"%d\"}",
            fileUrl, filePath, saveFileName, fileSize);
    out.println(rData);

} catch (Exception e) {
    System.out.println("----------------Editor ERROR>>" + e);
    out.println(e.getMessage());
}
%>



<%-- <%
int fileSizeLimit = 50 * 1000 * 1000;
String encoding = "utf-8";

//현재일자정보 추출
Calendar cal = Calendar.getInstance();
String dateString = "";
dateString = String.format("%04d-%02d-%02d", cal.get(Calendar.YEAR), cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH));
dateString = dateString.replaceAll("-", "\\/");

//저장경로 : 프로퍼티
final String UPLOAD_DIRECTORY = com.ctit.helper.PropertiesUtil.getProperty("Globals.FilePath")+"editor";
final String UPLOAD_URL       = com.ctit.helper.PropertiesUtil.getProperty("Globals.ServerUrl");

System.out.println("----------------Editor UPLOAD_DIRECTORY["+UPLOAD_DIRECTORY+"]");
//업로드 디렉토리
//String SAVE_DIR = "C:/1.DEV/KEA/4.Workspace/CENTUM/CTIT-Shhosp/src/main/webapp/_upload/" + dateString;
//String SAVE_DIR = "C:/1.DEV/KEA/4.Workspace/CTIT-Shhosp/src/main/webapp/_upload/editor/"+dateString;
String SAVE_DIR = UPLOAD_DIRECTORY+"/"+dateString+"/";
//String SAVE_URL = UPLOAD_URL+"/_upload/editor/"+dateString+"/";
String SAVE_URL = "http://piu-dent.ctit.co.kr:8819/commonFile2/loadImage.do?file_path=";
System.out.println("----------------Editor SAVE_DIR["+SAVE_DIR+"]");
try{

	File saveDir = new File(SAVE_DIR);
    if( !saveDir.exists() ){
    	saveDir.mkdirs();
    }

	long fileSize = 0;
    String saveFileName = null;
    MultipartRequest mRequest = new MultipartRequest(request, SAVE_DIR, fileSizeLimit, encoding, new DefaultFileRenamePolicy());

    saveFileName = mRequest.getFilesystemName("file");
    //saveFileName = "20201016172559_sbgguxvp.jpg";

    File file = mRequest.getFile("file");
    if( file == null ){
        throw new Exception("-ERR: No File");
    }

    fileSize = file.length();
    if (fileSize < 1) {
        throw new Exception("-ERR: File Size 0");
    }
	SAVE_URL += SAVE_DIR;
    String rData = String.format("{\"fileUrl\":\"%s%s\", \"filePath\":\"%s%s\",  \"fileName\":\"%s\", \"fileSize\":\"%d\"}",
    		SAVE_URL, saveFileName, SAVE_DIR, saveFileName, saveFileName, fileSize);
    out.println(rData);

} catch(Exception e) {
	System.out.println("----------------Editor ERROR>>"+e);
    out.println(e.getMessage());
}
%>
 --%>

