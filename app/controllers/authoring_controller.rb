class AuthoringController < ApplicationController
  # PUNDIT_CHECK_FILTERS
  after_filter :store_location, :only => [:index, :new, :show, :edit]
end
