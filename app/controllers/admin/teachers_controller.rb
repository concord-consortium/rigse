class Admin::TeachersController < ApplicationController
  before_filter :admin_or_manager

  protected

  def admin_or_manager
    return true if current_visitor.has_role?('admin')
    return true if current_visitor.has_role?('manager')
    flash[:notice] = "Please log in as an administrator or manager"
  end

  public
  class TeacherSearchForm < Struct.new(:name, :cohort_name)
    def initialize(params)
      self.name = params[:name] || "noah"
      self.cohort_name = params[:cohort_name]
    end
    def search
      value  = "%#{self.name}%"
      where  = "users.login like ? or users.first_name like ? or users.last_name like ?"
      Portal::Teacher.joins(:user).where(where, value, value, value)
    end
  end

  class TeacherView < Struct.new(:display_name, :class_names, :students)
    def intialize(teacher)

    end
  end


  def index
    form = TeacherSearchForm.new(params)
    @teachers = form.search
  end

  def show
  end

  def edit
  end

  def update
  end

end