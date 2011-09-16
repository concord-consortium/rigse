require 'builder'
require 'net/http'
require 'uri'

class Wordpress
  
  def initialize()
    project = Admin::Project.default_project
    @url = project.word_press_url
    @rpc_admin = project.rpc_admin_login
    @rpc_email = project.rpc_admin_email
    @rpc_password = project.rpc_admin_password
    raise "Can't talk to wordpress: No WP settings" if !has_valid_wp_settings?
  end

  def post_blog(blog, user, post_title, post_content)
    user_id = _get_user_id(user.login)

    # render the content template
    content = _create_blog_post_xml(post_title, post_content, user_id)

    # URI.parse("#{overlay_root}/#{runnable_id}")
    result = _post(content, blog)

    return result
  end
  
  def create_class_blog(class_word, teacher, class_name)
    # render the content template
    content = _create_create_class_blog_xml(class_word, teacher, class_name)
    result = _post(content)
    
    if result.body =~ /Site already exists/
      raise "Error creating class blog with id '#{class_word}': Site already exists"
    elsif result.body  =~ /fault/ || !(result.body  =~ /<int>([0-9]+?)<\/int>/)
      raise "Error creating class blog"
    else
      return $1
    end
  end

  def log_in_user(user_login, password)
    args = []
    args << "log=#{_escape(user_login)}"
    args << "pwd=#{_escape(password)}"
    args << "wp-submit=#{_escape("Login »")}"
    args << "sidebarlogin_posted=1"
    args << "testcookie=1"

    result = _post(args.join("&"), "", "/?_login=4838e49368")

    return result
  end
  
  def has_valid_wp_settings?
    return !(@url.nil? || @rpc_admin.nil? || @rpc_email.nil? || @rpc_password.nil?)
  end

  private

  require 'uri'
  
  def _escape(str)
    return URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def _post(content, blog = "", action = "/xmlrpc.php")
    uri = URI.parse(@url + blog + action)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port == 443
      http.use_ssl = true
    end
    http.start() do |conn|
      req = Net::HTTP::Post.new(uri.path)
      req.body = content
      response = conn.request(req)
      if response.code.to_i < 200 || (response.code.to_i >= 400)
        raise "Error creating blog post!"
      end
      return response
    end
  end

  def _get_user_id(user_name)
    xml = _create_xml("username_exists", true, user_name)
    result = _post(xml)
    if result.body =~ /<string>([0-9]+?)<\/string>/
      return $1
    else
      raise "Couldn't find user's id number"
    end
  end

  def _create_blog_post_xml(post_title, post_content, user_id)
    data = {
      "post_title" => post_title,
      "post_content" => post_content,
      "post_status" => "publish",
      "post_author" => user_id
    }
    return _create_xml("wp_insert_post", true, data)
  end
  
  def _create_create_class_blog_xml(class_word, teacher, class_name)
    uri = URI.parse(@url)
    data = {
      "domain" => uri.host,
      "path" => uri.path + class_word,
      "title" => "#{teacher.first_name} #{teacher.last_name}'s #{class_name.capitalize.to_s} Class",
      "user_id" => @rpc_email
    }
    return _create_xml("ms.CreateBlog", false, data)
  end

  # data can either be a hash or a single value
  def _create_xml(method_name, isExtApi, data)
    output = ""
    xml = Builder::XmlMarkup.new(:target => output, :indent => 1)
    xml.instruct!
    xml.methodCall {
      xml.methodName isExtApi ? "extapi.callWpMethod" : method_name
      xml.params {
        xml.param {
          xml.value {
            xml.string @rpc_admin
          }
        }
        xml.param {
          xml.value {
            xml.string @rpc_password
          }
        }
        if isExtApi
          xml.param {
            xml.value {
              xml.string method_name
            }
          }
        end
        xml.param {
          xml.value {
            if data.is_a? Hash
              if isExtApi
                xml.array {
                  xml.data {
                    xml.value {
                      _create_key_value_xml_struct(output, data)
                    }
                  }
                }
              else
                _create_key_value_xml_struct(output, data)
              end
            else
              xml.string data
            end
          }
        }
      }
    }
    return output
  end
  
  def _create_key_value_xml_struct(output, data)
    xml = Builder::XmlMarkup.new(:target => output, :indent => 1)
    xml.struct {
      data.each do |key, value|
        xml.member {
          xml.name key
          xml.value {
            if value.is_a? Fixnum
              xml.int value
            else
              xml.string value
            end
          }
        }
      end
    }
  end
end

