# this is a callback class for generating html output of diffs generated using Diff::LCS.

class Diff::Comparison::HtmlDiff
  # Based on Diff::LCS::HTMLDiff::Callbacks, but modified to produce html for both left and right
  attr_accessor :left_output
  attr_accessor :right_output
  attr_accessor :match_class
  attr_accessor :only_a_class
  attr_accessor :only_b_class
  attr_accessor :change_class

  # Split changes among 2 streams so that sources can be easily compared
  def initialize(left_output = "", right_output = "", options = {})
    @left_output = left_output
    @right_output = right_output

    @match_class  = options[:match_class]  || "match"
    @only_a_class = options[:only_a_class] || "only_a"
    @only_b_class = options[:only_b_class] || "only_b"
    @change_class = options[:change_class] || "change"
  end

  # This will be called with both lines are the same
  def match(event)
    @left_output  << htmlize("#{event.old_element}", :match_class)
    @right_output << htmlize("#{event.old_element}", :match_class) if @right_output
  end

  # This will be called when there is a line in A that isn't in B
  def discard_a(event)
    @left_output << htmlize("#{event.old_element}", :only_a_class)
  end

  # This will be called when there is a line in B that isn't in A
  def discard_b(event)
    if @right_output
      @right_output << htmlize("#{event.new_element}", :only_b_class)
    else
      @left_output  << htmlize("#{event.new_element}", :only_b_class)
    end
  end

  # This will be called when lines in both A and B differ from each other.
  # Sometimes this won't be called at all, and instead you'll get a discard_a
  # followed by a discard_b.
  def change(event)
    if @right_output
      @left_output  << htmlize("#{event.old_element}", :change_class)
      @right_output << htmlize("#{event.new_element}", :change_class)
    else
      @left_output  << htmlize("#{event.old_element}", :change_class)
    end
  end

  private

  def htmlize(element, css_class)
    element = "&nbsp;" if element.empty?
    %Q|<span class="#{__send__(css_class)}">#{element}</span> |
  end
end
