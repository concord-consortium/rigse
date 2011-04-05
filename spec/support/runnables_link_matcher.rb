module RunnablesLinkMatcher
  class BeLinkLike
    def initialize(href, css_class, image, link_text)
      @href, @css_class, @image, @link_text = href, css_class, image, link_text
    end

    def matches?(target)
      @target = target
      @target.should =~ /(.*)#{@href}(.*)#{@css_class}(.*)#{@image}(.*)(#{@link_text}(.*))?/i
    end

    def failure_message
      "Expected a properly formed link."
    end

    def negative_failure_message
      "Expected an improperly formed link."
    end
  end

  def be_link_like(href, css_class, image, link_text="")
    BeLinkLike.new(href, css_class, image, link_text)
  end
end
