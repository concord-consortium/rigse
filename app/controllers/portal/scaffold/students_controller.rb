class Portal::Scaffold::StudentsController < Portal::ApplicationController
  active_scaffold "Portal::Student" do |config|
    # this was causing problems because active scaffold is looking for a student_id on the Clazz
    config.columns.exclude :clazzes
  end
end