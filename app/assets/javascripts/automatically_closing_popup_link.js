// A wrapper around having an external link pop up in its own window, and then automatically monitoring it
// and closing it when it returns to the same domain as the current page.


window.inIframe = function() {
  try {
      return window.self !== window.top;
  } catch (e) {
      return true;
  }
};

window.AutomaticallyClosingPopupLink = {
  configure: function($link, directUrl, popupUrl, afterCloseUrl) {
    var onClick = function() {
      if (window.inIframe()) {
        // Pop up the url in a new window
        // Monitor it and close it when done
        // Redirect the current page when closed
        this._popupWindow($link.id, popupUrl, afterCloseUrl);
      } else {
        window.location.href = directUrl;
      }
    }.bind(this);
    $link.on('click', onClick);
  },

  // This code was adapted from CODAP's implementation of a similar feature
  _popupWindow: function(id, popupUrl, afterCloseUrl) {
    var width  = 800,
        height = 480,
        position = this._computeScreenLocation(width, height),
        windowFeatures = [
          'width=' + width,
          'height=' + height,
          'top=' + position.top || 200,
          'left=' + position.left || 200,
          'dependent=yes',
          'resizable=no',
          'location=no',
          'dialog=yes',
          'menubar=no'
        ],

        exceptionCount = 0,
        panel = window.open(popupUrl, id, windowFeatures.join()),
        checkPanelHref = function() {
          try {
            /* This is a bit of a hack. Accessing a popup's location throws a security exception
             * when the url is cross-origin. Therefore, 1) this should only be used with urls that are cross-origin, and 2) the url
             * should eventually return to a non-cross-origin url at the time the window should be closed.
             */
            var href = panel.location.href; // This will throw an exception if the url is still cross-origin.

            // If exceptionCount is not 0, then we hit an external url and came back. Assume that we're done.
            // If it's still 0, then keep waiting for the url to change to something external and change back.
            if (exceptionCount > 0) {
              window.clearInterval(timer);
              panel.close();
              if (afterCloseUrl) {
                document.location = afterCloseUrl;
              } else {
                document.location.reload();
              }
            }
          } catch(e) {
            exceptionCount++;
          }
        },
        timer = window.setInterval(checkPanelHref, 200);
  },

  _computeScreenLocation: function(w, h) {
    // Fixes dual-screen position                         Most browsers      Firefox
    var dualScreenLeft = window.screenLeft !== undefined ? window.screenLeft : screen.left;
    var dualScreenTop = window.screenTop !== undefined ? window.screenTop : screen.top;

    var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    return {left: left, top: top};
  }
};
