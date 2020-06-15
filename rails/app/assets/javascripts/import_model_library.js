jQuery(function() {

  var targetUrl = "/interactives/import_model_library"
  var lightboxconfig={
          content:"<div style='padding:10px'>Loading...Please Wait.</div>",
          title:"Import Model Library",
          width:450,
          height:200
      },import_model_library_modal;

  function ajaxSuccess(data) {
     import_model_library_modal.handle.setContent(data);
  };

  function importModelLibraryPopup() {
    var options = {
      url:targetUrl,
      method: 'get',
      success: function(transport) {
        var text = transport.html
        ajaxSuccess(text);
      }
    };
    import_model_library_modal = new Lightbox(lightboxconfig);
    jQuery.ajax(options)
  };

  function importModelLibraryPostJson() {
    filedata = new FormData()
    filedata.append('import', jQuery('input[type=file]')[0].files[0])
    var options = {
      url:targetUrl,
      type: 'POST',
      data: filedata,
      cache: false,
      processData: false,
      contentType: false,
      success: function(transport) {
        var text = transport.html
        ajaxSuccess(text);
      },
      error: function(transport) {
          message = JSON.parse(transport.responseText);
          jQuery(".message").html(message.error);
          return;
      }
    }
    jQuery.ajax(options);
  };

  function closeModelLibraryPopup() {
    import_model_library_modal.handle.destroy();
    import_model_library_modal = null;
  }


  jQuery("#import-model-library-popup").on("click", function() {
    importModelLibraryPopup();
  });
  jQuery("body").on("click", "#import-model-library-post-json" , function() {
    importModelLibraryPostJson();
  });
  jQuery("body").on("click", "#close-model-library-popup" , function() {
    closeModelLibraryPopup();
  });

});
