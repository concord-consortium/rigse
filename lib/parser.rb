require 'open-uri'
####################################################################
# Parser --
####################################################################

class Parser
 
 def initialize
   @last_k_statmenent = nil
   @assessment_targets = {}
 end
 
 
 def clean_text(text) 
   if(text)
     text.gsub!("\n"," ")
     text.gsub!("\t"," ")
     text.gsub!("\?","")
     text.squeeze!(" ")
     text.strip!
   end
 end
 
 def make_domains
   domains = [
     ["Life Science", "LS"],
     ["Earth and Space Science","ESS"],
     ["Physical Science", "PS"]]

   domains.collect { |d|
     # d = Domain.find_or_create(:key => d[1], :name => d[0])
     d = Domain.find_or_create_by_key(:key => d[1], :name => d[0])
     d.save
   }
 end

 def make_themes
   unifying_themes = [
     ["INQ", "Scientific Inquiry"],
     ["NOS", "Nature of Science"],
     ["SAE", "Systems & Energy"],
     ["MOS", "Models & Scale"],
     ["POC", "Patterns of Change"],
     ["FOF", "Form & Function"]
   ]
   unifying_themes.collect { |t|
     # theme = UnifyingTheme.find_or_create(:key => t[0], :name => t[1])
     theme = UnifyingTheme.find_or_create_by_key(:key => t[0], :name => t[1])
     theme.save
   }
 end
 
 
 # Parse a xhtml file looking for 
 # table_heading_regex to seperate 
 #
 def parse(path)
   
   #
   # first import the domains if they do not exist
   #
   make_domains
   make_themes
   
   match_expression = /Table(\d+)_([A-Z][0-9])/i
   doc = Hpricot(open(path))
   table_number = 0
   
   (doc/:table).each do | table |
     table_number = table_number + 1
     row_number = 0
     knowledge_statement=nil
     assessment_targets = []
     (table/:tr).each do | row |
       row_number = row_number + 1
       column = 0

       
       (row/:td).each do | data |
         column = column + 1 
         columntext = data.inner_text
         clean_text(columntext)
         case row_number
         when 1
           # we should be able to pull out KnowledgeStatement
            knowledge_statement = parse_knowledge_statement columntext
         when 2,5
           # we should be able to pull out an AssessmentTarget
           if (knowledge_statement)
             assessment_targets[column] = parse_assesment_target columntext
             if (assessment_targets[column])
               assessment_targets[column].knowledge_statement = knowledge_statement
               assessment_targets[column].save
             end
           end
         when 4,7
           # we should be able to pull out: GradeSpanExpectation, ExpectationStems, and Expectations
           if (knowledge_statement)
             assessment_target_index = (column / 2.0).ceil
             # puts "found assesment_targets for assessment_target_index #{}"
             # puts "====\n#{assessment_targets.inspect}\n"
             grade_span_expectation = parse_grade_span_expectation columntext
             if (grade_span_expectation)
               grade_span_expectation.assessment_target = assessment_targets[assessment_target_index]
               grade_span_expectation.save
             end
           end
         end # end case
         
       end # end for data
     end # end for row
   end  # end for table
 end # end for method declaration
 
 #
 #
 #
 def parse_knowledge_statement(text)
   knowledge_statement = nil
   regex = /(\w+?)\s*([0-9])[ |–|-]{1,6}(.*)/mi
   matches = text.match(regex)
   if (matches)
     (domain_key,number,statement) = matches.captures
     domain = Domain.find_by_key(domain_key)
     if (domain)
       knowledge_statement = KnowledgeStatement.find(
         :first, 
         :conditions => { :domain_id => domain.id, :number => number }
       )
       unless(knowledge_statement)
         knowledge_statement = KnowledgeStatement.new(:domain => domain, :number => number)
       end
       knowledge_statement.statement = statement
       knowledge_statement.save
     end
     else
       puts "***** unable to parse knowledge statement"
   end
   return knowledge_statement
 end # end for method dec
     
     
 #
 #
 #
 def parse_assesment_target(text)
   # needs a knowledgeStatement
   # needs a unifying theme
   # simple: grade_span
   # simple: target
   # simple: number
   assessment_target = nil
   regex = /([A-Z]+)\s*([0-9])\s*\?*\s*\(([K|0-9].{1,5}[K|0-9])\s*\).{1,5}([A-Z| |\+]+).{1,5}?([0-9|Ext|ext|EXT])(.*)/mi
   matches = text.match(regex)
   if (matches)
     (domain_key,ek_key,grade_span,unifying_theme_key,number,target) = matches.captures

     domain = Domain.find_by_key(domain_key)
     
     knowledge_statement = KnowledgeStatement.find(
       :first, 
       :conditions => { :domain_id => domain.id, :number => number })
    
     unifying_theme = UnifyingTheme.find(
       :first,
       :conditions => {:key => unifying_theme_key})

     assessment_target = AssessmentTarget.new(:knowledge_statement => knowledge_statement, :number => number)
     assessment_target.unifying_theme = unifying_theme
     assessment_target.target = target
     assessment_target.grade_span = grade_span
     assessment_target.save
   else
     puts "Error: cant parse assessment target"
     puts "text is #{text}"
   end
   return assessment_target
 end # end for method dec
 
 def parse_grade_span_expectation(text)
     gse = nil
     regex = /.*?\(\s?([K|0-9].{1,5}[K|0-9])\s?\).{1,5}[0-9](.*)/mi
     matches = text.match(regex)
     if (matches)
       (grade_span,body) = matches.captures
       clean_text(body)
       (stem_string,body) = body.split("…")

       statement_strings = body.split(/[0-9][a-z]{1,4}/)
       statement_strings.each { |s| clean_text(s) }
       statement_strings.reject! { |s| s == "" || s == nil || s == " " }

       # statements.each { | s | puts "--- #{s}" }
       gse = GradeSpanExpectation.new(:grade_span => grade_span)
       gse.save
       stem = ExpectationStem.find_or_create_by_stem(:stem => stem_string)
       stem.save
       stem.grade_span_expectations << gse
       stem.save
      
       ordinal = 'a'
       expectations = statement_strings.map { | ss | 
         expectation  = Expectation.new(:expectation => ss, :ordinal => ordinal)
         expectation.expectation_stem = stem
         expectation.save
         ordinal = ordinal.next
         expectation
       }
     else
       puts "Error: cant parse assessment gse"
     end
     return gse
   end # end for method dec
 
end # end for class
