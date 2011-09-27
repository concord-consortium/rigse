class HelloReport < Prawn::Document
  def to_pdf
    text("Generating a pdf report:")
    text("Using the Ruby Gem: <u><b><link href='http://github.com/sandal/prawn/wiki/'>Prawn</link></b></u>", :inline_format => true)
    render
  end
end
