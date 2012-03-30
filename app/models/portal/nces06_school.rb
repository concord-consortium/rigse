class Portal::Nces06School < ActiveRecord::Base
  self.table_name = :portal_nces06_schools
  
  belongs_to :nces_district, :class_name => "Portal::Nces06District", :foreign_key => "nces_district_id"
  
  has_one :school, :class_name => "Portal::School", :foreign_key => "nces_school_id"
  
  self.extend SearchableModel

  @@searchable_attributes = %w{NCESSCH LEAID SCHNO SCHNAM PHONE MSTREE MCITY MSTATE MZIP}

  include ActionView::Helpers::NumberHelper
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end
  
  def portal_school_created?
    self.school ? true : false
  end

  def capitalized_name
    capitalized_words(self.SCHNAM.split)
  end

  def phone
    number_to_phone(self.PHONE.to_i)
  end
  
  def address
    capitalized_words(self.MSTREE.split) + ', ' + capitalized_words(self.MCITY.split) + ", #{self.MSTATE} #{self.MZIP}" 
  end

  def geographic_location
    "latitude: #{self.LATCOD}, longitude: #{self.LONCOD}"
  end

  def student_teacher_ratio
    number_with_precision(self.MEMBER.to_f / self.FTE.to_f, :precision => 1)
  end

  def percent_free_reduced_lunch
    number_to_percentage(self.TOTFRL.to_f / self.MEMBER.to_f * 100, :precision => 1)
  end
  
  def description
    content = <<-HEREDOC
<h3>#{self.capitalized_name}</h3>

<p>In 2006 #{self.capitalized_name} with grades from #{self.GSLO.to_i} to #{self.GSHI.to_i} was located at #{address}, 
#{self.geographic_location} with telephone: #{self.phone}.</p>

<p>#{self.capitalized_name} had #{self.FTE} FTE-equivalent teachers and #{self.MEMBER} students of which #{self.percent_free_reduced_lunch} 
were eligible for either free or reduced-price lunch. The effective student-teacher ratio was #{self.student_teacher_ratio} to 1.
</p>

<p>Students were distributed among the following groups: American Indian/Alaska Native: #{self.AM}, 
Asian/Pacific Islander: #{self.ASIAN}, Hispanic: #{self.HISP}, Black: #{self.BLACK}, and White: #{self.WHITE}.</p>
    HEREDOC
    content.delete("\n")
  end

  def summary
    { 
      'name' => self.capitalized_name,
      'school_created' => self.portal_school_created?,
      'description' => self.description 
    }
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
    # active_grades.min >= grades.min && 
    # active_grades.min <= grades.max
    (active_grades & grades).size > 0
  end
  
  private
  
  def capitalized_words(words, delimiter=' ')
    words.collect {|w| w.capitalize}.join(delimiter).gsub(/\b\w{1,2}\b/) { $&.upcase }
  end
  
  
end
