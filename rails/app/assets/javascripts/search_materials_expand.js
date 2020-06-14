// Make material element clickable so user can expand its description.
(function ($) {

  $(function() {
    window.toggleDetails = function ($this) {
      $this.find('.material-details').slideToggle(250);
      $this.find('.toggle-details-icon').toggle();
    };

    $('.toggle-details').on('click', function(e) {
      // Make sure that we don't expand material details when:
      // - user clicks a link
      // - user tries to select some text fragment (e.g. description)
      if (e.target.tagName.toLowerCase() === 'a') return;
      if (getSelection().toString()) return;

      window.toggleDetails($(this));
    });
  });

}(jQuery));
