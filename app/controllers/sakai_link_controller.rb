class SakaiLinkController < ApplicationController
  require 'soap/wsdlDriver'
  DRIVERS = {}

  def index
    if (DRIVERS.size == 0)
      # we can't initialize these at the class level because if one of the wsdl
      # verifiers points to the currently starting app, we'll deadlock (aka points to the fake_verify action below)
      init_soap_drivers
    end
    @params = params  # FIXME for the fail view for now
    logout_keeping_session!
    @user = params[:user]
    @internaluser = params[:internaluser]
    @site = params[:site]
    @placement = params[:placement]
    @role = params[:role]
    @session = params[:session]
    @serverurl = params[:serverurl]
    @time = params[:time]
    @sign = params[:sign]
    @query_string = request.query_string
    
    @serverurl << '/' if (@serverurl && @serverurl !~ /\/$/)
    
    @fail_reason = ""
    
    driver = DRIVERS[@serverurl]
    success = false
    # If we're testing, pretend like we have verified with the sakai server
    if ENV['RAILS_ENV'] == 'test' || driver
      if ENV['RAILS_ENV'] == 'test'
        @response = "true"
      else
        @response = driver.testsign(@query_string)
      end
      # logger.warn "Testsign response: '#{@response}'"
      # the linktool doc says testsign should return "success", but in reality it returns "true"
      if @response == "true"
        # FIXME We may or may not be mapping the sakai internal unique id to the login field...
        begin
          external_domain = ExternalUserDomain.select_external_domain_by_server_url(@serverurl)
          user = ExternalUserDomain.find_user_by_external_login(@internaluser)
          logger.error("#{external_domain} == #{user}")
        rescue ExternalUserDomain::ExternalUserDomainError
          logger.error("couldnt find external doain and user for #{@serverurl} == #{@internaluser}")          
          external_domain = user = nil
        end
        # logger.warn("Login (#{@internaluser}) found user: #{user}")
        if user
          self.current_user = user
          session[:original_user_id] = current_user.id
          successful_login
          success = true
        else
          @fail_reason = "You don't appear to have a valid Investigations account. If your account in Sakai was created within the last 24 hours, wait 24 hours and try again. Otherwise, please contact your site administrator."
        end
      else
        @fail_reason = "Sakai could not validate your session. Please make sure your Sakai session is still active."
      end
    else
      @fail_reason = "Your request came from an unknown sakai server. Please contact your site administrator."
    end
    if ! success
      self.current_user = User.anonymous
    end
  end
  
  def fake_verification
    ## Not really used anymore... this was going to be use by the cucumber tests, but I haven't figured out how that would work
    # if (ENV['RAILS_ENV'] != 'test' && ENV['RAILS_ENV'] != 'development')
    #   render :xml => "<not_allowed/>", :layout => false
    # else
    #   response['Content-type'] = 'application/xml'
    #   # this is a fake verification action to be used when testing the sakai linktool integration\
    #   if request.method == :post
    #     # logger.warn "Post: #{request.raw_post}"
    #     # return the success message
    #     render 'wsdl_verify', :layout => false
    #   else
    #     render 'wsdl_def', :layout => false
    #   end
    # end
  end
  
  private
  
  def init_soap_drivers
    return if ! APP_CONFIG[:valid_sakai_instances]
    APP_CONFIG[:valid_sakai_instances].each do |url|
      begin
        url << '/' if (url !~ /\/$/)
        wsdl = url.clone
        wsdl << 'sakai-axis/SakaiSigning.jws?wsdl'
        driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
         # logger.warn("wsdl for #{url}: #{driver.methods.join(',')}")
        DRIVERS[url] = driver
        logger.info("INFO: Registered sakai host: #{url}")
      rescue Errno::ECONNREFUSED, HTTPClient::BadResponseError, SocketError
        DRIVERS.delete(url)
        logger.warn("WARN: Could not connect to sakai host: #{url}")
      rescue OpenSSL::SSL::SSLError
        DRIVERS.delete(url)
        logger.warn("WARN: Sakai hostname did not match with the server certificate: #{url}")
      rescue WSDL::XMLSchema::Parser::UnknownElementError
        DRIVERS.delete(url)
        logger.warn("WARN: Could not register sakai Host: #{url}: WSDL Parse error")
      end
    end
  end
  
  def successful_login
    new_cookie_flag = false
    handle_remember_cookie! new_cookie_flag
    redirect_to(root_path)
    flash[:notice] = "Logged in successfully"
  end
end
