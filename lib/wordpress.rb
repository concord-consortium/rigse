require 'builder'
require 'net/http'
require 'uri'

class Wordpress
  RPC_ADMIN = "rpc-admin"
  RPC_ADMIN_PASS = "password"
  
  def initialize(blog_url)
    @uri = URI.parse(blog_url)
  end

  def get_user_id(user_name)
    xml = _create_xml("username_exists", user_name)
    result = _post(xml)
    if result.body =~ /<string>([0-9]+?)<\/string>/
      return $1
    else
      raise "Couldn't find user's id number"
    end
  end

  def post_blog(user, post_title, post_content)
    user_id = get_user_id(user.login)

    # render the content template
    content = _create_blog_post_xml(post_title, post_content, user_id)

    # URI.parse("#{overlay_root}/#{runnable_id}")
    result = _post(content)

    return result
  end
  
  def create_class_blog(class_word, teacher, class_name)
    # render the content template
    content = _create_create_class_blog_xml(class_word, teacher, class_name)
    result = _post(content)
    if result =~ /fault/
      raise "Error creating class blog with id: #{class_word}"
    else  
      return result
    end
  end

  def log_in_user(user_login, password)
    args = []
    args << "log=#{_escape(user_login)}"
    args << "pwd=#{_escape(password)}"
    args << "wp-submit=#{_escape("Login »")}"
    args << "sidebarlogin_posted=1"
    args << "testcookie=1"

    result = _post(args.join("&"))

    return result
  end

  private

  require 'uri'
  def _escape(str)
    return URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def _post(content)
    http = Net::HTTP.new(@uri.host, @uri.port)
    if @uri.port == 443
      http.use_ssl = true
    end
    http.start() do |conn|
      req = Net::HTTP::Post.new(@uri.path)
      req.body = content
      response = conn.request(req)
      if response.code.to_i < 200 || (response.code.to_i >= 400)
        raise "Error creating blog post!"
      end
      return response
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
    data = {
      "domain" => @uri.host,
      "path" => "/journal/" + class_word,
      "title" => "#{teacher.first_name} #{teacher.last_name}'s #{class_name} Class",
      "user_id" => "sfentress@concord.org"
    }
    return _create_xml("ms.CreateBlog", false, data)
  end

  # data can either be a hash or a single value
  def _create_xml(method_name, isExtApi, data, admin_username = RPC_ADMIN, admin_password = RPC_ADMIN_PASS)
    output = ""
    xml = Builder::XmlMarkup.new(:target => output, :indent => 1)
    xml.instruct!
    xml.methodCall {
      xml.methodName isExtApi ? "extapi.callWpMethod" : method_name
      xml.params {
        xml.param {
          xml.value {
            xml.string admin_username
          }
        }
        xml.param {
          xml.value {
            xml.string admin_password
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

