module Diff
  module Comparison
    class RubricRule
      # provide a default which increments by 1
      def self.defaultRule
        return RubricRule.new({ :__default__ => lambda {|currentScore| return currentScore + 1 } })
      end

      # matchers is a hash, where the keys are a "difference", and the values are lambda functions
      # with two arguments (current score and the severity of the difference).
      #
      # Valid "differences": :added, :changed, :deleted
      # The severity will be a value between 0 and 100, inclusive (a percentage, basically)
      def initialize(matchers)
        @matchers = matchers
      end

      # the hash passed in should have the following key/value pairs:
      #   currentScore: number
      #   difference: one of :added, :changed, :deleted
      #   severity: (optional) number from 0 to 100, inclusive
      def applyRule(params)
        raise "currentScore required!" unless params[:currentScore]
        raise "difference required!" unless params[:difference]
        raise "Invalid difference: #{params[:difference]}!" unless [:added, :changed, :deleted].include?(params[:difference])

        defaults = { :severity => 100 }
        opts = defaults.merge(params)

        if m = (@matchers[opts[:difference]] || @matchers[:__default__])
          numArgsExpected = m.arity.abs
          args = [opts[:currentScore], opts[:severity]].slice(0,numArgsExpected)
          args.fill(nil, args.length...numArgsExpected) if numArgsExpected > args.length
          return m.call(*args)
        end
        return opts[:currentScore]
      end
    end
  end
end
