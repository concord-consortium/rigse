class HelloReport < Prawn::Document
  def to_pdf
    image(Rails.root.join("public", "images", "new", "banners", "empty.png"), :width => 450)
    text("Generating a pdf report:")
    text("Using the Ruby Gem: <u><b><link href='http://github.com/sandal/prawn/wiki/'>Prawn</link></b></u>", :inline_format => true)
    text(Admin::Project.summary_info)
    render
  end
end
