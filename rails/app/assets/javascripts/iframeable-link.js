(function() {
  const $ = jQuery;

  var IframeableLink = (function() {
    let IFRAME_CLASS = undefined;
    IframeableLink = class IframeableLink {
      static initClass() {
        IFRAME_CLASS = 'external-link-iframe';
      }

      constructor(element) {
        this.$element = $(element);
        this.iframeSrc = this.$element.data('iframe-src');

        this.iframeVisible = false;
        this.$iframe = $('<iframe>')
          .addClass(IFRAME_CLASS)
          .css({
            // Note that this is only a suggestion, max width and height are defined in CSS!
            width: this.$element.data('iframe-width'),
            height: this.$element.data('iframe-height'),
            display: 'none'
          })
          .appendTo(this.$element.parent());

        this.$element.on('click', e => {
          this.iframeVisible = !this.iframeVisible;
          this.setIframeSrc();
          this.updateView();
          e.preventDefault();
        });
      }

      setIframeSrc() {
        // Set iframe src (== load iframe) only when link is clicked for the frist time.
        const currentSrc = this.$iframe.attr('src');
        if (currentSrc !== this.iframeSrc) {
          this.$iframe.attr('src', this.iframeSrc);
        }
      }

      updateView() {
        if (this.iframeVisible) {
          this.$iframe.fadeIn();
          this.$element.text('Hide work');
        } else {
          this.$iframe.fadeOut();
          this.$element.text('View work');
        }
      }
    };
    IframeableLink.initClass();
    IframeableLink;
  })();


  $(document).ready(() => $('.iframeable-link').each(function() {
    new IframeableLink(this);
  }));
})();
