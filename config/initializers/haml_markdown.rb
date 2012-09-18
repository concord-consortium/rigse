module Haml::Filters::Markdown
  include Haml::Filters::Base
  lazy_require "redcarpet"

  def render(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(text)
  end
end