require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/wordpress',__FILE__)

describe Wordpress do

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    @project = Admin::Project.default_project

    @project.rpc_admin_login = "login"
    @project.rpc_admin_email = "email"
    @project.rpc_admin_password = "password"
    @project.word_press_url = "http://example.com"
    @project.admin_accounts = ""
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

    @cust_pages_mocks = [
      mock(Net::HTTP::Post),
      mock(Net::HTTP::Post),
      mock(Net::HTTP::Post)
    ]

    @user_id_response          = mock(Net::HTTPOK, :code => 200, :body => "<string>200</string>")
    @user_id_error_response    = mock(Net::HTTPOK, :code => 200, :body => "<string></string>")
    @content_post_response     = mock(Net::HTTPOK, :code => 200, :body => "<string>384</string>")
    @blog_create_post_response = mock(Net::HTTPOK, :code => 200, :body => "<int>600</int>")
    @blog_id_response          = mock(Net::HTTPOK, :code => 200, :body => "<string>213</string>")
    @blog_public_response      = mock(Net::HTTPOK, :code => 200, :body => "<string>false</string>")
    @blog_private_response     = mock(Net::HTTPOK, :code => 200, :body => "<string>true</string>")

    @wp = Wordpress.new
  end

  it 'should create the right xml for blog posting (private)' do
    Net::HTTP.should_receive(:new).exactly(3).times.and_return(@http_mock)
    @http_mock.should_receive(:start).exactly(3).times.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).exactly(3).times.and_return(@http_post_mock_1, @http_post_mock_2, @http_post_mock_3)
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
    <string>get_option</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
<value>
 <string>cc_post_private_js</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
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
  <name>post_title</name>
<value>
 <string>my title</string>
</value>
 </member>
 <member>
  <name>post_content</name>
<value>
 <string>my content</string>
</value>
 </member>
 <member>
  <name>post_status</name>
<value>
 <string>private</string>
</value>
 </member>
 <member>
  <name>post_author</name>
<value>
 <string>200</string>
</value>
 </member>
 <member>
  <name>tags_input</name>
<value>
 <string>tag1,tag2,tag3</string>
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
    @http_mock.should_receive(:request).exactly(3).times.and_return(@user_id_response, @blog_private_response, @content_post_response)

    @wp.post_blog("blog", @normal_user, "my title", "my content", "tag1,tag2,tag3");
  end

  it 'should create the right xml for blog posting (public)' do
    Net::HTTP.should_receive(:new).exactly(3).times.and_return(@http_mock)
    @http_mock.should_receive(:start).exactly(3).times.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).exactly(3).times.and_return(@http_post_mock_1, @http_post_mock_2, @http_post_mock_3)
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
    <string>get_option</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
<value>
 <string>cc_post_private_js</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
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
  <name>post_title</name>
<value>
 <string>my title</string>
</value>
 </member>
 <member>
  <name>post_content</name>
<value>
 <string>my content</string>
</value>
 </member>
 <member>
  <name>post_status</name>
<value>
 <string>publish</string>
</value>
 </member>
 <member>
  <name>post_author</name>
<value>
 <string>200</string>
</value>
 </member>
 <member>
  <name>tags_input</name>
<value>
 <string>tag1,tag2,tag3</string>
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
    @http_mock.should_receive(:request).exactly(3).times.and_return(@user_id_response, @blog_public_response, @content_post_response)

    @wp.post_blog("blog", @normal_user, "my title", "my content", "tag1,tag2,tag3");
  end

  it 'should create the right xml for blog creation' do
    Net::HTTP.should_receive(:new).exactly(5).times.and_return(@http_mock)
    @http_mock.should_receive(:start).exactly(5).times.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).exactly(5).times.and_return(@http_post_mock_1, @http_post_mock_2, @cust_pages_mocks[0], @cust_pages_mocks[1], @cust_pages_mocks[2])
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
  <name>domain</name>
<value>
 <string>example.com</string>
</value>
 </member>
 <member>
  <name>path</name>
<value>
 <string>class_word</string>
</value>
 </member>
 <member>
  <name>title</name>
<value>
 <string>joe user's Class name Class</string>
</value>
 </member>
 <member>
  <name>user_id</name>
<value>
 <string>200</string>
</value>
 </member>
</struct>
   </value>
  </param>
 </params>
</methodCall>
!)
    Wordpress::TITLES.keys.each_with_index do |k, i|
      title = Wordpress::TITLES[k]
      content = Wordpress::SHORTCODES[k]
      @cust_pages_mocks[i].should_receive(:body=).once.with(%!<?xml version="1.0" encoding="UTF-8"?>
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
  <name>post_title</name>
<value>
 <string>#{title}</string>
</value>
 </member>
 <member>
  <name>post_content</name>
<value>
 <string>#{content}</string>
</value>
 </member>
 <member>
  <name>post_type</name>
<value>
 <string>page</string>
</value>
 </member>
 <member>
  <name>post_status</name>
<value>
 <string>publish</string>
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
    end
    @http_mock.should_receive(:request).exactly(5).times.and_return(@user_id_response, @blog_create_post_response)

    @wp.create_class_blog("class_word", @authorized_teacher, "class name")
  end

  it 'should create the right xml for blog creation (with extra admin accounts)' do
    @project.admin_accounts = "user1,user2, user3 ,user4 , user5"
    @project.save
    @wp = Wordpress.new

    @blog_id_mock = mock(Net::HTTP::Post)
    @admin_account_mocks = [
      [mock(Net::HTTP::Post), mock(Net::HTTP::Post)],
      [mock(Net::HTTP::Post), mock(Net::HTTP::Post)],
      [mock(Net::HTTP::Post), mock(Net::HTTP::Post)],
      [mock(Net::HTTP::Post), mock(Net::HTTP::Post)],
      [mock(Net::HTTP::Post), mock(Net::HTTP::Post)]
    ]

    Net::HTTP.should_receive(:new).exactly(20).times.and_return(@http_mock)
    @http_mock.should_receive(:start).exactly(20).times.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).exactly(20).times.and_return(
      @http_post_mock_1, @http_post_mock_2,
      @cust_pages_mocks[0], @cust_pages_mocks[1], @cust_pages_mocks[2],
      @blog_id_mock, @admin_account_mocks[0][0], @admin_account_mocks[0][1],
      @blog_id_mock, @admin_account_mocks[1][0], @admin_account_mocks[1][1],
      @blog_id_mock, @admin_account_mocks[2][0], @admin_account_mocks[2][1],
      @blog_id_mock, @admin_account_mocks[3][0], @admin_account_mocks[3][1],
      @blog_id_mock, @admin_account_mocks[4][0], @admin_account_mocks[4][1]
    )
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
  <name>domain</name>
<value>
 <string>example.com</string>
</value>
 </member>
 <member>
  <name>path</name>
<value>
 <string>class_word</string>
</value>
 </member>
 <member>
  <name>title</name>
<value>
 <string>joe user's Class name Class</string>
</value>
 </member>
 <member>
  <name>user_id</name>
<value>
 <string>200</string>
</value>
 </member>
</struct>
   </value>
  </param>
 </params>
</methodCall>
!)
    Wordpress::TITLES.keys.each_with_index do |k, i|
      title = Wordpress::TITLES[k]
      content = Wordpress::SHORTCODES[k]
      @cust_pages_mocks[i].should_receive(:body=).once.with(%!<?xml version="1.0" encoding="UTF-8"?>
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
  <name>post_title</name>
<value>
 <string>#{title}</string>
</value>
 </member>
 <member>
  <name>post_content</name>
<value>
 <string>#{content}</string>
</value>
 </member>
 <member>
  <name>post_type</name>
<value>
 <string>page</string>
</value>
 </member>
 <member>
  <name>post_status</name>
<value>
 <string>publish</string>
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
    end

    @blog_id_mock.should_receive(:body=).exactly(5).times.with(%!<?xml version="1.0" encoding="UTF-8"?>
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
    <string>get_blog_id</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
<value>
 <string>example.com</string>
</value>
<value>
 <string>class_word</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    id = 13
    @admin_account_mocks.each_with_index do |mocks, idx|
      id += 1

      mocks[0].should_receive(:body=).once.with(%!<?xml version="1.0" encoding="UTF-8"?>
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
    <string>username_exists</string>
   </value>
  </param>
  <param>
   <value>
    <array>
     <data>
<value>
 <string>user#{idx+1}</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)

      mocks[1].should_receive(:body=).once.with(%!<?xml version="1.0" encoding="UTF-8"?>
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
 <string>#{400+id}</string>
</value>
<value>
 <string>#{300+id}</string>
</value>
<value>
 <string>administrator</string>
</value>
     </data>
    </array>
   </value>
  </param>
 </params>
</methodCall>
!)
    end

    @http_mock.should_receive(:request).exactly(20).times.and_return(
      @user_id_response, @blog_create_post_response,
      @blog_create_post_response, @blog_create_post_response, @blog_create_post_response,
      mock(Net::HTTPOK, :code => 200, :body => "<string>414</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>314</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>214</string>"),
      mock(Net::HTTPOK, :code => 200, :body => "<string>415</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>315</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>215</string>"),
      mock(Net::HTTPOK, :code => 200, :body => "<string>416</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>316</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>216</string>"),
      mock(Net::HTTPOK, :code => 200, :body => "<string>417</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>317</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>217</string>"),
      mock(Net::HTTPOK, :code => 200, :body => "<string>418</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>318</string>"), mock(Net::HTTPOK, :code => 200, :body => "<string>218</string>")
    )

    @wp.create_class_blog("class_word", @authorized_teacher, "class name")
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
  <name>first_name</name>
<value>
 <string>first</string>
</value>
 </member>
 <member>
  <name>last_name</name>
<value>
 <string>last</string>
</value>
 </member>
 <member>
  <name>user_email</name>
<value>
 <string>create_user@concord.org</string>
</value>
 </member>
 <member>
  <name>user_pass</name>
<value>
 <string>newpass</string>
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
  <name>first_name</name>
<value>
 <string>newFirst</string>
</value>
 </member>
 <member>
  <name>last_name</name>
<value>
 <string>newLast</string>
</value>
 </member>
 <member>
  <name>user_email</name>
<value>
 <string>normal_user@concord.org</string>
</value>
 </member>
 <member>
  <name>user_pass</name>
<value>
 <string>newpass</string>
</value>
 </member>
 <member>
  <name>ID</name>
<value>
 <string>200</string>
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
