module TruncatableXhtml
  #
  # Extracts and soft truncates text from an xhtml document stored
  # in the an attribute for models this module is included in.
  #
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
end
