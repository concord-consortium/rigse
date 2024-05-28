const waitForAutoShowingLightboxToClose = function (callback: any) {
  if (PortalComponents?.settings.autoShowingLightboxResource) {
    const pollForChange = function () {
      if (!PortalComponents.settings.autoShowingLightboxResource) {
        window.clearInterval(pollInterval);
        callback();
      }
    };
    const pollInterval = window.setInterval(pollForChange, 10);
  } else {
    callback();
  }
};

export default waitForAutoShowingLightboxToClose;
