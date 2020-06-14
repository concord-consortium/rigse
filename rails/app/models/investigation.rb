# encoding: UTF-8
class Investigation < ActiveRecord::Base
  include Cohorts
  include ResponseTypes
  include Archiveable

  belongs_to :user
  has_many :activities, :order => :position, :dependent => :destroy do
    def student_only
      where('teacher_only' => false)
    end
  end
  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :materials_collection_items, :dependent => :destroy, :as => :material
  has_many :materials_collections, :through => :materials_collection_items

  has_many :external_activities, :as => :template

  # BASE_EMBEDDABLES is defined in config/initializers/embeddables.rb
  # TODO We don't want Embeddable::Iframe showing up in any menus, so inject it here. It's used by LARA.
  (BASE_EMBEDDABLES + ["Embeddable::Iframe"]).each do |klass|
    eval %!has_many :#{klass[/::(\w+)$/, 1].underscore.pluralize}, :class_name => '#{klass}',
      :finder_sql => proc { "SELECT #{klass.constantize.table_name}.* FROM #{klass.constantize.table_name}
      INNER JOIN page_elements ON #{klass.constantize.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = '#{klass}'
      INNER JOIN pages ON page_elements.page_id = pages.id
      INNER JOIN sections ON pages.section_id = sections.id
      INNER JOIN activities ON sections.activity_id = activities.id
      WHERE activities.investigation_id = \#\{id\}" }!
  end

  has_many :page_elements,
    :finder_sql => proc { "SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id
    INNER JOIN sections ON pages.section_id = sections.id
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}" }

  has_many :sections,
    :finder_sql => proc { "SELECT sections.* FROM sections
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}" }

  has_many :student_sections, :class_name => Section.to_s,
    :finder_sql => proc { "SELECT sections.* FROM sections
    INNER JOIN activities ON sections.activity_id = activities.id AND activities.teacher_only = 0
    WHERE activities.investigation_id = #{id} AND sections.teacher_only = 0" }

  has_many :pages,
    :finder_sql => proc { "SELECT pages.* FROM pages
    INNER JOIN sections ON pages.section_id = sections.id
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}" }

  has_many :student_pages, :class_name => Page.to_s,
    :finder_sql => proc { "SELECT pages.* FROM pages
    INNER JOIN sections ON pages.section_id = sections.id AND sections.teacher_only = 0
    INNER JOIN activities ON sections.activity_id = activities.id AND activities.teacher_only = 0
    WHERE activities.investigation_id = #{id} AND pages.teacher_only = 0" }

  has_many :project_materials, :class_name => "Admin::ProjectMaterial", :as => :material, :dependent => :destroy
  has_many :projects, :class_name => "Admin::Project", :through => :project_materials

  has_many :favorites, as: :favoritable

  acts_as_replicatable

  include Publishable

  scope :assigned, -> { where('investigations.offerings_count > 0') }

  scope :like, lambda { |name|
    name = "%#{name}%"
    where("investigations.name LIKE ? OR investigations.description LIKE ?", name,name)
  }

  scope :activity_group, -> {
    group("#{self.table_name}.id")
  }

  scope :ordered_by, lambda { |order| order(order) }

  scope :is_template, ->(v) do
    joins(['LEFT OUTER JOIN activities ON investigations.id = activities.investigation_id',
           'LEFT OUTER JOIN external_activities',
           'ON (external_activities.template_id = activities.id AND external_activities.template_type = "Activity")',
           'OR (external_activities.template_id = investigations.id AND external_activities.template_type = "Investigation")'])
        .where("external_activities.id IS #{v ? 'NOT' : ''} NULL")
        .uniq
  end

  include Changeable
  include Noteable # convenience methods for notes...

  # Enables a teacher note to call the investigation method of an
  # authored_entity to find the relavent investigation
  def investigation
    self
  end

  after_save :add_author_role_to_use

  def add_author_role_to_use
    if self.user
      self.user.add_role('author')
    end
  end

  def left_nav_panel_width
     300
  end

  def parent
    nil
  end

  def children
    activities
  end

  include TreeNode

  def deep_xml
    self.to_xml(
      :include => {
        :teacher_notes=>{
          :except => [:id,:authored_entity_id, :authored_entity_type]
        },
        :activities => {
          :exlclude => [:id,:investigation_id],
          :include => {
            :sections => {
              :exlclude => [:id,:activity_id],
              :include => {
                :teacher_notes=>{
                  :except => [:id,:authored_entity_id, :authored_entity_type]
                },
                :pages => {
                  :exlclude => [:id,:section_id],
                  :include => {
                    :teacher_notes=>{
                      :except => [:id,:authored_entity_id, :authored_entity_type]
                    },
                    :page_elements => {
                      :except => [:id,:page_id],
                      :include => {
                        :embeddable => {
                          :except => [:id,:embeddable_type,:embeddable_id]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    )
  end



  def duplicate(new_owner)
    @return_investigation = deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at, :publication_status], :include => {:activities => {:sections => :pages}}
    @return_investigation.user = new_owner
    @return_investigation.name = "copy of #{self.name}"
    @return_investigation.deep_set_user(new_owner)
    @return_investigation.publication_status = "draft"
    @return_investigation.offerings_count = 0
    return @return_investigation
  end

  def print_listing
    listing = []
    self.activities.each do |a|
      a.sections.each do |s|
        listing << {"#{a.name} #{s.name}" => s}
      end
    end
    listing
  end

  # TODO: we have to make this container nuetral,
  # using parent / tree structure (children)
  def reportable_elements
    return @reportable_elements if @reportable_elements
    @reportable_elements = activities.collect{|a| a.reportable_elements }.flatten
    @reportable_elements.each{|elem| elem[:investigation] = self}
    return @reportable_elements
  end

  # return a list of broken parts.
  def broken_parts
    page_elements.select { |pe| pe.embeddable.nil? }
  end

  # is there something wrong with this investigation?
  def broken?
    self.broken_parts.size > 0
  end

  # is it 'safe' to modify this investigation?
  # TODO: a more thorough check.
  def can_be_modified?
    self.offerings.each do |o|
      return false if o.can_be_deleted? == false
    end
    return true
  end

  # Is it 'safe' to delete this investigation?
  def can_be_deleted?
    return can_be_modified?
  end

  # Investigation#broken
  # return a collection broken investigations
  def self.broken
    self.all.select { |i| i.broken? }
  end

  # Investigation#broken_report
  # print a list of broken investigations
  def self.broken_report
    self.broken.each do |i|
      puts "#{i.id} #{i.name}  #{i.broken_parts.size} #{i.offerings.map {|o| o.learners.size}}"
    end
  end

  # Investigation#delete_broken
  # delete broken investigations which can_be_deleted
  def self.delete_broken
    self.broken.each do |i|
      if i.can_be_deleted?
        i.destroy
      end
    end
  end

  def full_title
    full_title = self.name
    return full_title
  end

  def is_official
    true # FIXME: Not sure if true should be the hardwired value here
  end

  def is_template
    return true if activities.detect { |a| a.external_activities.compact.length > 0 }
    return external_activities.compact.length > 0
  end
end
