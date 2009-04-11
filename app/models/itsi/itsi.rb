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
  establish_connection :itsi

end
