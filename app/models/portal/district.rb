class Portal::District < ActiveRecord::Base
  set_table_name :portal_districts
  
  acts_as_replicatable
  
  has_many :schools, :dependent => :destroy, :class_name => "Portal::School", :foreign_key => "district_id", :order => "name"
  belongs_to :nces_district, :class_name => "Portal::Nces06District", :foreign_key => "nces_district_id"
  
  named_scope :real,    { :conditions => 'nces_district_id is NOT NULL', :include => :schools, :order => "name" }  
  named_scope :virtual, { :conditions => 'nces_district_id is NULL', :include => :schools, :order => "name" }  
  
  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def display_name
      "District"
    end
    
    ##
    ## Given an NCES local district id that matches the STID field in an NCES district
    ## find and return the first district that is associated with the NCES district or nil.
    ##
    ## example: 
    ##
    ##   Portal::District.find_by_state_and_nces_local_id('RI', 39).name
    ##   => "Woonsocket"
    ##
    def find_by_state_and_nces_local_id(state, local_id)
      nces_district = Portal::Nces06District.find(:first, :conditions => {:STID => local_id, :LSTATE => state}, 
        :select => "id, LEAID, STID, NAME, LSTATE")
      if nces_district 
        find(:first, :conditions=> {:nces_district_id => nces_district.id})
      end
    end

    ##
    ## Given a district name that matches the NAME field in an NCES district find
    ## and return the first district that is associated with the NCES district or nil.
    ##
    ## example: 
    ##
    ##   Portal::District.find_by_state_and_district_name('RI', "Woonsocket").nces_local_id
    ##   => "39"
    ##
    def find_by_state_and_district_name(state, district_name)
      nces_district = Portal::Nces06District.find(:first, :conditions => {:NAME => district_name.upcase, :LSTATE => state}, 
        :select => "id, LEAID, STID, NAME, LSTATE")
      if nces_district
        find(:first, :conditions=> {:nces_district_id => nces_district.id})
      end
    end

    ##
    ## given a NCES district, either find or create a portal_distrcit for it.
    ##
    def find_or_create_by_nces_district(nces_district)
      found_instance = find(:first, :conditions=> {:nces_district_id => nces_district.id})
      unless found_instance
        attributes = {
          :name => nces_district.NAME,
          :description => "imported from nces data",
          :nces_district_id => nces_district.id
        }
        found_instance = self.create(attributes)
        found_instance.save!
      end
      found_instance
    end
    
  end
  
  def virtual?
    nces_district_id.nil?
  end
  
  def real?
    ! virtual?
  end
  
  # if the district is a 'real' district return the NCES local district id
  def nces_local_id
    real? ? nces_district.STID : nil
  end
end
