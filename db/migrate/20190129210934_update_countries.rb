
class UpdateCountries < ActiveRecord::Migration

  class PortalCountry < ActiveRecord::Base
    self.table_name = :portal_countries

    @country_names_to_update = {
      'Aland' => 'Åland Islands',
      'Bahamas, The' => 'Bahamas',
      'Bosnia and Herzegovina' => 'Bosnia',
      'Congo, (Congo ? Brazzaville)' => 'Congo - Brazzaville',
      'Congo, (Congo ? Kinshasa)' => 'Congo - Kinshasa',
      'Cote d’Ivoire (Ivory Coast)' => 'Côte d’Ivoire',
      'Falkland Islands (Islas Malvinas)' => 'Falkland Islands',
      'Gambia, The' => 'Gambia',
      'Heard Island and McDonald Islands' => 'Heard and McDonald Islands',
      'Korea, North' => 'North Korea',
      'Korea, South' => 'South Korea',
      'Myanmar (Burma)' => 'Myanmar',
      'Saint Lucia' => 'St. Lucia',
      'Saint Helena' => 'St. Helena',
      'Saint Kitts and Nevis' => 'St. Kitts and Nevis',
      'Saint Pierre and Miquelon' => 'St. Pierre and Miquelon',
      'Saint Vincent and the Grenadines' => 'St. Vincent and the Grenadines',
      'South Georgia & South Sandwich Islands' => 'South Georgia and South Sandwich Islands',
      'Svalbard' => 'Svalbard and Jan Mayen',
      'Timor-Leste (East Timor)' => 'Timor-Leste'
    }

    def self.fix_existing_names
      @country_names_to_update.each_pair do |key, value|
        if existing = self.where("lower(name) like ?", key.downcase).first
          existing.update_attributes(:name => value)
        end
      end
    end

    def self.csv_filemame
        File.join(Rails.root,"resources/country-codes_csv.csv")
    end

    def self.from_csv_file
        body   = File.open(self.csv_filemame).read
        csv    = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => [:all])
        hashes = csv.to_a.map {|row| row.to_hash }
        hashes.map! { |h| from_hash(remap_keys(h)) }
    end

    def self.remap_keys(in_hash)
        result = Hash[in_hash.map {|k, v| [field_name_map[k] || :xxxX, v] }]
        result.delete(:xxxX)
        result
    end

    def self.field_name_map
        {
            :cldr_display_name      => :name,
            :official_name_en       => :formal_name,
            :capital                => :capital,
            :iso31661alpha2         => :two_letter,
            :iso31661alpha3         => :three_letter,
            :iso31661numeric        => :iso_id,
            :tld                    => :tld
        }
    end

    def self.from_hash(in_hash)
      if in_hash[:name]
        in_hash[:name] = adjust_country_name(in_hash[:name])

        existing = self.where("lower(name) like ?", in_hash[:name].downcase).first || self.new()
        existing.update_attributes(in_hash)
      end
    end

    def self.adjust_country_name(name)
      name = name.strip.gsub("&","and")
      name = name.gsub(/^UK$/, "United Kingdom")
      name = name.gsub(/^US$/, "United States")
      name
    end
  end

  def up
    PortalCountry.fix_existing_names
    PortalCountry.from_csv_file
  end

  def down
    # Nothing to do.
  end

end
