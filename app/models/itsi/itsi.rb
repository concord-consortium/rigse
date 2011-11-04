class Itsi::Itsi < ActiveRecord::Base

  def self.connection_possible?
    begin
      find(:first)
      true
    rescue SystemCallError, SocketError
      false
    end
  end


  begin
    establish_connection :itsi
  rescue
    "not able to establish itsi db connnection"
  end
end
