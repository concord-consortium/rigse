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
    
    @http_mock = mock(Net::HTTP)
    @http_post_mock_1 = mock(Net::HTTP::Post)
    @http_post_mock_2 = mock(Net::HTTP::Post)
    
    
    @user_id_response = mock(Net::HTTPOK, :code => 200, :body => "<string>200</string>")
    @user_id_error_response = mock(Net::HTTPOK, :code => 200, :body => "<string></string>")
    @content_post_response = mock(Net::HTTPOK, :code => 200, :body => "<string>384</string>")
    @blog_post_response = mock(Net::HTTPOK, :code => 200, :body => "<int>600</int>")
    
    @wp = Wordpress.new
  end
  
  it 'should create the right xml for blog posting' do
    Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
    @http_mock.should_receive(:start).twice.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).twice.and_return(@http_post_mock_1, @http_post_mock_2)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once.with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<methodCall>\n "+
      "<methodName>extapi.callWpMethod</methodName>\n <params>\n  <param>\n   <value>\n    <string>login</string>\n"+
      "   </value>\n  </param>\n  <param>\n   <value>\n    <string>password</string>\n   </value>\n  </param>\n  "+
      "<param>\n   <value>\n    <string>wp_insert_post</string>\n   </value>\n  </param>\n  <param>\n   <value>\n   "+
      " <array>\n     <data>\n      <value>\n<struct>\n <member>\n  <name>post_author</name>\n  <value>\n  "+
      " <string>200</string>\n  </value>\n </member>\n <member>\n  <name>post_title</name>\n  <value>\n   "+
      "<string>my title</string>\n  </value>\n </member>\n <member>\n  <name>post_status</name>\n  <value>\n "+
      "  <string>publish</string>\n  </value>\n </member>\n <member>\n  <name>post_content</name>\n  <value>\n  "+
      " <string>my content</string>\n  </value>\n </member>\n</struct>\n      </value>\n     </data>\n  "+
      "  </array>\n   </value>\n  </param>\n </params>\n</methodCall>\n")
    @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)
    
    @wp.post_blog("blog", @normal_user, "my title", "my content");
  end
  
  it 'should create the right xml for blog creation' do
    Net::HTTP.should_receive(:new).once.and_return(@http_mock)
    @http_mock.should_receive(:start).once.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).once.and_return(@http_post_mock_1)
    @http_post_mock_1.should_receive(:body=).once.with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<methodCall>\n "+
    "<methodName>ms.CreateBlog</methodName>\n <params>\n  <param>\n   <value>\n    <string>login</string>\n   "+
    "</value>\n  </param>\n  <param>\n   <value>\n    <string>password</string>\n   </value>\n  </param>\n  "+
    "<param>\n   <value>\n<struct>\n <member>\n  <name>title</name>\n  <value>\n   "+
    "<string>joe user's Class name Class</string>\n  </value>\n </member>\n <member>\n  <name>domain</name>\n"+
    "  <value>\n   <string>example.com</string>\n  </value>\n </member>\n <member>\n  <name>user_id</name>\n "+
    " <value>\n   <string>email</string>\n  </value>\n </member>\n <member>\n  <name>path</name>\n  <value>\n"+
    "   <string>class word</string>\n  </value>\n </member>\n</struct>\n   </value>\n  </param>\n </params>\n"+
    "</methodCall>\n")
    @http_mock.should_receive(:request).once.and_return(@blog_post_response)
    
    @wp.create_class_blog("class word", @authorized_teacher, "class name")
  end

  it 'should create the right xml for user creation' do
    Net::HTTP.should_receive(:new).once.and_return(@http_mock)
    @http_mock.should_receive(:start).once.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).once.and_return(@http_post_mock_1)
    @http_post_mock_1.should_receive(:body=).once.with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<methodCall>\n"+
      " <methodName>extapi.callWpMethod</methodName>\n <params>\n  <param>\n   <value>\n    <string>login</string>\n"+
      "   </value>\n  </param>\n  <param>\n   <value>\n    <string>password</string>\n   </value>\n  </param>\n  <param>\n"+
      "   <value>\n    <string>wp_insert_user</string>\n   </value>\n  </param>\n  <param>\n   <value>\n    <array>\n"+
      "     <data>\n      <value>\n<struct>\n <member>\n  <name>user_login</name>\n  <value>\n   <string>create_user</string>\n"+
      "  </value>\n </member>\n <member>\n  <name>last_name</name>\n  <value>\n   <string>last</string>\n  </value>\n </member>\n <member>\n"+
      "  <name>user_pass</name>\n  <value>\n   <string>newpass</string>\n  </value>\n </member>\n <member>\n"+
      "  <name>user_email</name>\n  <value>\n   <string>create_user@concord.org</string>\n  </value>\n </member>\n"+
      " <member>\n  <name>first_name</name>\n  <value>\n   <string>first</string>\n  </value>\n </member>\n</struct>\n"+
      "      </value>\n     </data>\n    </array>\n   </value>\n  </param>\n </params>\n</methodCall>\n")
    @http_mock.should_receive(:request).once.and_return(@content_post_response)

    User.create!(:login => "create_user", :password => "newpass", :password_confirmation => "newpass", :first_name => "first", :last_name => "last", :email => "create_user@concord.org")
  end

  it 'should create the right xml for user updating' do
    Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
    @http_mock.should_receive(:start).twice.and_yield(@http_mock)
    Net::HTTP::Post.should_receive(:new).twice.and_return(@http_post_mock_1, @http_post_mock_2)
    @http_post_mock_1.should_receive(:body=).once
    @http_post_mock_2.should_receive(:body=).once.with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<methodCall>\n"+
      " <methodName>extapi.callWpMethod</methodName>\n <params>\n  <param>\n   <value>\n    <string>login</string>\n"+
      "   </value>\n  </param>\n  <param>\n   <value>\n    <string>password</string>\n   </value>\n  </param>\n  <param>\n"+
      "   <value>\n    <string>wp_update_user</string>\n   </value>\n  </param>\n  <param>\n   <value>\n    <array>\n"+
      "     <data>\n      <value>\n<struct>\n <member>\n  <name>user_login</name>\n  <value>\n   <string>normal_user</string>\n"+
      "  </value>\n </member>\n <member>\n  <name>ID</name>\n  <value>\n   <string>200</string>\n  </value>\n </member>\n"+
      " <member>\n  <name>last_name</name>\n  <value>\n   <string>newLast</string>\n  </value>\n </member>\n <member>\n"+
      "  <name>user_pass</name>\n  <value>\n   <string>newpass</string>\n  </value>\n </member>\n <member>\n"+
      "  <name>user_email</name>\n  <value>\n   <string>normal_user@concord.org</string>\n  </value>\n </member>\n"+
      " <member>\n  <name>first_name</name>\n  <value>\n   <string>newFirst</string>\n  </value>\n </member>\n</struct>\n"+
      "      </value>\n     </data>\n    </array>\n   </value>\n  </param>\n </params>\n</methodCall>\n")
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
    @http_post_mock_2.should_receive(:body=).once.with(%r!<name>user_pass</name>\n  <value>\n   <string>[a-f0-9]{32}</string>\n  </value>!)
    @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)

    @normal_user.destroy
  end
end
