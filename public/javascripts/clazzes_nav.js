/**
 * @author Suhas Sanmukh
 */

var oPopUpWindow;
	
function createNewClass(portalClazzPath)
{
	window.location.href = portalClazzPath;
}

function manageClassList(ManagePath)
{
	/*alert('Manage Classes Stub');*/
	window.location.href = ManagePath;
}

function showFullStatus()
{
	alert('Full Status Link Stub');
}

function showMaterials()
{
	alert('Materials Link Stub');
}

function studentRoster()
{
	alert('Student Roster Stub');
}

function showCopyClassPopup(copy_clazz_id, clazz_name, class_word, class_description)
{
	teacher_clazz_name = decodeURIComponent(clazz_name);
	class_word = decodeURIComponent(class_word);
	class_description = decodeURIComponent(class_description);
	
	/*alert("Enter Inside");*/
	var oInnerHtml = '<div class="popup_content">' +
						 '<input type="hidden" id="copyClass_copy_class_id" name="copyClass_copy_class_id" value="' + copy_clazz_id + '" />' +
						 '<table cellspacing="0" cellpadding="0" border="0">' +
							 '<tr>' +
								 '<td>Class Name:</td>' +
					 			 '<td>' +
								 	'<input type="text" value="Copy of '+teacher_clazz_name.replace(/"/g, '\\"')+'" id="copyClass_name" name="copyClass_name" />' +
								 '</td>' +
							 '</tr>' +
							 '<tr>' +
								 '<td>Class Word:</td>' +
								 '<td><input type="text" value="copy of '+class_word.replace(/"/g, '\\"')+'" id="copyClass_class_word" name="copyClass_class_word" /></td>' +
							 '</tr>' +
							 '<tr>' +
								 '<td>Class Description:</td>' +
								 '<td><textarea id="copyClass_desc" name="copyClass_desc">'+class_description+'</textarea></td>' +
							 '</tr>' +
						 '</table>' +
						 '<div class="bottom_options">' +
							 '<div class="right_float">' +
							 	'<label id="submit_text" style="display : none; font-color: #ff0000"  > Submitting Data......</label>'+
								 '<button onclick="copyClass(this)">Save</button>' +
								 '<button onclick="destroyIt()">Cancel</button>' +
							 '</div>' +
							 '<div class="clear_both">' +
							 '</div>' +
						 '</div>' +
					 '</div>'+
					 '<script>'+
  						'document.getElementById("copyClass_name").focus();'+
					'</script>';
		
	oPopUpWindow = new UI.Window({ theme: "rites",
               shadow: true, 
               width:  500, 
               height: 250}).setContent(oInnerHtml).show(true).center();
               oPopUpWindow.activate();
               
}

function destroyIt()
{
	/*alert("Destroying !!");*/
	oPopUpWindow.destroy();
}


function copyClass(btnSave)
{
	btnSave.disabled = true;
 
	var copy_clazz_id = $("copyClass_copy_class_id").value;
	var clazz_name = $("copyClass_name").value;
	var clazz_word = $("copyClass_class_word").value;
	var clazz_desc = $("copyClass_desc").value;
	
	var strParams = "clazz_name=" + encodeURIComponent(clazz_name) +
					"&clazz_word=" + encodeURIComponent(clazz_word) +
					"&clazz_desc=" + encodeURIComponent(clazz_desc) +
					"";
	
    var options = {
					method: 'post',
					parameters: strParams,
					onSuccess: function(transport) {
									var text = transport.responseText;
									close_popup();
					}
	};
	var target_url = "/portal/classes/"+copy_clazz_id+"/copy_class";
	new Ajax.Request(target_url, options);
	var oSubmitText = document.getElementById("submit_text")
	oSubmitText.style.display = "inline";
	return;
}

