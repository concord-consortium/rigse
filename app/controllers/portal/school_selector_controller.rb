class Portal::SchoolSelectorController < ApplicationController
  public

  def update
    @school_selector = Portal::SchoolSelector.new(params)
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @school_selector
    # TODO: do we care about types?
    render  :partial => 'shared/school_selector', 
            :layout => false,
            :locals => { :school_selector => @school_selector }
  end

end
