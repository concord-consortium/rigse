function select_material(e){
 var strSuggestiontext=e.textContent.trim();
 $('name').value=strSuggestiontext;
 $('suggestions').remove();
 $('show_suggestion').writeAttribute('name','no_suggestion')
}

function highlightlabel(e){
	$$('.highlightoption')[0].removeClassName('highlightoption');
	e.addClassName('highlightoption');
}
 
function showsuggestion(){
	$('show_suggestion').writeAttribute('name','show_suggestion')
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
