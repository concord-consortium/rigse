
class UpdateCountries < ActiveRecord::Migration

  class PortalCountry < ActiveRecord::Base
    self.table_name = :portal_countries

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
         in_hash[:name] = in_hash[:name].strip.gsub("&","and")
         if in_hash[:name] == 'US'
           in_hash[:friendly_name] = 'United States'
         end
         if in_hash[:name] == 'UK'
           in_hash[:friendly_name] = 'United Kingdom'
         end
         existing = self.where("lower(name) like ?", in_hash[:name].downcase).first || self.new()
         existing.update_attributes(in_hash)
       end
    end
  end

  def up
    add_column :portal_countries, :friendly_name, :string, after: :formal_name
    PortalCountry.from_csv_file
  end

  def down
    remove_column :portal_countries, :friendly_name
  end

end
