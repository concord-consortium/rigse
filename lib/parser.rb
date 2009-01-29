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
  
  def remove_old_data
    classes_to_clean = [
      Domain,
      KnowledgeStatement,
      AssessmentTarget,
      GradeSpanExpectation,
      ExpectationStem,
      Expectation,
      UnifyingTheme, 
      BigIdea]
    classes_to_clean.each { | c| c.delete_all }
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
    remove_old_data
    make_domains
    make_themes
    
    match_expression = /Table(\d+)_([A-Z][0-9])/i
    doc = Hpricot(open(path))
    table_number = 0
    
    (doc/:table).each do | table |
      table_number = table.attributes['class'].gsub("Table","") 
      case table_number.to_i(10)
      when 1
        import_enduring_knowledge table
      when 2
        import_unifying_themes table
      else
        import_gses table
      end
    end
  end
  
  def import_enduring_knowledge (table)
    puts "======== importing enduring knowledge "
    domain_keys = Domain.find(:all).map { |domain| domain.key }
    regex = /^#{domain_keys.join("|")}/
    eks = (table/:tr).collect { | row |  (row/:td).inner_text.strip }
    eks = eks.select { | ek | ek =~ regex }
    eks.each { |ek| parse_knowledge_statement ek }
  end
  
  #
  #
  #
  def parse_knowledge_statement(text)
    knowledge_statement = nil
    regex = /(\w+?)\s*([0-9])(.*)/mi
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
        knowledge_statement.description = statement
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
  def import_unifying_themes(table)
    puts "======== importing unifying themes "
    relevent_columns = ((table/:tr)[2]/:td).collect { |td| td.inner_text.strip }
    relevent_columns.each { | column | 
      entries = column.split(/\n+/)
      entries.map! { |e| e.strip }
      entries.reject! { |d| d == "" || d =~ /^[\s+\?]+$/|| d.nil?}
      theme = UnifyingTheme.find_by_name(entries[0])
      if (theme)
        (1..(entries.size-1)).each do |i|        
          puts "========>#{entries[i]}|"
          big_idea = BigIdea.new
          big_idea.description = entries[i]
          big_idea.unifying_theme = theme 
          big_idea.save
        end
      else
        puts "could not find theme for : #{entires[0]}"
      end
    }
  end
  
  #
  #
  #s
  def import_gses(table)
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
        when 2,5
          assessment_targets[column] = parse_assesment_target columntext
        when 4,7
          assessment_target_index = (column / 2.0).ceil
          if (assessment_targets[assessment_target_index])
            grade_span_expectation = parse_grade_span_expectation(columntext,assessment_targets[assessment_target_index])
          end
        end # end case
        
      end # end for data
    end # end for row

  end # end for method declaration


  #
  #
  #
  def parse_assesment_target(text)
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
      assessment_target.description = target
      assessment_target.grade_span = grade_span
      assessment_target.save
    else
      puts "Error: cant parse assessment target"
      puts "text is #{text}"
    end
    return assessment_target
  end # end for method dec
  
  #
  #
  #
  def parse_grade_span_expectation(text, assessment_target)
      gse = nil
      regex = /.*?\(\s?([K|0-9].{1,5}[K|0-9])\s?\).{1,5}[0-9](.*)/mi
      matches = text.match(regex)
      if (matches)
        (grade_span,body) = matches.captures
        clean_text(body)
        (stem_string,body) = body.split("…")

        statement_strings = body.split(/[0-9]{1,2}[a-z]{1,4}/)
        statement_strings.each { |s| clean_text(s) }
        statement_strings.reject! { |s| s == "" || s == nil || s == " " }

        # statements.each { | s | puts "--- #{s}" }
        gse = GradeSpanExpectation.new(:grade_span => grade_span)
        gse.assessment_target = assessment_target
        gse.save
        stem = ExpectationStem.find_or_create_by_stem(:stem => stem_string)
        stem.save
        stem.grade_span_expectations << gse
        stem.save
        
        ordinal = 'a'
        expectations = statement_strings.map { | ss | 
          expectation  = Expectation.new(:description => ss, :ordinal => ordinal)
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
