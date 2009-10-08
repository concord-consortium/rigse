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
  
  def capitalized_name
    self.SCHNAM.split.collect {|w| w.capitalize}.join(' ').gsub(/\b\w/) { $&.upcase }
  end
  
  # School level.  The following codes were calculated from the school's corresponding GSLO and GSHI values: 
  #   1 = Primary (low grade = PK through 03; high grade = PK through 08)
  #   2 = Middle (low grade = 04 through 07; high grade = 04 through 09)
  #   3 = High (low grade = 07 through 12; high grade = 12 only
  #   4 = Other (any other configuration not falling within the above three categories, including ungraded)
  #
  # School low and high grade offered. The following codes are used:
  #   UG = Ungraded
  #   PK = Prekindergarten
  #   KG = Kindergarten
  #   01..12 = 1st through 12th grade
  #   N = School had no students reported
  # 

  GRADE_NAME_MAP = [
    ['PK', 'PK'],
    ['KG', 'K'],
    ['01', '1'],
    ['02', '2'],
    ['03', '3'],
    ['04', '4'],
    ['05', '5'],
    ['06', '6'],
    ['07', '7'],
    ['08', '8'],
    ['09', '9'],
    ['10', '10'],
    ['11', '11'],
    ['12', '12']
  ]
  
  def active_grades
    @active_grades ||= begin
      level = self.LEVEL
      gslo = self.GSLO
      gshi = self.GSHI
      if level == "4" || gslo == 'N' || gslo == 'UG'
        []
      else
        low_index = GRADE_NAME_MAP.index(GRADE_NAME_MAP.assoc(gslo))
        high_index = GRADE_NAME_MAP.index(GRADE_NAME_MAP.assoc(gshi))
        range = Range.new(low_index, high_index)
        GRADE_NAME_MAP[range].collect {|i| i[1]}
      end
    end
  end
  
  def grade_match(grades)
    active_grades.min >= grades.min && 
    active_grades.min <= grades.max
  end
  
end
