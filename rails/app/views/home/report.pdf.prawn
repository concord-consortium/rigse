prawn_document(:filename => 'Hello2.pdf') do |pdf|
  pdf.text "Generating a pdf view:"
  pdf.text("Using the Ruby Gems: <u><b><link href='http://github.com/sandal/prawn/wiki/'>Prawn</link></b></u> and <u><b><link href='https://github.com/Volundr/prawn-rails'>rawn_rails</link></b></u>", :inline_format => true)
end
