# This is controller that used to handle data coming from LARA. It doesn't do anything at this point, as answers are
# handled by Firetore and Athena. However, the API endpoint URLs are still used to identify students. That's why there
# are some empty actions here.
class Dataservice::ExternalActivityDataController < ApplicationController
  public

  def create
    head :ok
  end

  def create_by_protocol_version
    head :ok
  end
end
