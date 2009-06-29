class Ccportal::Student < Ccportal::Member
  has_many :class_students, :foreign_key => :member_id, :class_name => 'Ccportal::ClassStudent'
  has_many :courses, :through => :class_students, :foreign_key => :class_id, :class_name => 'Ccportal::Course'

  has_many :teachers,
    :class_name => 'Ccportal::Teacher',
    :finder_sql => 'SELECT DISTINCT portal_members.* FROM portal_members
    INNER JOIN portal_classes ON portal_classes.class_teacher = portal_members.member_id
    INNER JOIN portal_class_students ON portal_class_students.class_id = portal_classes.class_id    
    WHERE portal_class_students.member_id = #{id}'

  def self.find(*args)
    with_scope(:find => { :conditions => "member_type = 'student'" } ) do
      super
    end
  end

  # def teachers
  #   courses.collect{|c| c.teacher }.flatten.uniq   
  # end
  # 
  # # Filter all members by member_type
  # def self.find(*args)
  #   if args.first == :all || args.first == :first
  #     saw_conditions = false
  #     args.each do |a|
  #       if a.kind_of?(Hash) && a[:conditions]
  #         saw_conditions = true
  #         if a[:conditions].kind_of?(Hash)
  #           a[:conditions][:member_type] = 'student'
  #         else
  #           a[:conditions] << " AND member_type = 'student'"
  #         end
  #       end
  #     end
  #     if ! saw_conditions
  #       a = {:conditions => {:member_type => 'student'}}
  #       args.push a
  #     end
  #   end
  #   super
  # end
end
