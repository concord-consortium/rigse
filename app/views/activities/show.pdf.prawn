prawn_document() do |pdf|
  pdf.tags :h1 => { :font_size => "3em", :font_weight => :bold },
           :h2 => { :font_size => "2.5em", :font_style => :italic },
           :h3 => { :font_size => "2em", :font_style => :italic },
           :h4 => { :font_size => "1.5em", :font_style => :italic },
           :p => { :font_size => "1.0em" },
           :ul => { :display => :break },
           :li => { :display => :break },
           :ol => { :display => :break },
           :img => { :display => :break }

  pdf.header pdf.margin_box.top_left do 
    pdf.font "Helvetica" do
     pdf.text "Here's My Fancy Header", :size => 25, :align => :center   
     pdf.stroke_horizontal_rule
    end
  end

  pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
    pdf.font "Helvetica" do
      pdf.stroke_horizontal_rule
      pdf.text "And here's a footer", :size => 16
    end
  end

  pdf.font "#{Prawn::BASEDIR}/data/fonts/Chalkboard.ttf"

  # pdf.font "Helvetica"
  pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], 
      :width  => pdf.bounds.width, :height => pdf.bounds.height - 100) do                 
    pdf.text "Activity name: #{@investigation.name}"
    pdf.text @investigation.description

  end
end

