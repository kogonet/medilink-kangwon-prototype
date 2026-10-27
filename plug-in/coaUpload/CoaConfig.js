
var link = document.location.href;
var link_str = "";

if (link.indexOf("kemco.or.kr") != -1) {

  link_str = "91425605b7842199fae1d497879dc9f5";

} else if (link.indexOf("energy.or.kr") != -1) {

  link_str = "21865bfb327ad569a19e50a35b0b81d4";

} else if (link.indexOf("ctit.co.kr") != -1) {

  link_str = "4089636594de856cb0289bffedb635d3";

}

var CoaConfig = {

  Version: "1.0",
  ProductName: "CoaUpload",
  TemplateFolder: "/plug-in/coaUpload/template", //경로지정
  ImageFolder: "/plug-in/coaUpload/images",      //경로지정
  LibFolder: "/plug-in/coaUpload/lib",           //경로지정
  LicenseKey: link_str

};