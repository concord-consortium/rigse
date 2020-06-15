function copyToClipboard (textItem) {
  var temp = jQuery('<input>');
  jQuery('body').append(temp);
  temp.val(jQuery(textItem).val()).select();
  document.execCommand('copy');
  temp.remove();

  jQuery(textItem).parent().css({'position': 'relative'}).append('<div class="text-copied-alert" style="background: #ffc320; font-size: 14px; left: 0; padding: 0 5px; position: absolute; top: 0; width: 100%;"><span>Copied to clipboard!</span></div>');

  jQuery('.text-copied-alert span').fadeIn(200).fadeOut(200).fadeIn(200).fadeOut(200).fadeIn(200, function() {
    hide_timer = setTimeout('removeTextCopyAlert()', 2000);
  });
}

function addCopyButton () {
  if (typeof document.execCommand === 'function') {
    jQuery('.copytextarea').each(function(index) {
      var link_html = '<p><a id="copy-link-' + index + '" class="copy-link" onclick="copyToClipboard(' + index + ')">copy to clipboard</a> <span class="copy-alert" id="copy-alert-' + index + '">copied</span></p>';
      jQuery(this).after(link_html);
    });
  }
}

function removeTextCopyAlert() {
  jQuery('.text-copied-alert').fadeOut(1000, function() {
    jQuery('.text-copied-alert').remove();
  });
}
