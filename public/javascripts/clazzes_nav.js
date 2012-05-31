/**
 * @author Tanzeel R.A. Kazi
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

function showCopyClassPopup()
{
	oPopUpWindow = new UI.Window({ theme: "rites",
               shadow: true, 
               width:  500, 
               height: 250}).setContent('<div class="popup_content"><table><tr><td>Class Name:</td><td><input type="text" name="firstname" /></td></tr><tr><td>Class Word:</td><td><input type="text" name="firstname" /></td></tr><tr><td>Class Description:</td><td><textarea id="class_description"></textarea></td></tr></table><div class="bottom_options"><div class="right_float"><button onclick="manageClassList("/portal/classes/manage")">Save</button><button onclick="destroyIt()">Cancel</button></div><div class="clear_both"></div></div></div>').show(true).center();
               
}

function destroyIt()
{
	alert("Destroying !!");
	oPopUpWindow.destroy();
}
