require 'builder'
require 'net/http'
require 'lib/wordpress'

class Blog::BlogsController < ApplicationController
  def post_blog
    blog_url = params[:blog_url]
    post_title = params[:post_title]
    post_content = params[:post_content]

    begin
      wp = Wordpress.new(blog_url)

      result = wp.post_blog(post_title, post_content)

      render :text => "OK!\n#{result}"
    rescue => e
      render :text => "NOT OK!\n#{e}", :status => 404
    end
  end
end

