function select_material(){
 var strSuggestiontext=event.toElement.textContent.trim();
 $('name').value=strSuggestiontext;
 $('suggestions').remove();
}
