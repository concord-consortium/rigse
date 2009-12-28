module Jnlp #:nodoc:
  VERSION = '0.0.5.3'
  #
  # Let's see if this patch:
  #
  #   http://rubyforge.org/tracker/index.php?func=detail&aid=24392&group_id=126&atid=577
  #
  # makes it into RubyGems -- it has been applied.
  # Will probably be part of 1.3.2.
  #
  # then I can start using this form again:
  #
  # module VERSION
  #   MAJOR = 0
  #   MINOR = 0
  #   TINY  = 4
  # 
  #   STRING = [MAJOR, MINOR, TINY].join('.')
  #   
  #   class << self
  #     def to_s
  #       STRING
  #     end
  #     
  #     def ==(arg)
  #       STRING == arg
  #     end
  #   end
  # end
end
