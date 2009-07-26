module TruncatableXhtml
  #
  # Extracts and soft truncates text from an xhtml document stored
  # in the an attribute for models this module is included in.
  #
  def truncate_from_xhtml(attribute, limit=24, soft_limit=8)
    begin
      child = Hpricot.XML(attribute).children.first
      while child.kind_of? Hpricot::Elem
        child = child.children.first
      end
      extracted_text = child.to_s.gsub(/\s*\n/, ' ')
      soft_truncate(extracted_text, limit, soft_limit)
    rescue ArgumentError
      ''
    end
  end
  #
  # Truncates a string to length characters with an additional 
  # optional soft limit. If a soft_limit length is specified  
  # and a word in the string crosses the length boundary the
  # length of the returned string will be increased up to a
  # total length of (length + soft_limit) in an attempt to
  # complete the last word.
  #
  def soft_truncate(string, length, soft_limit=nil)
    return '' unless string
    string.strip!
    return string if string.length <= length
    firstpart = string[0..(length-1)]
    afterpart = string[length..-1]
    starts_with_whitespace = afterpart[/^\s/]
    afterpart.strip!
    return firstpart if afterpart.empty?
    return firstpart << ' ...' unless soft_limit || starts_with_whitespace
    afterword = afterpart[/(\S+)/][0..(soft_limit-1)]
    afterword << ' ...' if afterpart.length > afterword.length
    firstpart << afterword
  end
end
