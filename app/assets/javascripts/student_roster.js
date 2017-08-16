var student_list_modal = null;
var student_popup_base_url = "/portal/classes/999/add_new_student_popup";

function close_popup()
{
    student_list_modal.handle.hide();
    student_list_modal = null;
}

function get_Add_Register_Student_Popup(strURL)
{
    student_list_modal = student_list_modal || null;
    if(student_list_modal !== null)
    {
        close_popup();
    }
    var lightboxconfig={
        content:"<div style='padding:10px'>Loading...Please Wait.</div>",
        title:"Register & Add New Student",
        width:500,
        height:350
    };
    student_list_modal = new Lightbox(lightboxconfig);
    var clazz_id = $("portal_clazz_id").value;
    var options = {
        method: 'post',
        onSuccess: function(transport) {
            var text = transport.responseText;
            text = "<div id='oErrMsgDiv' style='color:Red;font-weight:bold;margin-left: 7px;'></div>"+ text;
            student_list_modal.handle.setContent("<div style='padding:10px' test='foo'>" + text + "</div>");
            $$(".create_button").each(function(item) {
                createstatus = new CreateStatus(item);
            });
        }
    };
    var target_url = student_popup_base_url.replace(/999/,clazz_id);
    new Ajax.Request(target_url, options);
}

function add_New_Student_To_Class()
{
    $('oErrMsgDiv').innerHTML = "";
    var oForm = $('new_portal_student');
    var options = {
        method: 'post',
        onSuccess: function(transport) {
            var text = transport.responseText;
            var response = text.evalJSON(true);
            if (!response.success)
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

                $('oErrMsgDiv').innerHTML = error_msg;

                $$(".create_button").each(function(item) {
                    createstatus = new CreateStatus(item, false);
                    createstatus.showButton();
                });
            }
        }
    };

    oForm.request(options);
}
