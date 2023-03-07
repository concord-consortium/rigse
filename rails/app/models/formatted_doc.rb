class FormattedDoc
  
  def initialize(path)
    @document_path = File.join(::Rails.root.to_s, path)
    @html = "<p>Technical document: <i><b>#{File.basename(@document_path)}</i></b> not found</p>".html_safe
    if File.exists?(@document_path)
      @last_changed = File.ctime(@document_path)
    end
    @markup = @document_path[/\S+\.(textile|md)$/, 1]
    generate_html
  end
  
  def html
    if File.exists?(@document_path) && (File.ctime(@document_path) > @last_changed)
      @last_changed = File.ctime(@document_path)
      generate_html
    end
    @html
  end

private

  def generate_html
    if File.exists?(@document_path)
      case @markup
      when 'md'
        @html = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new).render(File.read(@document_path))
      else
        @html = "<p>Document: <i><b>#{File.basename(@document_path)}</i></b> not displayable.</p>".html_safe
      end
    end
  end

end
