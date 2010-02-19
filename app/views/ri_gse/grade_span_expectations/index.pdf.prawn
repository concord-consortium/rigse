pdf.tags :h1 => { :font_size => "3em", :font_weight => :bold },
         :h2 => { :font_size => "2.5em", :font_style => :italic },
         :h3 => { :font_size => "2em", :font_style => :italic },
         :h4 => { :font_size => "1.5em", :font_style => :italic },
         :p => { :font_size => "1.0em" },
         :ul => { :display => :break },
         :li => { :display => :break },
         :ol => { :display => :break },
         :dl => { :display => :break },
         :dt => { :display => :break },
         :dd => { :display => :break },
         :div => { :display => :break },
         :img => { :display => :break }

# serif_font  = "/Library/Fonts/Baskerville.dfont" 

serif_font  = File.join([RAILS_ROOT] + %w{fonts Temporarium_version_1.1 Temporarium.ttf})

if File.exists?(serif_font)
  pdf.font_families["Baskerville"] = {
    :normal      => { :file => serif_font, :font => 1 },
    :italic      => { :file => serif_font, :font => 2 },
    :bold        => { :file => serif_font, :font => 4 }, # semi-bold, not bold
    :bold_italic => { :file => serif_font, :font => 3 }
  }
  pdf.font "Baskerville", :size => 14
else
  warn "Baskerville font is preferred for the manual, but could not be found. Using Times-Roman."
  pdf.font "Times-Roman", :size => 14
end

pdf.header pdf.margin_box.top_left do 
  pdf.pad(10) do
    pdf.text "Rhode Island Grade Span Expectations", :size => 25, :align => :center
  end
  pdf.stroke_horizontal_rule
end

pdf_footer(@search_string.empty? ? "" : "Grade spans matching: #{@search_string}")

# pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
#   pdf.stroke_horizontal_rule
#   pdf.pad(10) do
#     unless @search_string.empty?
#       pdf.text "Grade spans matching: #{@search_string}", :size => 16
#     end
#   end
# end

# pdf.font "#{Prawn::BASEDIR}/data/fonts/Chalkboard.ttf"

# pdf.font "Helvetica"
pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], 
    :width  => pdf.bounds.width, :height => pdf.bounds.height - 100) do
  pdf.text @rendered_partial
end