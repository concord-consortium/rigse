jQuery(function () {

  var collectionsMenuOffset = 1,  // vertical distance from nav bar
      rightArrow = "&#x25B6;",
      downArrow = "&#x25BC;",
      $collectionsMenuItems = jQuery("a[href='#collections_menu']"),
      $collectionsMenuTopItem = jQuery("#nav_top a[href='#collections_menu']"),
      $collectionsMenuMoreItem = jQuery("#nav_top_more_menu a[href='#collections_menu']"),
      $collectionsMenu = jQuery("div#collections_menu"),
      $topMenu = jQuery("#nav_top ul.menu_h"),
      $moreMenu = jQuery("#nav_top_more_menu"),
      topMenuHeight = $topMenu.height(),
      showingCollectionsMenu = false;

  // no menu, no work to do...
  if ($collectionsMenuItems.length === 0) {
    return;
  }

  // create the arrow span
  $collectionsMenuItems.append(jQuery("<span>").addClass("collections_menu_arrow"));
  updateArrow();

  // move the collections menu on window resizing (in case we are in the more menu)
  jQuery(window).on("resize", layoutCollectionsMenu);

  // handle toggling both the main collections menu link and the link in the more menu
  $collectionsMenuItems.on('click', function (e) {

    // track this with a variable because we may hide the menu for other reasons in the layout code
    showingCollectionsMenu = !showingCollectionsMenu;

    layoutCollectionsMenu();
    updateArrow();

    return false;
  });

  function layoutCollectionsMenu() {
    var offset;

    // done if not visible
    if (!showingCollectionsMenu) {
      $collectionsMenu.hide();
      return;
    }

    // layout either next to the more menu or the top nav if the more link is not visible
    if ($collectionsMenuMoreItem.is(':visible')) {
      offset = $collectionsMenuMoreItem.offset();
      $collectionsMenu.css({
        left: offset.left,
        top: offset.top + $collectionsMenuMoreItem.height()
      });
      $collectionsMenu.show();
    }
    else if ($collectionsMenuTopItem.is(':visible')) {
      offset = $collectionsMenuTopItem.offset();
      $collectionsMenu.css({
        left: offset.left - $topMenu.offset().left,
        top: offset.top + $collectionsMenuTopItem.height() + ((topMenuHeight - $collectionsMenuTopItem.height()) / 2) + collectionsMenuOffset
      });
      $collectionsMenu.show();
    }
    else {
      $collectionsMenu.hide();
    }
  }

  function updateArrow() {
    jQuery('.collections_menu_arrow').html($collectionsMenu.is(':visible') ? downArrow : rightArrow);
  }

});
