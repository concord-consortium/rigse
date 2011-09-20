require 'builder'
require 'net/http'
require 'lib/wordpress'

class Blog::BlogsController < ApplicationController
  def post_blog
    blog_name = params[:blog_name] + "/"
    post_title = params[:post_title]
    post_content = params[:post_content]
    post_tags = params[:post_tags]

    begin
      wp = Wordpress.new

      result = wp.post_blog(blog_name, current_user, post_title, post_content, post_tags)

      render :text => "OK!\n#{result}"
    rescue => e
      render :text => "NOT OK!\n#{e}", :status => 404
    end
  end
end

