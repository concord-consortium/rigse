var waitForAutoShowingLightboxToClose = function (callback) {
  if (PortalComponents && PortalComponents.settings.autoShowingLightboxResource) {
    var pollForChange = function () {
      if (!PortalComponents.settings.autoShowingLightboxResource) {
        window.clearInterval(pollInterval)
        callback()
      }
    }
    var pollInterval = window.setInterval(pollForChange, 10)
  } else {
    callback()
  }
}

export default waitForAutoShowingLightboxToClose
