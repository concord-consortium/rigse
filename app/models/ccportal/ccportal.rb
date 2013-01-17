module Ccportal
  class Ccportal < ActiveRecord::Base

    def self.connection_possible?
      begin
        find(:first)
        true
      rescue SystemCallError, SocketError
        false
      end
    end

    #  self.table_name_prefix = ""

    if configurations.include? 'ccportal'
      begin
        establish_connection :ccportal
      rescue
        puts "unable to establish connection for ccportal (models/ccportal/ccportal)"
      end
    end
  end
end