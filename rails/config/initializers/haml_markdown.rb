require 'haml'
require 'haml/filters'
require 'redcarpet'

module Haml
  module Filters
    class Markdown < Base
      def render(text)
        Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text)
      end
    end
  end
end
