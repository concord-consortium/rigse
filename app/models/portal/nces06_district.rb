class Portal::Nces06District < ActiveRecord::Base
  set_table_name :portal_nces06_districts
  
  has_many :nces_schools, :class_name => "Portal::Nces06School", :foreign_key => "nces_district_id"

  has_many :minimized_nces_schools, :class_name => "Portal::Nces06School", :foreign_key => "nces_district_id", 
    :select => "id, nces_district_id, NCESSCH, LEAID, SCHNO, STID, SEASCH, SCHNAM, GSLO, GSHI, PHONE, MEMBER, FTE, TOTFRL, AM, ASIAN, HISP, BLACK, WHITE, LATCOD, LONCOD, MCITY, MSTREE, MSTATE, MZIP"

  has_one :district, :class_name => "Portal::District", :foreign_key => "nces_district_id"

  self.extend SearchableModel

  @@searchable_attributes = %w{LEAID NAME PHONE MSTREE MCITY MSTATE MZIP}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end
  
  def capitalized_name
    self.NAME.split.collect {|w| w.capitalize}.join(' ').gsub(/\b\w/) { $&.upcase }
  end
  
end
