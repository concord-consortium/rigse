class Portal::District < ActiveRecord::Base
  self.table_name = :portal_districts

  acts_as_replicatable

  has_many :schools, -> { order :name },
    dependent: :destroy,
    class_name: 'Portal::School',
    foreign_key: 'district_id'

  belongs_to :nces_district, :class_name => "Portal::Nces06District", :foreign_key => "nces_district_id"

  scope :real,    -> { where('nces_district_id is NOT NULL').includes(:schools).order("name") }
  scope :virtual, -> { where('nces_district_id is NULL').includes(:schools).order("name") }

  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{uuid name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
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
      nces_district = Portal::Nces06District
                          .where(:STID => local_id, :LSTATE => state)
                          .select("id, LEAID, STID, NAME, LSTATE")
                          .first
      if nces_district
        where(:nces_district_id => nces_district.id).first
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
      nces_district = Portal::Nces06District.where(:NAME => district_name.upcase, :LSTATE => state)
        .select("id, LEAID, STID, NAME, LSTATE").first
      if nces_district
        where(:nces_district_id => nces_district.id).first
      end
    end

    ##
    ## given a NCES district, either find or create a portal_distrcit for it.
    ##
    def find_or_create_using_nces_district(nces_district)
      found_instance = where(:nces_district_id => nces_district.id).first
      unless found_instance
        attributes = {
          :name             => nces_district.NAME,
          :description      => "imported from nces data",
          :nces_district_id => nces_district.id,
          :state            => nces_district.LSTATE,
          :leaid            => nces_district.LEAID,
          :zipcode          => nces_district.LZIP
        }
        found_instance = self.create(attributes)
        found_instance.save!
      end
      found_instance
    end

    def default
      Portal::District.where(name: 'default').first_or_create
    end

    def find_by_similar_or_new(attrs,username='automatic process')
      found = Portal::District.where(attrs).first
      unless found
        attrs[:description] ||= "created by #{username}"
        found = Portal::District.new(attrs)
      end
      found
    end

    def find_by_similar_name_or_new(name,username='automatic process')
      sql = "SELECT id, name FROM portal_districts"
      all_names = Portal::District.find_by_sql(sql)
      found = all_names.detect { |s| s.name.upcase.gsub(/[^A-Z]/,'') == name.upcase.gsub(/[^A-Z]/,'') }
      unless found
        found = Portal::District.new(:name => name, :description => "#{name} created by #{username}")
      end
      found
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
