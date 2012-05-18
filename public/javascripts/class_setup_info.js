function add_Edit_Class_Teachers()
{
	teacher_list_modal = new UI.Window({  theme:  "rites",
               width:  300, 
               height: 350}).setContent("<div style='padding:10px'>Loading...Please Wait.</div>").show(true).focus().center();
	
	var clazz_id = $("portal_clazz_id").value
	var options = {
					method: 'post',
				  	onSuccess: function(transport) {
				    	var text = transport.responseText;
				    	text += "<div><table cellpadding='5' align='right'><tr>"+
			    				"<td><input type='button' value='Save' onclick='save_Class_Teacher_List(this)' /></td>"+
			    				"<td><a class='HLink' onclick='close_popup()'>Cancel</a></td>"+
			    				"</table></div>"
					    teacher_list_modal.setContent("<div style='padding:10px'>" + text + "</div>")
					  }
				};
	new Ajax.Request("/portal/classes/"+clazz_id+"/get_teachers", options);
}

function close_popup()
{
	teacher_list_modal.hide()
}

function save_Class_Teacher_List(btnSave)
{
	btnSave.disabled = true;
	
	var clazz_id = $("portal_clazz_id").value
	var arrSelectedTeachers = new Array();
	var arrCkhBoxes = document.getElementsByName("clazz_teacher[]")
	for(var i=0; i< arrCkhBoxes.length; i++)
	{
    	if (arrCkhBoxes[i].checked){
    		arrSelectedTeachers.push(arrCkhBoxes[i].value)
        }
    }
    var options = {
					method: 'post',
					parameters: "clazz_teacher_ids=" + arrSelectedTeachers,
				  	onSuccess: function(transport) {
				    	var text = transport.responseText;
					    //alert(text)
					    //$("#dialog-form").html("Loading... Please wait.")
					    //$( "#dialog-form" ).dialog( "close" );
					    //window.location.reload()
					    close_popup()
					  }
				};
	new Ajax.Request("/portal/classes/"+clazz_id+"/edit_teachers", options);
}
