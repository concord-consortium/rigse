class Itsi::Itsi < ActiveRecord::Base

  def self.connection_possible?
    begin
      find(:first)
      true
    rescue SystemCallError, SocketError
      false
    end
  end

#  self.table_name_prefix = ""
  begin
    establish_connection :itsi
  rescue 
    puts "unable to establish connection for itsi (models/itsi/itsi)"
  end
end
