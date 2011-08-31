# Copyright (c) 2005 Concord Consortium
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# requires gem uuidtools version 2.0.0 or newer

module Foo #:nodoc:
  module Acts #:nodoc:
    # Specify this act if you want to be able to replicate models from one instance of this web application to another.
    # But ... so far all this plugin does is create and save a uuid for model instances.
    module Replicatable

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_replicatable
          
          send :include, Foo::Acts::Replicatable::InstanceMethods
          
          class_eval do
            before_create  :generate_uuid
            before_save    :generate_uuid
          end         
        end
      end
    
      module InstanceMethods
        def generate_uuid
          # if we have a uuid, don't generate a new one
          if ! self.uuid
            self.uuid = UUIDTools::UUID.timestamp_create.to_s
          end
        end
      end    

    end
  end
end

ActiveRecord::Base.send :include, Foo::Acts::Replicatable