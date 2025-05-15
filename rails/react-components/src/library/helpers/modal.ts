// Simple library that can be used to create a modal dialog.
// Requires no setup. Just create HTML container:
// <div id="my-modal" class="modal">Content</div>
// and then call:
// showModal(clickHandler, "#my-modal");
// Close button and overlay will be automatically added.
// Related styles are in modal.scss file.

const showOverlay = function (clickHandler: any, modalId: any, fixedPosition: any) {
  jQuery(".portal-pages-modal").hide();
  jQuery(modalId).addClass("portal-pages-modal");
  if (fixedPosition) {
    jQuery(modalId).addClass("portal-pages-modal-fixed");
  }
  if (jQuery("#portal-pages-modal-overlay").length === 0) {
    jQuery("body").append('<div id="portal-pages-modal-overlay"></div>');
  }
  jQuery("#portal-pages-modal-overlay").unbind("click");
  if (clickHandler) {
    jQuery("#portal-pages-modal-overlay").click(clickHandler);
  }
  jQuery("#portal-pages-modal-overlay").css({ "height": jQuery(document).height() + "px" }).fadeIn("fast");
};

const showModal = function (modalId: any, specialMsg: any, fixedPosition: any, closeFunc: any, modalCloseable: any) {
  let _closeFunc = hideModal;
  if (closeFunc) {
    _closeFunc = closeFunc;
  }

  jQuery("html, body").css({ "overflow": "hidden" });
  showOverlay(_closeFunc, modalId, fixedPosition);

  if (jQuery(modalId + " .portal-pages-close").length === 0) {
    if (modalCloseable) {
      jQuery(modalId).append('<a class="portal-pages-close">x</a>');
      jQuery(modalId + " .portal-pages-close").click(_closeFunc);
      jQuery(modalId).click(function (e) {
        if (jQuery(e.target).is(modalId)) {
          _closeFunc();
        }
      });
    }
  }
  if (specialMsg != null) {
    jQuery(modalId + " .portal-pages-special-msg").text(specialMsg).show();
  }
  jQuery("#portal-pages-modal-overlay").css({ "height": jQuery(document).height() + "px" }).fadeIn("fast");
  jQuery(modalId).fadeIn("slow");
};

const hideModal = function () {
  jQuery("html, body").css({ "overflow": "auto" });
  jQuery(".portal-pages-modal").fadeOut("fast");
  jQuery("#portal-pages-modal-overlay").fadeOut("slow");
  jQuery(".portal-pages-special-msg").text("").hide();
};

let hideDisabled = false;
const disableHide = function (disable: boolean) {
  hideDisabled = disable;
};
const isHideDisabled = function () {
  return hideDisabled;
};

export default {
  showModal,
  hideModal,
  disableHide,
  isHideDisabled,
};
