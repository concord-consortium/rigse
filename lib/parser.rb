require 'open-uri'
require 'yaml'
####################################################################
# Parser --
####################################################################
class Parser
  
  
  def initialize
    @domains = {}
    @themes = {}
  end
    
  #
  #
  #
  def clean_text(text) 
    if(text)
      text.gsub!("\n"," ")
      text.gsub!("\t"," ")
      text.gsub!("\?","")
      text.squeeze!(" ")
      text.strip!
    end
  end
  
  #
  #
  #
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
    classes_to_clean.each { | c| c.destroy_all }
  end
  
  #
  #
  #
  def make_domains(domain_yaml)
    data = YAML::load(File.open(domain_yaml))
    data.keys.each do |key| 
      d = Domain.find_or_create_by_key(:key => key, :name => data[key])
      d.save
      @domains[key] = d
    end
  end

  #
  #
  #
  def make_themes(theme_yaml)
    data = YAML::load(File.open(theme_yaml))
    data.keys.each do |key|
      theme = UnifyingTheme.find_or_create_by_key(:key => key, :name => data[key])
      theme.save
      @themes[key] = theme
      end
    end
  
  
  # Parse a xhtml file looking for 
  # table_heading_regex to seperate 
  #
  def parse(path)
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
  
  
  #
  #
  #
  def import_enduring_knowledge (table)
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
    regex = /([A-Z]+)\s?([0-9])(.*)/mi
    matches = text.match(regex)
    
    if (matches)
      (domain_key,number,statement) = matches.captures
      puts "domain: #{domain_key} number: #{number} statement: #{statement}"
      domain = Domain.find_by_key(domain_key)
      if (domain)
        knowledge_statement = KnowledgeStatement.find(
          :first, 
          :conditions => { :domain_id => domain.id, :number => number }
        )
        unless (knowledge_statement)
          knowledge_statement=KnowledgeStatement.new
        end
        knowledge_statement.domain = domain
        knowledge_statement.number = number
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
    relevent_columns = ((table/:tr)[2]/:td).collect { |td| td.inner_text.strip }
    relevent_columns.each { | column | 
      entries = column.split(/\n+/)
      entries.map! { |e| e.strip }
      entries.reject! { |d| d == "" || d =~ /^[\s+\?]+$/|| d.nil?}
      theme = UnifyingTheme.find_by_name(entries[0])
      if (theme)
        (1..(entries.size-1)).each do |i|        
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
    ut_regex = @themes.keys.join("|")
    domain_regex = @domains.keys.join("|")
    space_or_dashes = "[\s|-|–|-]+"
    regex = /(#{domain_regex})\s*([0-9]+)\s*\(\s*([K|0-9][ |-|–|-][K|0-9]+)\s*\)[ |-|–|-]+((#{ut_regex})[\s|\+])*[ |-|–|-]+(.*)/mix
    
    matches = text.match(regex)
    if (matches)
      (domain_key,ek_key,grade_span,unifying_theme_key,number,target) = matches.captures
    
      
      themes = unifying_theme_key.split(' +');
      themes.map { |theme| theme.gsub!("+","") }
      unifying_theme_key = themes[0]

      domain = @domains[domain_key.strip]

      if (domain)
        knowledge_statement = KnowledgeStatement.find(
          :first, 
          :conditions => { :domain_id => domain.id, :number => ek_key })
      else
        puts "could not find domain for #{domain_key}"
      end

      assessment_target = AssessmentTarget.new(:knowledge_statement => knowledge_statement, :number => number)
      unifying_theme = @themes[unifying_theme_key.strip]
      if (unifying_theme)
        assessment_target.unifying_theme = unifying_theme
      else
        puts "could not find unifying theme that matches: #{unifying_theme_key}"
      end
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
