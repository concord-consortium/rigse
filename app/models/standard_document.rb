class StandardDocument < ActiveRecord::Base
  attr_accessible :jurisdiction, :name, :title, :uri

  #
  # Populate database with default Standard Documents
  #
  def self.create_defaults

      StandardDocument.find_or_create_by_name(
        :name           => "NGSS",
        :jurisdiction   => "Next Generation Science Standards",
        :title          => "Next Generation Science Standards",
        :uri            => "http://asn.jesandco.org/resources/D2454348" )

      StandardDocument.find_or_create_by_name(
        :name           => "NSES",
        :jurisdiction   => "National Science Education Standards",
        :title          => "National Science Education Standards",
        :uri            => "http://asn.jesandco.org/resources/D10001D0" )

      StandardDocument.find_or_create_by_name(
        :name           => "AAAS",
        :jurisdiction   => "American Association for the Advancement of Science",
        :title          => "Benchmarks for Science Literacy",
        :uri            => "http://asn.jesandco.org/resources/D2365735" )

      StandardDocument.find_or_create_by_name(
        :name           => "CCSS",
        :jurisdiction   => "Common Core State Standards",
        :title          => "Common Core State Standards for Mathematics",
        :uri            => "http://asn.jesandco.org/resources/D10003FB" )

  end

end
