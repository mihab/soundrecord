$(document).ready(function () {
    if (navigator.userAgent.toLowerCase().indexOf("iphone") !== -1 || navigator.userAgent.toLowerCase().indexOf("ipad") !== -1) {
    	$("#flashContent").empty();
        var link = $("<a></a>").attr("href", "http://itunes.apple.com/us/app/soundcloud/id336353151").html("Please download our iPhone/iPad app!");
        $("#flashContent").append(link);
        return;
    }
    if (navigator.userAgent.toLowerCase().indexOf("android") !== -1) {
    	$("#flashContent").empty();
        var link = $("<a></a>").attr("href", "https://play.google.com/store/apps/details?id=com.soundcloud.android").html("Please download our Android app!");
        $("#flashContent").append(link);
        return;
    }
    SC.initialize({
        client_id: "7c6c04b49de256fd22b2d9f83d1877c8",
        redirect_uri: "http://soundrecord.herokuapp.com/callback.html"
    });
    window.authorize = function () {
        SC.connect(function () {
            $("#soundrecord").get(0).upload(SC.accessToken());
        });
    };
    window.addLink = function (title, permalink_url) {
        var link = $("<a></a>").attr("href", permalink_url).attr("target", "_blank").html(title);
        $("#links").append($("<p></p>").append(link));
        $("#links").css("visibility", "visible");
    };
    var swfVersionStr = "11.0.0";
    var xiSwfUrlStr = "";
    var flashvars = {};
    var params = {};
    params.quality = "high";
    params.bgcolor = "#ffffff";
    params.allowscriptaccess = "always";
    params.allowfullscreen = "true";
    var attributes = {};
    attributes.id = "soundrecord";
    attributes.name = "soundrecord";
    attributes.align = "middle";
    swfobject.embedSWF("SoundRecord.swf", "flashContent", "100%", "400", swfVersionStr, xiSwfUrlStr, flashvars, params, attributes);
});