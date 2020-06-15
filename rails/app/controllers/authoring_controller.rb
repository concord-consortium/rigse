class AuthoringController < ApplicationController
  after_filter :store_location, :only => [:index, :new, :show, :edit]
end
