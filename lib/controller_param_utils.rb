module ControllerParamUtils
  # restrict access to sensitive routes to manager 
  def self.included(clazz)
    clazz.class_eval do
      protected  
      def boolean_param(symbol)
        boolvalue = params[symbol]
        # ugly. but we need to undo our madness of 
        # explicitly seeting boolean params to 'false' (strings)
        if boolvalue.class == String
          boolvalue = false if (boolvalue =~ /false/i)
          boolvalue = true if (boolvalue  =~ /true/i)
        end
        return boolvalue
      end
    end
  end
end
