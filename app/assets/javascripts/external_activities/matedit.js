function get_edit_resource_popup(external_activity_id, popup_options){
  var lightboxConfig = {
        content:"<div style='padding:10px'>Loading...Please Wait.</div>",
        title:"Edit Options"
    };
    list_lightbox=new Lightbox(lightboxConfig);
    jQuery(".buttons")[0].innerHTML = jQuery(".buttons")[0].innerHTML + "<a href='javascript:void(0)' style='float:right;margin-top: 5px;margin-right: 10px' class='button' onclick='close_popup()'>Cancel</a>"

    // This 999 template is used because we cannot use route helpers in assets
    // The docker build process precompiles the assets and while doing so the route helpers
    // are not available.
    var target_url = "/eresources/999/edit";
    if (popup_options && popup_options.use_short_form) {
      target_url = "/eresources/999/edit_basic"
    }
    target_url = target_url.replace('999',external_activity_id);

    var resizeLightbox = function() {
      list_lightbox.handle.setSize(800,document.viewport.getHeight() - 40);
      list_lightbox.handle.center({top: 20});
    };

    // Need to remove this when it closes
    jQuery(window).resize(resizeLightbox);

    var options = {
        method: 'get',
        onSuccess: function(transport) {
            var text = transport.responseText;
            text = "<div id='oErrMsgDiv' style='color:Red;font-weight:bold'></div>"+ text;
            list_lightbox.handle.setContent("<div id='windowcontent' style='padding:10px'>" + text + "</div>");
            resizeLightbox();
        }
    };
    new Ajax.Request(target_url, options);
}
