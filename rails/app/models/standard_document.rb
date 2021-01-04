class StandardDocument < ActiveRecord::Base
  #
  # Populate database with default Standard Documents
  #
  def self.create_defaults
      StandardDocument.where(name: "NGSS").first_or_create(
        :jurisdiction   => "Next Generation Science Standards",
        :title          => "Next Generation Science Standards",
        :uri            => "http://asn.jesandco.org/resources/D2454348" )

      StandardDocument.where(name: "NSES").first_or_create(
        :jurisdiction   => "National Science Education Standards",
        :title          => "National Science Education Standards",
        :uri            => "http://asn.jesandco.org/resources/D10001D0" )

      StandardDocument.where(name: "AAAS").first_or_create(
        :jurisdiction   => "American Association for the Advancement of Science",
        :title          => "Benchmarks for Science Literacy",
        :uri            => "http://asn.jesandco.org/resources/D2365735" )

      StandardDocument.where(name: "CCSS").first_or_create(
        :jurisdiction   => "Common Core State Standards",
        :title          => "Common Core State Standards for Mathematics",
        :uri            => "http://asn.jesandco.org/resources/D10003FB" )
  end

end
