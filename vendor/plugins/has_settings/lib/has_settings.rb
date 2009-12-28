module CC
  module HAS
    module Settings
  
      
      def to_hash(first,other)
          Hash[ *(0...first.size()).inject([]) { |arr, ix| arr.push(first[ix], other[ix]) } ]
      end
      
      
      def self.included(base)
        base.extend(ClassMethods)
      end
  
      module ClassMethods
        def has_settings
          has_many :settings, :as => :scope, :dependent => :destroy
          send :include, CC::HAS::Settings::InstanceMethods
        end
      end
      
      
      module InstanceMethods
        def settings_hash
          keys = settings.map {|s| s.name}
          values = settings.map {|s| s.value}
          return to_hash(keys,values)
        end
        
        def print_settings
          settings.each { |s| puts "#{s.name}: #{s.value}"}
        end
        
        def get_setting(name)
          setting = settings.detect { |s| s.name.to_s == name.to_s}
        end
        
        def get_value(name)
          setting = get_setting(name)
          if setting
            return setting.value
          end
          return nil
        end
        
        def put_setting(name,value)
          name = name.to_s
          setting = get_setting(name)
          if setting
            if setting.value != value
              setting.value=value
              setting.save
            end
          else
            setting =  Setting.create(:name=>name.to_s,:value=>value);
            self.settings << setting
          end
          setting
        end
        alias get get_value
        alias put put_setting
        
      end #instance Methods
    end # Module Settings
  end # Module HAS
end # Module CC
