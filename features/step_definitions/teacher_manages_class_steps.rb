
And /^I follow copy class link for first class$/ do
  xpath_for_list_elem = "//ul[@id=\"sortable\"]/li[2]"
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

And /^the Manage class list state starts saving$/ do
  page.execute_script("SaveManageClassListState();")
end

And /^the modal for saving manage classes dissappears$/ do
  page.has_no_css?('div.invisible_modal.show')
end

Then /^"(.+)" should be the first on the list with id "(.+)"$/ do|class_name, id_of_list|
  result = page.execute_script("
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
  raise 'Not first on the list' if result == false
end

Then /^"(.+)" should be the last on the list with id "(.+)"$/ do|class_name, id_of_list|
  result = page.execute_script("
                                 var bSortSuccess = false;
                                 var strUlId = '#{id_of_list}'
                                 var oLabel = $$('#'+strUlId+' > li:last-child label')[0];
                                 var strClassNameOfTopMostClass = oLabel.innerHTML.stripTags().strip()
                                 if(strClassNameOfTopMostClass == '#{class_name}')
                                 {
                                    bSortSuccess = true;
                                 }
                                 return bSortSuccess; 
                              ")
  raise 'Not last on the list' if result == false                                
end


And /^"(.+)" should be the last class$/ do |class_name|
  within(:xpath, '//li[last()]') do
    has_content?("#{class_name}")
  end
end

And /^"(.+)" should be the first class$/ do |class_name|
  within(:xpath, '//li[2]') do
    has_content?("#{class_name}")
  end
end


And /^there should be no student in "(.+)"$/ do |class_name|
  click_link(class_name)
  page.has_content?('No students registered for this class yet.')  
end

