// Make material element clickable so user can expand its description.
(function ($) {

  $(function() {
    $('.material_list_item').on('click', function (e) {
      if (e.target.tagName.toLowerCase() === 'a') return;
      var $this = $(this);
      $this.find('.material-details').slideToggle(250, function () {
      	$this.find('.toggle-details').toggle();
      });
    });
  });

}(jQuery));
