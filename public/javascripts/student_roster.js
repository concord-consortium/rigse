function get_School_Student_List()
{
	teacher_list_modal = new UI.Window({ theme:"rites", width:400, height:350}).setContent("<div style='padding:10px'>Loading...Please Wait.</div>").show(true).focus().center();
	teacher_list_modal.setHeader("Add Students to Roster");
	var clazz_id = $("portal_clazz_id").value;
	var options = {
		method: 'post',
		onSuccess: function(transport) {
			var text = transport.responseText;
			text += "<div><table cellpadding='5' align='right'><tr>"+
			"<td><a class='hlink' onclick='close_popup()'>Cancel</a></td>"+
			"</table></div>";
			teacher_list_modal.setContent("<div style='padding:10px'>" + text + "</div>");
		}
	};
	var target_url = "/portal/classes/"+clazz_id+"/get_students";
	new Ajax.Request(target_url, options);
}

function close_popup()
{
	teacher_list_modal.hide();
}

function add_Class_Students(btnSave)
{
	btnSave.disabled = true;
	
	var clazz_id = $("portal_clazz_id").value;
	var arrSelectedStudents = [];
	var arrCkhBoxes = document.getElementsByName("clazz_student[]");
	for(var i=0; i< arrCkhBoxes.length; i++)
	{
		if (arrCkhBoxes[i].checked){
			arrSelectedStudents.push(arrCkhBoxes[i].value);
		}
    }
    var options = {
		method: 'post',
		parameters: "student_ids=" + arrSelectedStudents,
		onSuccess: function(transport) {
			var text = transport.responseText;
			close_popup();
		}
	};
	var target_url = "/portal/classes/"+clazz_id+"/add_students";
	new Ajax.Request(target_url, options);
}