require 'cgi'

module Diff
  module Comparison
    class Comparer

      def initialize(left, right)
        @left = flatten(left)
        @right = flatten(right)
      end

      def differences(opts = {})
        process(opts)
        return unflatten(@differences)
      end

      def flat_differences(opts = {})
        process(opts)
        return @differences
      end

      def score(rubric, opts = {})
        rubric.reset
        flat_differences(opts).each do |path,result|
          rubric.applyRule({:path => path, :difference => result[:difference], :severity => result[:severity]})
        end
        return rubric.currentScore
      end

      # returns a value from 0 to 100 inclusive (essentially a percentage)
      # 0 means the values are the same, 100 means the values are entirely different
      def severity(left, right)
        return 0 if left == right
        return 100 if left.nil? || right.nil?
        return 100 if left.class != right.class
        if left.is_a?(String)
          # compare the strings
          # symbol diff returns a string of +-=* which represent whether the "word" was added, deleted, the same, or changed.
          sd = SymbolDiff.new

          a = CGI.escapeHTML(left).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
          a.delete("")
          b = CGI.escapeHTML(right).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
          b.delete("")

          Diff::LCS.traverse_balanced(a, b, sd)

          # return the percent of words that are different
          same = sd.output.count("=")
          return 100-((same.to_f/sd.output.size)*100).to_i
        else
          return 100 # the objects are different
        end
      end

      def html(left, right, output_both = false)
        hd = HtmlDiff.new
        hd.right_output = nil unless output_both

        a = [left]
        b = [right]

        if (left.is_a?(String) && right.is_a?(String)) ||
           (left.is_a?(String) && right.nil?) ||
           (right.is_a?(String) && left.nil?)
          # compare the strings
          # symbol diff returns a string of +-=* which represent whether the "word" was added, deleted, the same, or changed.

          a = CGI.escapeHTML(left || "").gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
          a.delete("")
          b = CGI.escapeHTML(right || "").gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
          b.delete("")
        end

        Diff::LCS.traverse_balanced(a, b, hd)

        # return the left and right html
        return [hd.left_output, hd.right_output]
      end

      private

      def process(opts = {})
        return if @processed

        only_left = @left.keys - @right.keys
        only_right = @right.keys - @left.keys
        both = @left.keys & @right.keys

        @differences = {}
        only_left.each do |k|
          @differences[k] = {:difference => :added, :severity => severity(@left[k], nil)}
          @differences[k].merge! _generateHtml(@left[k], nil, opts)
        end
        only_right.each do |k|
          @differences[k] = {:difference => :deleted, :severity => severity(nil, @right[k])}
          @differences[k].merge! _generateHtml(nil, @right[k], opts)
        end
        both.each do |k|
          s = severity(@left[k], @right[k])
          unless s == 0
            @differences[k] = {:difference => :changed, :severity => s}
            @differences[k].merge! _generateHtml(@left[k], @right[k], opts)
          end
        end

        @processed = true
      end

      def _generateHtml(left, right, opts)
        ret = {}
        ignore = nil

        if opts[:html_left] && opts[:html_right]
          ret[:html_left], ret[:html_right] = html(left, right, true)
        elsif opts[:html_left]
          ret[:html_left], ignore = html(left, right, false)
        else
          ret[:html_right], ignore = html(right, left, false)
        end

        return ret
      end

      def flatten(h, f=[], g={})
        return g.update({ f=>h }) unless h.is_a? Hash
        h.each { |k,r| flatten(r,f+[k],g) }
        g
      end

      def unflatten(h)
        out = {}
        h.each do |k,v|
          parent = out
          k.each do |kp|
            if k.last == kp
              parent[kp] = v
            else
              parent[kp] ||= {}
              parent = parent[kp]
            end
          end
          parent = v
        end
        out
      end
    end
  end
end
