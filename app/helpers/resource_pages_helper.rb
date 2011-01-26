module ResourcePagesHelper
  def resource_page_printable_index_params
    {   :name             => @name, 
        :portal_clazz_id  => @portal_clazz_id,
        :include_drafts   => @include_drafts, 
        :grade_span       => @grade_span,
        :domain_id        => @domain_id,
        :sort_order       => @sort_order,
        :mine_only        => params[:mine_only]
    }
  end

end
