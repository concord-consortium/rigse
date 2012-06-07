
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

Then /^"(.+)" should be the last on the list with id "(.+)"$/ do|class_name, id_of_list|
  page.execute_script("
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
end

Given /^Following teacher and class mapping exists:$/ do |teacher_clazz|
  teacher_clazz.hashes.each do |hash|
    begin
        clazz = Portal::Clazz.find_by_name(hash['class_name'])
        user = User.find_by_login(hash['teacher'])
        teacher = Portal::Teacher.find_by_user_id(user.id)
        teacher_clazzObj = Portal::TeacherClazz.new()
        teacher_clazzObj.clazz_id = clazz.id
        teacher_clazzObj.teacher_id = teacher.id
        teacher_clazzObj.save!
        rescue ActiveRecord::RecordInvalid
          # assume this user is already created...
        end 
    end
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

And /^the following offerings exist in the classes:?/ do |offering_list|
   offering_list.hashes.each do |hash|
    begin
        investigation = Factory(:investigation)
        investigation.name = hash['name']
        investigation.save!
        myclazz = Portal::Clazz.find_by_name(hash['class'])
        offering = Portal::Offering.new
        offering.runnable_id = investigation.id
        offering.clazz_id = myclazz.id
        offering.runnable_type = 'Investigation'
        offering.save!
        rescue ActiveRecord::RecordInvalid
          # assume this user is already created...
        end 
    end 
end

