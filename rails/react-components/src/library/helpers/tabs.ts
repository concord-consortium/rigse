function showTab (tabID: any) {
  jQuery(".tab-content").hide().removeClass("active");
  jQuery(tabID + "-tab").addClass("active").show();
  jQuery("ul.tabs li").removeClass("active");
  jQuery(tabID + "-tab-link").addClass("active");
  jQuery("html,body").animate({ scrollTop: (jQuery("ul.tabs").offset()?.top ?? 0) - 25 }, 1000);
  if (window.history.pushState) {
    window.history.pushState(null, "", tabID);
  } else {
    window.location.hash = tabID;
  }
}

export default showTab;
