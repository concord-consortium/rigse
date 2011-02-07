class HomeController < ApplicationController
  def readme
    @document = FormattedDoc.new('README.textile')
    render :action => "formatted_doc", :layout => "technical_doc"
  end

  def doc
    if document_path = params[:document]
      @document = FormattedDoc.new(File.join('doc', File.basename(document_path)))
      render :action => "formatted_doc", :layout => "technical_doc"
    end
  end

  def pick_signup
  end

  def about
  end

  # @template is a reference to the View template object
  def name_for_clipboard_data
    render :text=> @template.clipboard_object_name(params)
  end

  def missing_installer
    @os = params['os']
  end
end
