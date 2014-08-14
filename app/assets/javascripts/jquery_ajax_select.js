(function($) {

  /**
   * Downloads data and uses it to dynamically create set of select options.
   * url          - URL used to dynamically obtain select options (using $.ajax).
   * formatResult - function that accepts data and returns an array of objects,
   *                where each object has two attributes: 'val' and 'text', e.g.:
   *                [{val: 'val1', text: 'First option'}, {val: 'val2', 'text': 'Second option'}]
   */
  $.fn.getSelectOptions = function (url, formatResult) {
    $.ajax({
      type: 'get',
      url: url,
      xhrFields: {
        withCredentials: true
      },
      contentType: 'application/json'
    }).done(success.bind(this));

    function success (data) {
      var options = formatResult(data);

      this.filter('select').each(function() {
        var $select = $(this);
        $select.empty();
        options.forEach(function (opt) {
          $select.append($('<option>').attr('value', opt.val).text(opt.text));
        });
      });
    }

    return this;
  };

}(jQuery));
