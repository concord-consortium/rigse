function showInstructionalMaterial(oMaterialTab){
	var oSelectedTab = $$('.selected_tab')[0];
	if(oSelectedTab){
		oSelectedTab.removeClassName('selected_tab');
		oSelectedTab.addClassName('tab');
		$(oSelectedTab.id + "_data").hide();
	}
	
	oMaterialTab.removeClassName('tab');
	oMaterialTab.addClassName('selected_tab');
	$(oMaterialTab.id + "_data").show();
}

function startScroll(direction,size){
	oTimer = setInterval(function(){ 
			var scroller = document.getElementById('oTabcontainer');
			if (direction == 'l') {
				scroller.scrollLeft -= size;
			}
			else if (direction == 'r') {
				scroller.scrollLeft += size;
			}
	},20);
}

function stopScroll(){
	clearTimeout(oTimer);
}

function showHideActivityButtons(investigation_id, oLink){
	var bVisible = false;
	$$('.activitybuttoncontainer_'+investigation_id).each(function(oButtonContainer){
		oButtonContainer.toggle();
		bVisible = bVisible || oButtonContainer.getStyle('display')=='none';
	});
	
	var strLinkText = ""; 
	var strExpandCollapseText = "";
	if(bVisible){
		strLinkText = "Show Run Activity buttons";
		strExpandCollapseText = "+";
	}
	else{
		strLinkText = "Hide Run Activity buttons";
		strExpandCollapseText = "-";
	}
	
	$('oExpandCollapseText_'+investigation_id).update(strExpandCollapseText);
	oLink.update(strLinkText);
}
