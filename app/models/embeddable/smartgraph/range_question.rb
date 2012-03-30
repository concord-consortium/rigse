class Embeddable::Smartgraph::RangeQuestion < ActiveRecord::Base
  self.table_name = "embeddable_smartgraph_range_questions"


  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  belongs_to :data_collector, :class_name => 'Embeddable::DataCollector'
  
  @@answer_styles = %w{ number label }

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def answer_styles
      @@answer_styles
    end
  end
  
  validates_numericality_of :correct_range_min
  validates_numericality_of :correct_range_max
  validates_numericality_of :highlight_range_min
  validates_numericality_of :highlight_range_max
  
  # Have to do on => update so that a default one can be created when editing at the page level
  # Actually, we can't do this at all, or the user won't get saved to the question, causing editing problems.
  # validates_presence_of :data_collector, :on => :update

  default_value_for :name, "Smartgraph Range Question"
  default_value_for :description, "description ..."
  
  default_value_for :correct_range_min, 0
  default_value_for :correct_range_max, 10
  default_value_for :correct_range_axis, "x"
  default_value_for :highlight_range_min, 0
  default_value_for :highlight_range_max, 10
  default_value_for :highlight_range_axis, "x"
  default_value_for :prompt, "Where on the graph ... ?"
  default_value_for :answer_style, "number"
  
  default_value_for :no_answer_response_text, "Please enter an answer..."
  default_value_for :no_answer_highlight, false
  default_value_for :correct_response_text, "Good job! That's correct."
  default_value_for :correct_highlight, false
  default_value_for :first_wrong_answer_response_text, "I'm sorry, that's not correct. Please try again!"
  default_value_for :first_wrong_highlight, false
  default_value_for :second_wrong_answer_response_text, "I'm sorry, that's not correct. Please try again!"
  default_value_for :second_wrong_highlight, false
  default_value_for :multiple_wrong_answers_response_text, "I'm sorry, that's not correct. Please try again!"
  default_value_for :multiple_wrong_highlight, false


  def script_text
    script = <<EOF
    # Original template file: scripts/smart_graph_number_script_template.rb

    # Setting the DEBUG constant to true will generate additional 
    # debugging information in the Java console.
    # DEBUG=true

    eval Java::JavaLang::String.new($otrunk_ruby_script_tools.src).to_s
    eval Java::JavaLang::String.new($smart_graph_range_response.src).to_s

    # Edit the values in the response_key Hash below to customize the
    # Smart Graph Query responses

    response_key = {
      # Optional: You can specify the prompt in the script, this will override the 
      # value entered in the question object.
      # :prompt => "Please answer this question: how much?",

      # Specify the response_type as :number when the
      # learner responds to the question by entering a number.
      :response_type => :#{self.answer_style},

      # The value for a :range key can be any of the following:
      #
      #   a Ruby Range object
      #
      #     <start_of_range>..<end_of_range>
      #
      #   The values for start_of_range and end_of_range can be
      #   Fixnums (Integers) or Floats. Specify a floating point 
      #   by including a decimal point and at least one one digit
      #   to the right of the decimal point.
      #
      #   Example: 30.0..31.5
      #
      #   a Ruby number (Fixnum or Float)
      #
      #   Examples: 26, 30.0
      #
      #   *** If you specify the correct_range with a number instead of a range object
      #   *** you must also specify a highlight_range using a range object. 
      #
      # valid axis values are :x and :y
      #
      :correct_range => { :range => #{self.correct_range_min.to_f}..#{self.correct_range_max.to_f}, :axis => :#{self.correct_range_axis} },

      # Optional: specify the highlight_range if it is different than the correct_range
      :highlight_range => { :range => #{self.highlight_range_min.to_f}..#{self.highlight_range_max.to_f}, :axis => :#{self.highlight_range_axis} },
      :no_answer_entered => 
        { :text => "#{self.no_answer_response_text.gsub('"', '\"')}", :highlight_region => #{self.no_answer_highlight.to_s}  },
      :correct => 
        { :text => "#{self.correct_response_text.gsub('"', '\"')}", :highlight_region => #{self.correct_highlight.to_s}  },
      :first_wrong_answer => 
        { :text => "#{self.first_wrong_answer_response_text.gsub('"', '\"')}", :highlight_region => #{self.first_wrong_highlight.to_s}  },
      :second_wrong_answer => 
        { :text => "#{self.second_wrong_answer_response_text.gsub('"', '\"')}", :highlight_region => #{self.second_wrong_highlight.to_s}  },
      :multiple_wrong_answers => 
        { :text => "#{self.multiple_wrong_answers_response_text.gsub('"', '\"')}", :highlight_region => #{self.multiple_wrong_highlight.to_s}  }
    }

    # Create a new SmartGraphRangeResponse object with your response_key and the 
    # global variables created by the Smart Graph Number type Question input.
    @smart_graph_range_response = SmartGraphRangeResponse.new(response_key, $graph, $smart, $correct, $times_incorrect, $question, $text_field)

    # When the "Check Answer" button is clicked the clicked method
    # of the @smart_graph_range_response object will be called.
    def self.clicked
      @smart_graph_range_response.clicked
    end
EOF
  end

end
