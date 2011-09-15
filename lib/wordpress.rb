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
    debugger
    result = _post(content)

    return result
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
    return _create_xml("wp_insert_post", data)
  end
  
  def _create_create_class_blog_xml(class_word, teacher, class_name)
    data = {
      "domain" => @uri.host,
      "path" => "/" + class_word,
      "title" => "#{teacher.first_name} #{teacher.last_name}'s #{class_name} Class"
    }
    return _create_xml("create_empty_blog", data)
  end

  # data can either be a hash or a single value
  def _create_xml(method_name, data, admin_username = RPC_ADMIN, admin_password = RPC_ADMIN_PASS)
    output = ""
    xml = Builder::XmlMarkup.new(:target => output, :indent => 1)
    xml.instruct!
    xml.methodCall {
      xml.methodName "extapi.callWpMethod"
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
        xml.param {
          xml.value {
            xml.string method_name
          }
        }
        xml.param {
          xml.value {
            if data.is_a? Hash
              xml.array {
                xml.data {
                  xml.value {
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
                  }
                }
              }
            else
              xml.string data
            end
          }
        }
      }
    }
    return output
  end
end

