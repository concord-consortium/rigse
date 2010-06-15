require 'net/http'
require 'uri'

class Sparks::QucsatorController < ApplicationController

  def solve
    puts "#{'*' * 72}\n" * 4
    puts "params=#{params.inspect}"
    res = Net::HTTP.post_form(URI.parse('http://localhost/qucs/index.php'),
      { :qucs => params['qucs'] })
    puts "res=#{res.body.inspect}"
    render :inline => res.body
  end
  
end
