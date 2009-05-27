class Ccportal::Teacher < Ccportal::Member
  
  belongs_to :school, :foreign_key => :member_school, :class_name => 'Ccportal::School'
  has_many :courses, :foreign_key => :class_teacher, :class_name => 'Ccportal::Course'
  has_many :students,
    :class_name => 'Ccportal::Student',
    :finder_sql => 'SELECT DISTINCT portal_members.* FROM portal_members
    INNER JOIN portal_class_students ON portal_class_students.member_id = portal_members.member_id
    INNER JOIN portal_classes ON portal_classes.class_id = portal_class_students.class_id
    WHERE portal_classes.class_teacher = #{id}'

  def self.find(*args)
    with_scope(:find => { :conditions => "member_type != 'student'" } ) do
      super
    end
  end

  # # Filter all members by member_type
  # def self.find(*args)
  #   if args.first == :all || args.first == :first
  #     saw_conditions = false
  #     args.each do |a|
  #       if a.kind_of?(Hash) && a[:conditions]
  #         saw_conditions = true
  #         if a[:conditions].kind_of?(Hash)
  #           a[:conditions][:member_type] = ['teacher','admin','superuser']
  #         else
  #           a[:conditions] << " AND (member_type = 'teacher' OR member_type = 'admin' OR member_type = 'superuser')"
  #         end
  #       end
  #     end
  #     if ! saw_conditions
  #       a = {:conditions => {:member_type => ['teacher','admin','superuser']}}
  #       args.push a
  #     end
  #   end
  #   super
  # end
end
