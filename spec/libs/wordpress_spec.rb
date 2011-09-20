require File.expand_path('../../spec_helper', __FILE__)
require 'lib/wordpress'

describe Wordpress do

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    @project = Admin::Project.default_project

    @project.rpc_admin_login = "login"
    @project.rpc_admin_email = "email"
    @project.rpc_admin_password = "password"
    @project.word_press_url = "http://example.com"
    @project.save

    @mock_semester = Factory.create(:portal_semester, :name => "Fall")
    @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
    @normal_user = Factory.create(:user, :login => "normal_user", :first_name => "normal", :last_name => "user")
    @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"), :schools => [@mock_school])
    @portal_student = Factory.create(:portal_student, :user => Factory.create(:user, :login => "portal_student"))

    course = Factory(:portal_course)
    @clazz = Factory(:portal_clazz, {
      :section => "section",
      :start_time => DateTime.parse('2011-09-19'),
      :course => course
    })

    @http_mock = mock(Net::HTTP)
    @http_post_mock_1 = mock(Net::HTTP::Post)
    @http_post_mock_2 = mock(Net::HTTP::Post)
    @http_post_mock_3 = mock(Net::HTTP::Post)

    @user_id_response = mock(Net::HTTPOK, :code => 200, :body => "<string>200</string>")
    @user_id_error_response = mock(Net::HTTPOK, :code => 200, :body => "<string></string>")
    @content_post_response = mock(Net::HTTPOK, :code => 200, :body => "<string>384</string>")
    @blog_post_response = mock(Net::HTTPOK, :code => 200, :body => "<int>600</int>")
    @blog_id_response = mock(Net::HTTPOK, :code => 200, :body => "<string>213</string>")

    @wp = Wordpress.new
  end

  it 'should create the right xml for blog posting' do
    Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
    @http_mock.should_receive(:start).twice.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).twice.and_return(@http_post_mock_1, @http_post_mock_2)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once.with(
%!<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
 <methodName>extapi.callWpMethod</methodName>
 <params>
  <param>
   <value>
    <string>login</string>
   </value>
  </param>
  <param>
   <value>
    <string>password</string>
   </value>
  </param>
  <param>
   <value>
    <string>wp_insert_post</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
      <value>
<struct>
 <member>
  <name>post_author</name>
<value>
 <string>200</string>
</value>
 </member>
 <member>
  <name>post_title</name>
<value>
 <string>my title</string>
</value>
 </member>
 <member>
  <name>post_status</name>
<value>
 <string>publish</string>
</value>
 </member>
 <member>
  <name>post_content</name>
<value>
 <string>my content</string>
</value>
 </member>
</struct>
      </value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)

    @wp.post_blog("blog", @normal_user, "my title", "my content");
  end

  it 'should create the right xml for blog creation' do
    Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
    @http_mock.should_receive(:start).twice.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).twice.and_return(@http_post_mock_1, @http_post_mock_2)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once.with(%!<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
 <methodName>ms.CreateBlog</methodName>
 <params>
  <param>
   <value>
    <string>login</string>
   </value>
  </param>
  <param>
   <value>
    <string>password</string>
   </value>
  </param>
  <param>
   <value>
<struct>
 <member>
  <name>title</name>
<value>
 <string>joe user's Class name Class</string>
</value>
 </member>
 <member>
  <name>domain</name>
<value>
 <string>example.com</string>
</value>
 </member>
 <member>
  <name>user_id</name>
<value>
 <string>200</string>
</value>
 </member>
 <member>
  <name>path</name>
<value>
 <string>class word</string>
</value>
 </member>
</struct>
   </value>
  </param>
 </params>
</methodCall>
!)
    @http_mock.should_receive(:request).twice.and_return(@user_id_response, @blog_post_response)

    @wp.create_class_blog("class word", @authorized_teacher, "class name")
  end

  it 'should create the right xml for user creation' do
    Net::HTTP.should_receive(:new).once.and_return(@http_mock)
    @http_mock.should_receive(:start).once.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).once.and_return(@http_post_mock_1)
    @http_post_mock_1.should_receive(:body=).once.with(
%!<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
 <methodName>extapi.callWpMethod</methodName>
 <params>
  <param>
   <value>
    <string>login</string>
   </value>
  </param>
  <param>
   <value>
    <string>password</string>
   </value>
  </param>
  <param>
   <value>
    <string>wp_insert_user</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
      <value>
<struct>
 <member>
  <name>user_login</name>
<value>
 <string>create_user</string>
</value>
 </member>
 <member>
  <name>last_name</name>
<value>
 <string>last</string>
</value>
 </member>
 <member>
  <name>user_pass</name>
<value>
 <string>newpass</string>
</value>
 </member>
 <member>
  <name>user_email</name>
<value>
 <string>create_user@concord.org</string>
</value>
 </member>
 <member>
  <name>first_name</name>
<value>
 <string>first</string>
</value>
 </member>
</struct>
      </value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    @http_mock.should_receive(:request).once.and_return(@content_post_response)

    User.create!(:login => "create_user", :password => "newpass", :password_confirmation => "newpass", :first_name => "first", :last_name => "last", :email => "create_user@concord.org")
  end

  it 'should create the right xml for user updating' do
    Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
    @http_mock.should_receive(:start).twice.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).twice.and_return(@http_post_mock_1, @http_post_mock_2)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once.with(
%!<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
 <methodName>extapi.callWpMethod</methodName>
 <params>
  <param>
   <value>
    <string>login</string>
   </value>
  </param>
  <param>
   <value>
    <string>password</string>
   </value>
  </param>
  <param>
   <value>
    <string>wp_update_user</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
      <value>
<struct>
 <member>
  <name>user_login</name>
<value>
 <string>normal_user</string>
</value>
 </member>
 <member>
  <name>ID</name>
<value>
 <string>200</string>
</value>
 </member>
 <member>
  <name>last_name</name>
<value>
 <string>newLast</string>
</value>
 </member>
 <member>
  <name>user_pass</name>
<value>
 <string>newpass</string>
</value>
 </member>
 <member>
  <name>user_email</name>
<value>
 <string>normal_user@concord.org</string>
</value>
 </member>
 <member>
  <name>first_name</name>
<value>
 <string>newFirst</string>
</value>
 </member>
</struct>
      </value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)

    @normal_user.password = "newpass"
    @normal_user.password_confirmation = "newpass"
    @normal_user.first_name = "newFirst"
    @normal_user.last_name = "newLast"
    @normal_user.save!
  end

  it 'should create the right xml for user destroying' do
    Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
    @http_mock.should_receive(:start).twice.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).twice.and_return(@http_post_mock_1, @http_post_mock_2)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once.with(%r!<name>user_pass</name>\n<value>\n <string>[a-f0-9]{32}</string>\n</value>!)
    @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)

    @normal_user.destroy
  end

  it 'should create the right xml for adding a student to a class' do
    Net::HTTP.should_receive(:new).exactly(3).times.and_return(@http_mock)
    @http_mock.should_receive(:start).exactly(3).times.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).exactly(3).times.and_return(@http_post_mock_1, @http_post_mock_2, @http_post_mock_3)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once
    @http_post_mock_3.should_receive(:body=).once.with(
%!<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
 <methodName>extapi.callWpMethod</methodName>
 <params>
  <param>
   <value>
    <string>login</string>
   </value>
  </param>
  <param>
   <value>
    <string>password</string>
   </value>
  </param>
  <param>
   <value>
    <string>add_user_to_blog</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
<value>
 <string>200</string>
</value>
<value>
 <string>213</string>
</value>
<value>
 <string>author</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    @http_mock.should_receive(:request).exactly(3).times.and_return(@user_id_response, @blog_id_response, @content_post_response)

    @portal_student.student_clazzes.create!(:clazz_id => @clazz.id, :student_id => @portal_student.id, :start_time => Time.now)
  end

  it 'should create the right xml for removing a student from a class' do
    student_clazz = @portal_student.student_clazzes.create!(:clazz_id => @clazz.id, :student_id => @portal_student.id, :start_time => Time.now)

    Net::HTTP.should_receive(:new).exactly(3).times.and_return(@http_mock)
    @http_mock.should_receive(:start).exactly(3).times.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).exactly(3).times.and_return(@http_post_mock_1, @http_post_mock_2, @http_post_mock_3)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once
    @http_post_mock_3.should_receive(:body=).once.with(
%!<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
 <methodName>extapi.callWpMethod</methodName>
 <params>
  <param>
   <value>
    <string>login</string>
   </value>
  </param>
  <param>
   <value>
    <string>password</string>
   </value>
  </param>
  <param>
   <value>
    <string>remove_user_from_blog</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
<value>
 <string>213</string>
</value>
<value>
 <string>200</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    @http_mock.should_receive(:request).exactly(3).times.and_return(@user_id_response, @blog_id_response, @content_post_response)

    student_clazz.destroy
  end
end
