function toggle_Notice_Display(oLink){
    $('user_notice_container_div').toggle();
    var strLinkText = ($('user_notice_container_div').getStyle('display') == "none")? "Show Notices" : "Hide Notices";
    oLink.update(strLinkText);
}
