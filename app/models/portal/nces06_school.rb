class Portal::Nces06School < ActiveRecord::Base
  set_table_name :portal_nces06_schools
  
  belongs_to :nces_district, :class_name => "Portal::Nces06District", :foreign_key => "nces_district_id"
  
  has_one :school, :class_name => "Portal::School", :foreign_key => "nces_school_id"
  
  self.extend SearchableModel

  @@searchable_attributes = %w{NCESSCH LEAID SCHNO SCHNAM PHONE MSTREE MCITY MSTATE MZIP}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "NCES School"
    end
  end
end
