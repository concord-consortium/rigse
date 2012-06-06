
And /^I follow copy class link for first class$/ do
  xpath_for_list_elem = "//ul[@id=\"sortable\"]/li[1]"
  within(:xpath, xpath_for_list_elem) do
    click_link('Copy Class')
  end
end


And /^I move "(.+)" to the top of the list with id "(.+)"$/ do|sortable_name, id_of_list|
  page.execute_script(
                      "
                       var strUlId = '#{id_of_list}';
                       var sortableList = document.getElementById(strUlId);
                       var arrListChildren = sortableList.getElementsByTagName('li');
                       var offeringToMove = null;
                       var strListLabel = null;
                       for(var i=0; i< arrListChildren.length; i++)
                       {
                          strListLabel = arrListChildren[i].getElementsByTagName('label')[0].innerHTML.stripTags().strip();
                          if(strListLabel == '#{sortable_name}')
                          {
                            offeringToMove = arrListChildren[i];
                            break;
                          }
                       }
                       var listFirstChild = arrListChildren[0]; 
                       if(offeringToMove && offeringToMove != listFirstChild)
                       {
                        sortableList.removeChild(offeringToMove);
                        sortableList.insertBefore(offeringToMove,listFirstChild);
                       }
                       
                       "
                     )
end  

Then /^"(.+)" should be the first on the list with id "(.+)"$/ do|class_name, id_of_list|
  page.execute_script("
                       var bSortSuccess = false;
                       var strUlId = '#{id_of_list}'
                       var oLabel = $$('#'+strUlId+' > li:first-child label')[0];
                       var strClassNameOfTopMostClass = oLabel.innerHTML.stripTags().strip()
                       if(strClassNameOfTopMostClass == '#{class_name}')
                       {
                          bSortSuccess = true;
                       }
                       return bSortSuccess; 
                    ")
end