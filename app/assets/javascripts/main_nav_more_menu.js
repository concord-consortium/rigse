jQuery(function () {

  var showMoreMargin = 20, // right margin on menu items before the show more menu is triggered
      menuItemMargin = 20, // left+right margin around each menu item
      moreMenuOffset = 1,  // vertical distance from nav bar
      moreItemWidth = 60,  // can't compute this as it is created as a hidden item
      rightArrow = "&#x25B6;",
      downArrow = "&#x25BC;",
      moreMenuVisible = false,
      $topMenu = jQuery("#nav_top ul.menu_h"),
      topMenuWidth = $topMenu.width(),
      topMenuHeight = $topMenu.height(),
      menuItemWidths = [],
      moreMenuItems = [],
      $window = jQuery(window),
      $moreMenu, $menuItems, $moreLink, $moreItem;

  // no menu, no work to do...
  if ($topMenu.length === 0) {
    return;
  }

  // create a more menu with all the current menu items
  $moreMenu = jQuery("<div>").attr("id", "nav_top_more_menu").hide();
  $moreMenuList = jQuery("<ul>");
  $moreMenu.append($moreMenuList);

  $menuItems = $topMenu.find("li").filter(":not(.hide-menu-item)")
  $menuItems.each(function () {
    var $menuItem = jQuery(this),
        $moreMenuItem = $menuItem.clone().removeClass("trail").css({
          color: '#416992',
          textTransform: 'uppercase'
        });
    moreMenuItems.push($moreMenuItem);
    $moreMenuList.append($moreMenuItem);
    menuItemWidths.push($menuItem.width() + menuItemMargin);
  });
  jQuery("body").append($moreMenu);

  // adds a more link that is only visible when the menu bar is collapsed
  $moreLink = jQuery("<a>").attr("href", "#more").html("More " + rightArrow).on("click", function (e) {
    e.preventDefault();
    e.stopPropagation();
    showMoreMenu(!moreMenuVisible);
  })
  $moreItem = jQuery("<li>").addClass("trail").append($moreLink).hide();
  $topMenu.append($moreItem);

  // listen for window changes to compute the layout and layout at startup
  $window.on("resize", layoutMoreMenu);
  layoutMoreMenu();

  function layoutMoreMenu() {
    var windowWidth = $window.width(),
        leftOffset = $topMenu.offset().left,
        itemVisible = true,
        maxItemRight = windowWidth - moreItemWidth - showMoreMargin;

    // if all the original menu items can show then hide the more menu and we are done
    if (topMenuWidth + showMoreMargin < windowWidth) {
      if ($moreItem.is(":visible")) {
        $menuItems.each(function () {
          jQuery(this).show();
        });
        $moreItem.hide();
        showMoreMenu(false);
      }
      return;
    }

    // walk down the items and show/hide them based on their offset
    $menuItems.each(function (index) {
      var $item = jQuery(this),
          itemWidth = $item.width(),
          itemOffset = $item.offset(),
          itemRight = leftOffset + menuItemWidths[index];

      itemVisible = itemVisible && (itemRight < maxItemRight);
      leftOffset += menuItemWidths[index];

      if (itemVisible) {
        $item.show();
        moreMenuItems[index].hide();
      }
      else {
        $item.hide();
        moreMenuItems[index].show();
      }
    });

    // move the more menu to under the more item
    if (itemVisible) {
      $moreItem.hide();
    }
    else {
      $moreItem.show();
      showMoreMenu(moreMenuVisible);
    }
  }

  function showMoreMenu(show) {
    if (show) {
      $moreLink.html("More " + downArrow);
      $moreMenu.css({
        left: $moreItem.offset().left + moreItemWidth - $moreMenu.width(),
        top: $moreItem.offset().top + $moreItem.height() + ((topMenuHeight - $moreItem.height()) / 2) + moreMenuOffset
      });
      $moreMenu.show();
    }
    else {
      $moreLink.html("More " + rightArrow);
      $moreMenu.hide();
    }
    moreMenuVisible = show;
  }
});
