// Simple library that can be used to create a modal dialog.
// Requires no setup. Just create HTML container:
// <div id="my-modal" class="modal">Content</div>
// and then call:
// Portal.showModal(clickHandler, "#my-modal");
// Close button and overlay will be automatically added.
// Related styles are in modal.scss file.
Portal.showOverlay = function(clickHandler,modalId,fixedPosition) {
    jQuery('.modal').hide();
    jQuery(modalId).addClass('modal');
    if(fixedPosition) {
        jQuery(modalId).addClass('modal-fixed');
    }
    if (jQuery('#modal-overlay').length === 0) {
        jQuery('body').append('<div id="modal-overlay"></div>');
    }
    jQuery('#modal-overlay').unbind('click');
    if(clickHandler) {
        jQuery('#modal-overlay').click(clickHandler)
    }
    jQuery('#modal-overlay').css({'height': jQuery(document).height() + 'px'}).fadeIn('fast');
};

Portal.showModal = function(modalId, specialMsg, fixedPosition) {
  Portal.showOverlay(Portal.hideModal,modalId,fixedPosition);

  if (jQuery(modalId + ' .close').length === 0) {
    jQuery(modalId).append('<a class="close">x</a>');
    jQuery(modalId + ' .close').click(Portal.hideModal);
  }
  if (specialMsg != null) {
    jQuery(modalId + ' .special-msg').text(specialMsg).show();
  }
  jQuery('#modal-overlay').css({'height': jQuery(document).height() + 'px'}).fadeIn('fast');
  jQuery(modalId).fadeIn('slow');
};

Portal.hideModal = function() {
  jQuery('.modal').fadeOut('fast');
  jQuery('#modal-overlay').fadeOut('slow');
  jQuery('.special-msg').text('').hide();
};

// A simple confirm modal, suitable for replacing window.confirm in most cases.
Portal.confirm = function(opts) {
    var callback   = (opts && opts.callback) || function() { console.log("complete");    };
    var message    = (opts && opts.message)  || "Are you sure?";
    var okText     = (opts && opts.okText)   || "OK";
    var cancelText = (opts && opts.okText)   || "Cancel";
    var noCancel   = (opts && opts.noCancel) || false;
    var wrapper    = jQuery('<div id="portal-confirm-wrapper"/>');
    var dialog     = jQuery('<div class="cc-confirm"/>');
    var messageDiv = jQuery('<div class="message"/>').text(message);
    var buttonDiv  = jQuery('<div class="buttons"/>')
    var cancelBtn  = jQuery('<button class="submit-btn" type="submit"/>').text(cancelText);
    var okBtn      = jQuery('<button class="submit-btn" type="submit"/>').text(okText);

    if(!noCancel) {
        buttonDiv.append(cancelBtn);
    }
    buttonDiv.append(okBtn);
    dialog.append(messageDiv);
    dialog.append(buttonDiv);
    jQuery('body').append(wrapper);
    wrapper.append(dialog);

    var remove = function() {
        dialog.remove();
        wrapper.remove();
    }

    var close = function() {
        Portal.hideModal();
        wrapper.fadeOut('slow', remove)
    }
    var doOk = function() {
        close();
        callback();
    }
    okBtn.click(doOk);
    cancelBtn.click(close);

    Portal.showOverlay();
}

// Look for data-cc-confirm links, and add custom confirmation
document.addEventListener("DOMContentLoaded", function()  {
    var clickReplacement = function(event) {
        var target = event.target;
        var location = target.getAttribute('href');
        var message = target.getAttribute('data-cc-confirm');
        var followLink = function() { window.location=location; }
        Portal.confirm({message: message, callback: followLink})
        event.preventDefault();
    }
    jQuery('a[data-cc-confirm]').click(clickReplacement);
});
