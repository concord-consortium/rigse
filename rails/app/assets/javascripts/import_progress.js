jQuery(function () {
    jQuery("#import_activity").on("click", function() {
    import_activity_status();

    jQuery("body").on("click", "#import-activity-post-json" , function() {
      importActivityPostJson();
    });
  });
});

function import_activity_status() {
    var lightboxConfig = {
        content:"<div style='padding:10px'>Loading...Please Wait.</div>",
        title:"Import Activity"
    },
    target_url = "/import/imports/import_activity_status",
    options = {
      url:target_url,
      method: 'get',
      success: function(transport) {
        list_lightbox=new Lightbox(lightboxConfig);
        var text = transport.html;
        text = "<div id='oErrMsgDiv' style='padding-left:15px;font-weight:bold'></div>" +
                "<div id ='content'>"+ text +"</div>";
        list_lightbox.handle.setContent("<div id='windowcontent' style='padding:0 10px'>" + text + "</div>");
        var contentheight=$('windowcontent').getHeight();
        var contentoffset=50;
        list_lightbox.handle.setSize(400,contentheight+contentoffset+20);
        list_lightbox.handle.center();
      }
    };
    jQuery.ajax(options)
};

function importActivityPostJson() {
    jQuery("#import_activity_form").css('display','none');
    jQuery("#oErrMsgDiv").css('text-align','center');
    jQuery("#oErrMsgDiv").css('color','black');
    jQuery("#oErrMsgDiv").css('margin-top','30px');
    jQuery("#oErrMsgDiv").html("Import in progress please wait...<br><i class='wait-icon fa fa-spinner fa-spin'></i>");
    filedata = new FormData()
    filedata.append('import_activity_form', jQuery('input[type=file]')[0].files[0])
    var targetUrl = "/import/imports/import_activity"
    var options = {
      url:targetUrl,
      type: 'POST',
      data: filedata,
      cache: false,
      processData: false,
      contentType: false,
      success: function(transport) {
        import_job_status();
      },
      error: function(transport) {
          message = JSON.parse(transport.responseText);
          jQuery("#oErrMsgDiv").html(message.error);
          return;
      }
    }
    jQuery.ajax(options);
};

function import_job_status(){
    var targetUrl = "/import/imports/import_activity_progress";
    var timer;

    timer = setInterval(function(){
      jQuery.ajax({
        url:targetUrl,
        success: function(progressData) {
          console.log(progressData.progress);
          if (progressData.progress == 100) {
            jQuery("#oErrMsgDiv").html("Activity imported successfully.").css('color','Green');
            console.log(progressData.progress);
            clearInterval(timer);
            delete_job();
            window.location = "/search"
          }
          else if (progressData.progress == -1) {
            jQuery("#oErrMsgDiv").html("Import failed.Please try again.").css('color','Red');
            jQuery("#oErrMsgDiv").css('margin-top','0');
            jQuery("#oErrMsgDiv").css('text-align','');
            jQuery("#import_activity_form").css('display','block');
            console.log(progressData.prgress);
            clearInterval(timer);
            delete_job();
          }
        },
        error: function(transport) {
          console.log("error");
        }
      });
    },5000);
};

function delete_job(){
    jQuery.ajax({
      url:"/import/imports/activity_clear_job",
      success: function(progressData) {
        console.log("job deleted");
      },
    });
}
