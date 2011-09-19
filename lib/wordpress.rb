require 'builder'
require 'net/http'
require 'uri'
require 'uuidtools'

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

  def create_user(user)
    content = _create_user_xml(user, false)
    result = _post(content)
    return result
  end

  def update_user(user)
    content = _create_user_xml(user, true)
    result = _post(content)
    return result
  end

  def destroy_user(user)
    # just set the user's password to gibberish
    user.password = user.password_confirmation = UUIDTools::UUID.timestamp_create.hexdigest
    update_user(user)
  end

  def add_user_to_clazz(user, clazz)
    content = _create_add_user_to_blog_xml(user, clazz)
    result = _post(content)
    return result
  end

  def remove_user_from_clazz(user, clazz)
    content = _create_remove_user_from_blog_xml(user, clazz)
    result = _post(content)
    return result
  end

  def has_valid_wp_settings?
    return !(@url.nil? || @rpc_admin.nil? || @rpc_email.nil? || @rpc_password.nil?)
  end

  private

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
    xml = _create_xml("username_exists", true, [user_name])
    result = _post(xml)
    if result.body =~ /<string>([0-9]+?)<\/string>/
      return $1
    else
      raise "Couldn't find user's id number"
    end
  end

  def _get_blog_id(domain, path)
    xml = _create_xml("get_blog_id", true, [domain, path])
    result = _post(xml)
    if result.body =~ /<string>([0-9]+?)<\/string>/
      return $1
    else
      raise "Couldn't find blog's id number"
    end
  end

  def _create_remove_user_from_blog_xml(user, clazz)
    uri = URI.parse(@url)
    domain = uri.host
    path = uri.path + clazz.class_word

    blog_id = _get_blog_id(domain, path)
    user_id = _get_user_id(user.login)

    return _create_xml("remove_user_from_blog", true, [user_id, blog_id])
  end

  def _create_add_user_to_blog_xml(user, clazz)
    uri = URI.parse(@url)
    domain = uri.host
    path = uri.path + clazz.class_word

    blog_id = _get_blog_id(domain, path)
    user_id = _get_user_id(user.login)

    role = "author"
    return _create_xml("add_user_to_blog", true, [blog_id, user_id, role])
  end

  def _create_blog_post_xml(post_title, post_content, user_id)
    data = {
      "post_title" => post_title,
      "post_content" => post_content,
      "post_status" => "publish",
      "post_author" => user_id
    }
    return _create_xml("wp_insert_post", true, [data])
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

  def _create_user_xml(user, update = false)
    data = {
      "user_login" => user.login,
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "user_email" => user.email
    }

    # if the password_confirmation exists, we'll assume the password is changing and set it in the data
    data["user_pass"] = user.password_confirmation if user.password_confirmation
    data["ID"] = _get_user_id(user.login) if update

    # use wp_update_user so that we can pass in a plaintext password on updating.
    # wp_insert_user only accepts plaintext passwords on creation.
    method = update ? "wp_update_user" : "wp_insert_user"
    return _create_xml(method, true, [data])
  end

  # data must be an array
  def _create_xml(method_name, isExtApi, data = [])
    raise "Invalid data! Needs to be an array" if isExtApi && !data.is_a?(Array)

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
            if isExtApi
              xml.array {
                xml.data {
                  data.each do |param|
                    xml.value {
                      if param.is_a? Hash
                        _create_key_value_xml_struct(output, param)
                      else
                        _create_value_xml_struct(output, param)
                      end
                    }
                  end
                }
              }
            else
              _create_key_value_xml_struct(output, data)
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
          _create_value_xml_struct(output, value)
        }
      end
    }
  end

  def _create_value_xml_struct(output, value)
    xml = Builder::XmlMarkup.new(:target => output, :indent => 1)
    xml.value {
      if value.is_a? Fixnum
        xml.int value
      else
        xml.string value
      end
    }
  end
end

