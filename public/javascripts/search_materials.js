var suggestioncount=-1;

function select_material(e){
 var strSuggestiontext=e.textContent.trim();
 $('name').value=strSuggestiontext;
 $('suggestions').remove();
 $('show_suggestion').writeAttribute('name','no_suggestion');
 suggestioncount=-1;
}

function highlightlabel(e){
	$$('.highlightoption')[0].removeClassName('highlightoption');
	e.addClassName('highlightoption');
}

function showsuggestion(event,oelem){	
	$('show_suggestion').writeAttribute('name','show_suggestion');
	var osuggestions=$$('.suggestion');
	var ohoverelements=$$('.suggestionhover');
	if(osuggestions.length==0)
	{
		return;
	}
	if(ohoverelements.length>0)
	{
	 ohoverelements[0].removeClassName('suggestionhover');
	}
	switch (event.keyCode)
	{
		case 40:
			suggestioncount++;
			if(suggestioncount>=osuggestions.length)
			{
				suggestioncount=0;
			}
			osuggestions[suggestioncount].addClassName('suggestionhover');
			break;
		
		case 38:
			suggestioncount--;
			if(suggestioncount<=-1)
			{
				suggestioncount=osuggestions.length-1;
			}
			osuggestions[suggestioncount].addClassName('suggestionhover');
			break;
		
		case 13:
			select_material(osuggestions[suggestioncount]);
			suggestioncount=-1;
			break;
		
		default:
			suggestioncount=-1;
	}
	
}

function showHideProbes(activity){
	
	var bVisible = false;
    $$('.probes_container,.probes_header').each(function(oButtonContainer){
        oButtonContainer.toggle();
        bVisible = bVisible || oButtonContainer.getStyle('display')=='none';
    });
    	
}

function showHideFilters(oLink){
    var bVisible = false;
    $$('.collapse_filters').each(function(oButtonContainer){
        oButtonContainer.toggle();
        bVisible = bVisible || oButtonContainer.getStyle('display')=='none';
    });
    
    var strLinkText = "";
    var strExpandCollapseText = "";
    if(bVisible){
        strLinkText = "Show Filters";
        strExpandCollapseText = "+";
    }
    else{
        strLinkText = "Hide Filters";
        strExpandCollapseText = "-";
    }
    
    $('oExpandCollapseText').update(strExpandCollapseText);
    oLink.update(strLinkText);
}
function uncheckedallprobes()
{
	$$(".probe_items").each(function(e){
		e.checked= false;
		
	})
}

function removesuggestions(){
	$('suggestions').remove();
}
