require 'csv'

class Portal::Country < ActiveRecord::Base
    self.table_name = :portal_countries
    has_many :schools, :class_name => "Portal::School"

    def self.csv_filemame
        File.join(Rails.root,"resources/iso_3166_2_countries.csv")
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
            :common_name             => :name,
            :formal_name             => :formal_name,
            :capital                 => :capital,
            :iso_31661_2_letter_code => :two_letter,
            :iso_31661_3_letter_code => :three_letter,
            :iso_31661_number        => :iso_id,
            :iana_country_code_tld   => :tld
        }
    end

    def self.from_hash(in_hash)
        existing = self.find_by_tld(in_hash[:tld]) || self.new()
        existing.update_attributes(in_hash)
    end
end