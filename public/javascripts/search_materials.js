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
