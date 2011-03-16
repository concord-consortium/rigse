module TruncatableXhtml
  #
  # Extracts and soft truncates text from an xhtml document stored
  # in the an attribute for models this module is included in.
  #
  # Including TruncatableXhtml adds a before_save hook which will automatically
  # generate a name attribute for the model instance if there is any content on 
  # the main xhtml attribute (examples: content or prompt) that can plausibly be 
  # turned into a name. Otherwise the default_value_for :name specified below is used.
  # 
  # At this time (2009-12) this is used in the following models:
  # 
  #   app/models/multiple_choice.rb
  #   app/models/open_response.rb
  #   app/models/xhtml.rb
  #
  # FIXME: refactor code to use names like 'DEFAULT_ATTRIBUTES' instead of 'DEFAULT_TABLES'
  # Using the word 'table' to refer to the attributes of a table is confusing.
  
  def truncate_from_xhtml(xhtml, limit=24, soft_limit=8, logging=false)
    return '' unless xhtml && !xhtml.empty?
    print "#{self.id}: " if logging
    extracted_text = extract_first_text(xhtml)
    truncated_text = soft_truncate(extracted_text, limit, soft_limit)
    puts "#{truncated_text}" if logging
    truncated_text
  end
  #
  # Finds the first text element that has non-whitespace
  # using a depth first search of the xhtml tree.
  #
  def extract_first_text(xhtml)
    texts = extract_text_from_elements(xhtml)
    texts.empty? ? '' : texts[0]
  end
  #
  # Extract an array of the text content of elements with text.
  # return and empty array if:
  #
  #   the xhtml string can't be parsed
  #   there are no text elements with non-whitespace characters 
  #
  def extract_text_from_elements(xhtml)
    return '' if xhtml.empty?
    begin
      doc = Hpricot.XML(xhtml)
      text_contents = []
      doc.children.each do |child| 
        child.traverse_text do |text_element| 
          t = text_element.to_s.strip
          text_contents << t unless t.empty?
        end
      end
    rescue ArgumentError
    end
    text_contents
  end
  #
  # Truncates a string to length characters with an additional 
  # optional soft limit. If a soft_limit length is specified  
  # and a word in the string crosses the length boundary the
  # length of the returned string will be increased up to a
  # total length of (length + soft_limit) in an attempt to
  # complete the last word.
  #
  # "Will someone else try to match the graph?"
  #
  def soft_truncate(string, length, soft_limit=nil)
    return '' unless string
    string.strip!
    return string if string.length <= length
    firstpart = string[0..(length-1)]
    afterpart = string[length..-1]
    does_not_start_with_whitespace = afterpart[/^\S/]
    afterpart.strip!
    return firstpart if afterpart.empty?
    return firstpart << ' ...' unless soft_limit && does_not_start_with_whitespace
    afterword = afterpart[/(\S+)/][0..(soft_limit-1)]
    afterword << ' ...' if afterpart.length > afterword.length
    firstpart << afterword
  end
  
  ##
  ## Two good places to look for Embeddable::XhtmlContent
  ##
  DEFAULT_TABLES = [
    "content",
    "prompt"
  ]

  # DEFAULT_REPLACEABLES=  [
  #   /\s+style\s?=\s?"(.*?)"/,
  #   /&nbsp;/
  # ]
  # 
  REPLACEMENT_MAP={
    /\s+style\s?=\s?"(.*?)"/ => "",
    /(&nbsp;)+/ => " "}
    
  ## for ITSI carolyn might want everything 
  unless Admin::Project.default_project.empty?
    if (!Admin::Project.project_settings.blank? && Admin::Project.project_settings.dont_sanitize_xhtml)
      REPLACEMENT_MAP = {}
    end
  end
  
  ##
  ## These methods are added to the class when 
  ## this module is included:
  ##
  module ClassMethods
    ## has_html_tables (you can specify table names that have html content)
    ##  @param table_anames = names of attributes that might have html content.
    ##  @ param replaceables = patterns we want to exlude from the sanitized output.
    def has_html_tables(table_names = DEFAULT_TABLES,replaceables = REPLACEMENT_MAP)
      define_method("html_tables") do
        table_names
      end
      define_method("html_replacements") do
        replaceables
      end
    end
  end
  
  
  ##
  ## Called when a class extends this module:
  ##
  def self.included(clazz)
    clazz.extend(ClassMethods)
    clazz.has_html_tables
    
    ## add before_save hooks
    clazz.class_eval {
      alias old_before_save before_save
      def before_save
        self.old_before_save
        if (self.respond_to? 'name')
          self.html_tables.each do |tablename|
            if self.respond_to? tablename
              truncated_xhtml = truncate_from_xhtml(self.send(tablename))
              self.name = truncated_xhtml unless truncated_xhtml.empty?
            end
          end
        end
        self.replace_offensive_html
      end
    }
  end
  
  ##
  ## remove any HTML patterns that we don't want.
  ##
  def replace_offensive_html
    logger.debug "calling replace_offensive_html"
    html_tables.each do |tablename|
      if self.respond_to? tablename
        html_replacements.each_pair do |replacable,replacement|
          self.send("#{tablename}=",(self.send tablename).gsub(replacable,replacement))
        end
      end
    end
    self
  end
  
end
