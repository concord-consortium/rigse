// Simple library that can be used to create a modal dialog.
// Requires no setup. Just create HTML container:
// <div id="my-modal" class="modal">Content</div>
// and then call:
// Portal.showModal("#my-modal");
// Close button and overlay will be automatically added.
// Related styles are in modal.scss file.

Portal.showModal = function(modalId, specialMsg) {
  jQuery('.modal').hide();
  jQuery(modalId).addClass('modal');
  if (jQuery('#modal-overlay').length === 0) {
    jQuery('body').append('<div id="modal-overlay"></div>');
    jQuery('#modal-overlay').click(Portal.hideModal);
  }
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
