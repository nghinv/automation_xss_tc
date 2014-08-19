// ++ TQA aided feature
window.xalert = function(msg,duration)
{
  //var img = document.createElement("img");
  //img.src = "/eXoPlatformResources/skin/platformSkin/UIToolbarContainer/background/HomeIcon.png?MSG_CODE=" + url;
  //img.style.width= '1px';
 if (!duration) duration = 10000;
 //alert("start:" + msg);
 var startTime=new Date().getTime();
 var el = document.createElement("div");
 el.setAttribute("style","position:absolute;top:40%;left:20%;width:300px;height:200px;background-color:white;");
 el.setAttribute("id","innerXSSdiv");
 el.innerHTML = "<table><tr><td><button id='innerXSSbutton' onclick='javascipt:alert(" + msg +")' value='show alert' text='show alert'/><image id='innerXSSimg' style='width:1px; height:1px;' src='/eXoPlatformResources/skin/platformSkin/UIToolbarContainer/background/HomeIcon.png?MSG_CODE=" + msg + "&startTime=" + startTime + "' /> ALERT::" + msg + "</td></tr></table>";
 setTimeout(function(){
  el.parentNode.removeChild(el);
 },duration);
 document.body.appendChild(el);
 //alert("end:" + msg);
};

window.yalert = function(msg,duration)
{
  //var img = document.createElement("img");
  //img.src = "/eXoPlatformResources/skin/platformSkin/UIToolbarContainer/background/HomeIcon.png?MSG_CODE=" + url;
  //img.style.width= '1px';
 if (!duration) duration = 10000;
 //alert("start:" + msg);
 var startTime=new Date().getTime();
 var el = document.createElement("div");
 el.setAttribute("style","position:absolute;top:40%;left:20%;width:300px;height:200px;background-color:white;");
 el.setAttribute("id","innerXSSdiv");
 el.innerHTML = "<table><tr><td><button id='innerXSSbutton' onclick='javascipt:alert(" + msg +")' value='show alert' text='show alert'/><image id='innerXSSimg' style='width:1px; height:1px;' src='/eXoPlatformResources/skin/platformSkin/UIToolbarContainer/background/HomeIcon.png?YMSG_CODE=" + msg + "&startTime=" + startTime + "' /> ALERT::" + msg + "</td></tr></table>";
 setTimeout(function(){
  el.parentNode.removeChild(el);
 },duration);
 document.body.appendChild(el);
 //alert("end:" + msg);
};


window.jjQuery = function(script) {
  require(["SHARED/jquery"], function(jjQ) {
	  window.jjQ=jjQ;
  });
  return jjQ(script);
};

// -- TQA aided feature
