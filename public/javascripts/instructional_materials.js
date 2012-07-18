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
		strLinkText = "Show Activities";
		strExpandCollapseText = "+";
	}
	else{
		strLinkText = "Hide Activities";
		strExpandCollapseText = "-";
	}
	
	$('oExpandCollapseText_'+investigation_id).update(strExpandCollapseText);
	oLink.update(strLinkText);
}

function setSelectedTab(strTabID){
	$(strTabID).simulate('click');
	$$('.scrollertab').each(function(oTab){
		var strDirection = oTab.hasClassName('tableft')? "l" : "r";
		oTab.observe('mouseover',function(){
			startScroll(strDirection,5);
			});
		oTab.observe('mouseout',stopScroll);
	});
}

document.observe("dom:loaded", function() {
	var arrTabs = $$('#oTabcontainer .tab');
	arrTabs.each(function(oTab){
		oTab.observe('click',function(){
			showInstructionalMaterial(oTab);
		});
	});
	if (arrTabs.length > 0)
	{
		var strTabID = arrTabs[0].id;
		setSelectedTab(strTabID);
	}
});
