And /^I move the offering named "(.+)" to the top of the list on the class summary page$/ do|sortable_name|
  result = page.execute_script(
                      "
                       var bReturnValue = true;
                       var strUlId = 'clazz_offerings';
                       var sortableList = document.getElementById(strUlId);
                       if (sortableList === null)
                       {
                          return bReturnValue;
                       }
                       var arrListChildren = sortableList.getElementsByClassName('offering');
                       var offeringToMove = null;
                       var strListLabel = null;
                       for(var i=0; i< arrListChildren.length; i++)
                       {
                          strListLabel = arrListChildren[i].getElementsByClassName('component_title')[0].innerHTML.stripTags().strip();
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
                       Sortable.sortables[strUlId].onUpdate.call();
                       return bReturnValue;
                       "
                     )
  raise 'Could not move the offering in the list' if result == false
end

Then /^the offering named "(.+)" should be the first on the list on the class summary$/ do|class_name|
  result = page.execute_script("
                                 var bSortSuccess = false;
                                 var strUlId = 'clazz_offerings'
                                 var oLabel = $$('#'+strUlId+' > li:first-child span.component_title')[0];
                                 var strClassNameOfTopMostClass = oLabel.innerHTML.stripTags().strip()
                                 if(strClassNameOfTopMostClass == '#{class_name}')
                                 {
                                    bSortSuccess = true;
                                 }
                                 return bSortSuccess; 
                              ")
  raise 'Offering is not the first on the list' if result == false
end

