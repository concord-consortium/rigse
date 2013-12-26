class Otrunk::ObjectExtractor
  require 'nokogiri'

  def initialize(otml)
    @otml = Nokogiri::XML(otml)
    @doc_id = @otml.at("otrunk[@id]")[:id]
  end

  def get_text_property(element, property)
    prop = nil

    return element.get_attribute(property) if element.has_attribute?(property)

    prop = element.xpath("./#{property}/text()")
    return '' if prop.nil?
    prop = prop[0] if prop.size > 1
    prop.text
  end

  # returns an array of zero or more elements or attributes
  def get_property(element, property)
    prop = nil

    return [element.get_attribute(property)] if element.has_attribute?(property)

    props = element.xpath("./#{property}")
    return [] if props.nil?

    results = []
    props.each do |prop|
      # we should now have an element
      next if ! prop.kind_of?(Nokogiri::XML::Element)

      resolved_children = resolve_elements(prop.children)
      if property =~ /\[(.*)\]$/
        results << resolved_children[$1.to_i]
      end
      results << resolved_children
    end
    return results
  end

  ## path is a '/' delimited list of otobject property names which will be traversed
  # and the values from the final path piece will be returned
  def get_property_path(element, path)
    path = path.split('/') unless path.is_a?(Array)
    element = [element] unless element.is_a?(Array)
    unless path.size < 1
      path_piece = path.shift
      results = []
      element.each do |el|
        results << get_property(el, path_piece)
      end
      element = get_property_path(results.flatten, path)
    end
    return element
  end

  def resolve_elements(elements)
    resolved = elements.map {|elem|
      out = nil
      if elem.elem?
        if elem.name == "object"
          ref = elem.get_attribute('refid')
          out = resolve_id(ref)
        else
          out = elem
        end
      end
      out
    }.compact

    return (resolved.empty? ? elements : resolved)
  end

  def resolve_id(id)
    if id =~ /$\{(.*?)\}/
      return resolve_local_id($1)
    elsif id =~ /(.*?)\!\/(.*)/
      return resolve_path_id($1, $2)
    elsif id =~ /^([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})$/
      return resolve_uuid($1)
    else
      return nil
    end
  end

  def resolve_local_id(local_id)
    elem = @otml.at("//[@local_id='#{local_id}']")
    return elem unless elem.nil?
    return resolve_entry("#{@doc_id}!/#{local_id}")
  end

  def resolve_path_id(parent_id, path_id)
    parent = (parent_id == @doc_id) ? @otml : resolve_uuid(parent_id)
    path_parts = path_id.split('/')
    if parent == @otml
      parent_local_id = path_parts.shift
      parent = resolve_local_id(parent_local_id)
    end
    path_parts.each do |path|
      break if parent.nil?
      parent = get_property(parent, path).first
    end
    if parent.nil?
      parent = resolve_entry("#{parent_id}!/#{path_id}")
    end
    return parent
  end

  def resolve_uuid(uuid)
    elem = @otml.at("//[@id='#{uuid}']")
    return elem unless elem.nil?
    return resolve_entry(uuid)
  end

  def resolve_entry(entry_key)
    elem = @otml.at("//entry[@key='#{entry_key}']")
    return (elem.nil? ? nil : elem.children.first)
  end

  def find_all(object_type, &block)
    elements = @otml.search("//#{object_type}")
    if block_given?
      elements.each do |element|
        yield(element)
      end
    else
      return elements
    end
  end

  def get_parent_id(element)
    parent = element.parent
    return parent.get_attribute('key') if parent.name == 'entry' && parent.has_attribute?('key')
    return parent.get_attribute('id') if parent.has_attribute?('id')
    return "#{@doc_id}!/#{parent.get_attribute('local_id')}" if parent.has_attribute?('local_id')
    ## FIXME detecting property names by first-letter capitalization is probably not the best way...
    return "#{get_parent_id(parent)}" + (parent.name =~ /^[A-Z]/ ? "" : "/#{parent.name}")
  end
end
