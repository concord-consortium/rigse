# this is a callback class for generating symbolic output of diffs generated using Diff::LCS.

module Diff
  module Comparison
    class SymbolDiff
      attr_accessor :output

      def initialize(output = "")
        @output = output || ""
      end

      # This will be called with both lines are the same
      def match(event)
        @output << "="
      end

      # This will be called when there is a line in A that isn't in B
      def discard_a(event)
        @output << "+"
      end

      # This will be called when there is a line in B that isn't in A
      def discard_b(event)
        @output << "-"
      end

      # Change will only be triggered when using traverse_balanced. Otherwise, a change will
      # be represented by a discard_a followed by a discard_b.
      def change(event)
        @output << "*"
      end
    end
  end
end
