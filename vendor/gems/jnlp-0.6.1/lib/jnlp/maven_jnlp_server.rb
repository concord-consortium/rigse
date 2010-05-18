require 'sinatra/base'

module Jnlp #:nodoc:

  class MavenJnlpServer < Sinatra::Base
    set :sessions, true
    set :foo, 'bar'

    get '/' do
      'Hello world!'
    end
  end
end

require 'sinatra'

class MavenJnlpServer < Sinatra::Base
  ROOT = File.expand_path(File.dirname(__FILE__)) unless defined?(ROOT)
  
  set :static, true
  set :public, ROOT + '/public'
  set :views,  ROOT + '/views'
  
  get('/') { erb :index }
  post('/save') { erb :save }
  
  get('/*.html') { erb params[:splat].first.to_sym }
end

