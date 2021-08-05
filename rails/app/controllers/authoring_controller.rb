class AuthoringController < ApplicationController
  after_action :store_location, :only => [:index, :new, :show, :edit]
end
