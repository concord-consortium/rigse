require 'builder'
require 'net/http'

class Blog::BlogsController < ApplicationController
  def post_blog
    blog_url = params[:blog_url]
    post_title = params[:post_title]
    post_content = params[:post_content]

    begin
      @uri = URI.parse(blog_url)
      user_id = _get_user_id(current_user.login)

      # render the content template
      content = _create_blog_post_xml(post_title, post_content, user_id)

      # URI.parse("#{overlay_root}/#{runnable_id}")
      result = _post(content)

      render :text => "OK!\n#{result}"
    rescue => e
      render :text => "NOT OK!\n#{e}", :status => 404
    end
  end

  private

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
      return response.body
    end
  end


  def _get_user_id(user_name)
    xml = _create_xml("username_exists", user_name)
    result = _post(xml)
    if result =~ /<string>([0-9]+?)<\/string>/
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
    return _create_xml("wp_insert_post", data)
  end


  # data can either be a hash or a single value
  def _create_xml(method_name, data)
    output = ""
    xml = Builder::XmlMarkup.new(:target => output, :indent => 1)
    xml.instruct!
    xml.methodCall {
      xml.methodName "extapi.callWpMethod"
      xml.params {
        xml.param {
          xml.value {
            xml.string "rpc-admin"
          }
        }
        xml.param {
          xml.value {
            xml.string "password"
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

