class Admin::RolesController < ApplicationController
  layout "admin"
  active_scaffold :role
end