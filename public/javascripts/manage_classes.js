/**
 * @author Suhas B. Sanmukh
 */
function showCopyClassPopup(copy_clazz_id, clazz_name, class_word, class_description)
{
	teacher_clazz_name = decodeURIComponent(clazz_name);
	class_word = decodeURIComponent(class_word);
	class_description = decodeURIComponent(class_description);
	
	var oInnerHtml = '<div class="popup_content">'+
	'<input type="hidden" id="copyClass_copy_class_id" name="copyClass_copy_class_id" value="'+copy_clazz_id+'" />'+
	'<div id="class_form_fill_error_text" name="copy_class_error_text" class="bold"></div>'+
	'<table cellspacing="0" cellpadding="0" border="0">'+
	'<tr>'+
	'<td><label for="copyClass_name">Class Name:<label></td>'+
	'<td>'+
	'<input type="text" value="Copy of '+teacher_clazz_name.replace(/"/g, '\\"')+'" id="copyClass_name" name="copyClass_name" />'+
	'</td>'+
	'</tr>'+
	'<tr>'+
	'<td><label for="copyClass_class_word">Class Word:<label></td>'+
	'<td><input type="text" value="copy of '+class_word.replace(/"/g, '\\"')+'" id="copyClass_class_word" name="copyClass_class_word" /></td>'+
	'</tr>'+
	'<tr>'+
	'<td><label for="copyClass_desc">Class Description:</label></td>'+
	'<td><textarea id="copyClass_desc" name="copyClass_desc">'+class_description+'</textarea></td>'+
	'</tr>'+
	'</table>'+
	'<div class="bottom_options">'+
	'<div class="right_float">'+
	'<label id="submit_text" style="display : none; font-color: #ff0000"  > Submitting Data......</label>'+
	'<button class="pie" onclick="copyClass(this)">Save</button>'+
	'<button class="pie" onclick="destroyIt()">Cancel</button>'+
	'</div>'+
	'<div class="clear_both">'+
	'</div>'+
	'</div>'+
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
	oPopUpWindow.destroy();
}

function ClassActiveCheckBoxChanged()
{
	SaveManageClassListState();
}

function SaveManageClassListState()
{
	showModalPopup();
	//$$(".edit_portal_teacher")[0].submit()
	var oForm = $$("form.edit_portal_teacher")[0];
	
	var options = {
		method: 'post',
		onSuccess: function(transport) {
			setTimeout(function () {
				initManageClasses();
				hideModalPopup();
				return;
			}, 150);
			return;
		}
	};
	
	Sortable.destroy("sortable");
	oForm.request(options);
	return;
}

function ClassDragComplete()
{
	SaveManageClassListState();
}

function copyClass(btnSave)
{
	btnSave.disabled = true;
 
	var oSubmitText = document.getElementById("submit_text");
	var copy_clazz_id = $("copyClass_copy_class_id").value;
	var clazz_name = $("copyClass_name").value.strip();
	var clazz_word = $("copyClass_class_word").value.strip();
	var clazz_desc = $("copyClass_desc").value;
	
	error_text = document.getElementById('class_form_fill_error_text');
	
	var strParams = "clazz_name="+encodeURIComponent(clazz_name) +
					"&clazz_word="+encodeURIComponent(clazz_word) +
					"&clazz_desc="+encodeURIComponent(clazz_desc) +
					"";
	
    var options = {
		method: 'post',
		parameters: strParams,
		onSuccess: function(transport) {
			var text = transport.responseText;			
			var response = text.evalJSON(true);
			if (response.success)
			{
				window.location.href = window.location.href;
			}
			else
			{
				var error_msg = response.error_msg;
				if (typeof(response.error_msg) == "object")
				{
					error_msg = "";
					for (var strKey in response.error_msg)
					{
						if (response.error_msg.hasOwnProperty(strKey))
						{
							if (error_msg !== '')
							{
								error_msg += "<br />";
							}
							error_msg += strKey.replace(/_/g, " ").capitalize() + " " + response.error_msg[strKey];
						}
					}											
				}
				
				error_text.innerHTML = error_msg;
				oSubmitText.style.display = "none";
				btnSave.disabled = false;
			}
		}
	};
	
	var target_url = "/portal/classes/"+copy_clazz_id+"/copy_class";
	new Ajax.Request(target_url, options);
	oSubmitText.style.display = "inline";
	return;
}

function showModalPopup() {
	var el = document.getElementById("invisible_modal");
	el.className = "invisible_modal show";
}


function hideModalPopup() {
	var el = document.getElementById("invisible_modal");
	el.className = "invisible_modal";
}


var g_oMouseDownTimer = null;
var g_strLabelFor = null;

function removeLabelFor()
{
	var oElement = this;
	g_oMouseDownTimer = setTimeout(function () {
		var oLabel = oElement.getElementsByTagName("label")[0];
		g_strLabelFor = oLabel.getAttribute("for");
		oLabel.removeAttribute("for");
		return;
	}, 250);
}

function applyLabelFor()
{
	var oElement = this;
	
	if (g_strLabelFor !== null)
	{
		clearTimeout(g_oMouseDownTimer);
	}
	
	if (g_strLabelFor === null)
	{
		return;
	}
	
	setTimeout(function () {
		var oLabel = oElement.getElementsByTagName("label")[0];
		oLabel.setAttribute("for", g_strLabelFor);
		g_strLabelFor = null;
		return;
	}, 50);
}

function initManageClasses() {
	
	var arrSortableElems = $$("#sortable > li"); 
	var oElem = null
	
	for (var i = 0; i < arrSortableElems.length; i++)
	{
		oElem = arrSortableElems[i];
		oElem.observe("mousedown", removeLabelFor);
		oElem.observe("mouseup", applyLabelFor);
	}
	
	Sortable.create("sortable", {onUpdate:ClassDragComplete});
}

document.observe("dom:loaded", initManageClasses);
