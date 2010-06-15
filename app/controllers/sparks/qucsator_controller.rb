require 'net/http'
require 'uri'

class Sparks::QucsatorController < ApplicationController

  def solve
    puts "#{'*' * 72}\n" * 4
    puts "params=#{params.inspect}"
    puts "url=#{APP_CONFIG[:qucs_url]}"
    res = Net::HTTP.post_form(URI.parse(APP_CONFIG[:qucs_url]),
      { :qucs => params['qucs'] })
    puts "res=#{res.body.inspect}"
    render :inline => res.body
  end
  
end
