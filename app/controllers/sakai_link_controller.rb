class SakaiLinkController < ApplicationController
  require 'soap/wsdlDriver'
  WSDL = 'http://moleman.concord.org/sakai-axis/SakaiSigning.jws?wsdl'
  DRIVER = SOAP::WSDLDriverFactory.new(WSDL).create_rpc_driver

  def index
    @site = params[:site]
    @username = params[:username]
    @params = params
    @query_string = request.query_string
    @response = DRIVER.testsign(@query_string)
    @params[:query_string] = @query_string
    @params[:response] = @response
    # render views/sakai_link.html.haml
  end
end
