require 'open-uri'
require 'yaml'
require 'spreadsheet'

####################################################################
# GseParser --
####################################################################
class GseParser
  
  ELIPSIS = "\u2026"
  EMDASH  = "\u2014"

  attr_accessor :logger
  
  def initialize(options={})
    @domains = {}
    @themes = {}
    @verbose = true
    @logger = Logger.new(STDOUT)
    if options.has_key?(:verbose)
      @verbose = options[:verbose]
      logger.level = Logger::ERROR unless @verbose
    else
      @verbose = true
      logger.level = Logger::INFO
    end
  end

  def pre_parse
    remove_old_data #should delete old stuff
    @domains = make_domains(File.join([::Rails.root.to_s] + %w{config rigse_data domains.yml}))
    make_themes(File.join([::Rails.root.to_s] + %w{config rigse_data themes.yml}))
    @assessment_target_regex = build_assessment_target_regex(@domains.keys)
  end
  
  def process_rigse_data
    pre_parse
    parse(File.join([::Rails.root.to_s] + %w{config rigse_data science_gses PS_RI_K-12.xhtml}))
    parse(File.join([::Rails.root.to_s] + %w{config rigse_data science_gses ESS_RI_K-12.xhtml}))
    parse(File.join([::Rails.root.to_s] + %w{config rigse_data science_gses LS_RI_K-12.xhtml}))
    RiGse::GradeSpanExpectation.all.each { |gse|  gse.set_gse_key }
  end

  #
  def clean_text(text)
    text = text.encode("utf-8", "iso-8859-1")
    if(text)
      # remove all non-ascii except elipses, which I like
      text.gsub!(/[^\x20-\x7E|#{ELIPSIS}]/, "")
      text.gsub!("\n"," ")
      text.gsub!("\t"," ")
      text.gsub!(/\?+/,"")
      text.squeeze!(" ")
      text.strip!
    end
    text
  end

  #
  #
  #
  def remove_old_data
    # The TRUNCATE cammand works in mysql to effectively empty the database and reset 
    # the autogenerating primary key index ... not certain about other databases
    [ RiGse::Domain,
      RiGse::KnowledgeStatement,
      RiGse::AssessmentTarget,
      RiGse::AssessmentTargetUnifyingTheme,
      RiGse::GradeSpanExpectation,
      RiGse::ExpectationIndicator,
      RiGse::ExpectationStem,
      RiGse::Expectation,
      RiGse::UnifyingTheme, 
      RiGse::BigIdea].each do |klass|
        ActiveRecord::Base.connection.delete("TRUNCATE `#{klass.table_name}`")
    end
  end

  #
  #
  #
  def make_domains(domain_yaml)
    domains = {}
    data = YAML::load(File.open(domain_yaml))
    data.keys.each do |key| 
      logger.info(key)
      d = RiGse::Domain.find_or_create_by_key(:key => key, :name => data[key])
      d.save
      logger.info(d.inspect)
      domains[key] = d
    end
    domains
  end

  #
  #
  #
  def make_themes(theme_yaml)
    data = YAML::load(File.open(theme_yaml))
    data.keys.each do |key|
      theme = RiGse::UnifyingTheme.find_or_create_by_key(:key => key, :name => data[key])
      theme.save
      @themes[key] = theme
    end
  end


  #
  # use spreadsheet to pull in additional (incomplete) expectations
  #
  def parse_ri_goals_xls(path_to_xls)
    spreadsheet = Spreadsheet.open path_to_xls
    sheet = spreadsheet.worksheet 'Science'
    domain_regex = @domains.keys.join("|")
    regex = /(#{domain_regex})(\d+)\(([K|0-9]\s*[-|#{EMDASH}]\s*[K|0-9]+)\)\s*[-|#{EMDASH}]\s*([0-9]+)([a-b])(.+)/
    sheet.each do |row| 
      if (row[1])
        begin
          matches = (row[1]).match(regex) # we are only after column #2
          if (matches) # PS3(9-11)-10b Comparing and contrasting electromagnetic waves to mechanical waves.
            (domain_key,someNumber,grade_span,target_number,expectaton_ordinal,description) = matches.captures
            if (domain_key)
              if (domain_key !="PS") # we already have all of these
                expectation  = RiGse::Expectation.new(:description => description, :ordinal => expectaton_ordinal)
                expectation.save
              end
            end
          end
        rescue
          logger.warn "problem reading #{row} / #{sheet}"
        end
      end
    end
  end


  # Parse a xhtml file looking for 
  # table_heading_regex to seperate 
  #
  def parse(path)
    doc = Nokogiri(open(path))
    table_number = 0

    (doc/:table).each do | table |
      table_number = table[:class].gsub("Table","") 
      case table_number.to_i(10)
      when 1
        import_enduring_knowledge table
      when 2
        import_unifying_themes table
      else
        import_gses(table) if is_gses_table(table)
      end
    end
  end
  
  #
  #
  #
  def import_enduring_knowledge (table)
    domain_keys = RiGse::Domain.find(:all).map { |domain| domain.key }
    regex = /^#{domain_keys.join("|")}/
    (table/:tr/:td).each do | td |  
      data = td.inner_text.strip
      if (data =~ regex)
        parse_knowledge_statement data
      end
    end
  end

  #
  #
  #
  def parse_knowledge_statement(text)
    knowledge_statement = nil
    regex = /([A-Z]+)\s?([0-9])(.+)/mi
    matches = text.match(regex)

    if (matches)
      (domain_key,number,statement) = matches.captures
      domain = RiGse::Domain.find_by_key(domain_key)
      if (domain)
        knowledge_statement = RiGse::KnowledgeStatement.find(
        :first, 
        :conditions => { :domain_id => domain.id, :number => number }
        )
        unless (knowledge_statement)
          knowledge_statement=RiGse::KnowledgeStatement.new
        end
        knowledge_statement.domain = domain
        knowledge_statement.number = number
        knowledge_statement.description = statement
        knowledge_statement.save
      end
    else
      logger.warn "unable to parse knowledge statement in text: #{text}"
    end
    return knowledge_statement
  end # end for method dec    


  #
  #
  def import_unifying_themes(table)
    relevent_columns = ((table/:tr)[2]/:td).each do |td| 
      themeName = ((td/:p)[0]).inner_text.strip 
      theme = RiGse::UnifyingTheme.find_by_name(themeName)
      if (theme)
        (td/:li).each do  |li|
          big_idea = RiGse::BigIdea.new
          big_idea.description = (clean_text(li.inner_text)).gsub(/^\./,"")
          big_idea.unifying_theme = theme 
          big_idea.save
        end
      else
        logger.warn "could not find theme for : #{themeName}"
      end
    end   
  end

  ## table: an HTML table that contains GSEs
  def import_gses(table)
    assessment_targets = []
    row_number = 1
    (table/:tr).each do |row|
      column = 1
      (row/:td).each do |data|
        colspan = data['colspan'].nil? ? 1 : data['colspan'].to_i
        column_text = data.inner_text.strip
        clean_text(column_text)
        case row_number
        when 2, 5
          #@logger.debug("ROW=#{row_number} COL=#{column} TXT=#{column_text}")
          assessment_target = parse_assessment_target(column_text)
          colspan.times do |i|
            assessment_targets[column + i] = assessment_target
          end
        when 4, 6, 7
          #@logger.debug("ROW=#{row_number} COL=#{column} TXT=#{column_text}")
          assessment_target = assessment_targets[column]
          if assessment_target
            grade_span_expectation = parse_grade_span_expectation(column_text, assessment_target)
          end
        end # end case
        column += colspan
      end # end for data
      row_number += 1
    end # end for row
  end # end for method declaration

  def parse_assessment_target(text)
    text.strip!
    assessment_target = nil
    #domain_regex = @domains.keys.join("|")
    #space_or_dashes = "[\s|-|–|-]+"
    # (ESS)\s*([0-9]+)\s*\(([K|0-9|\-|\–|\-|\s])+\)[\s|\-|\–|\-][\s|\-|\–|\-]*([A-Z|\s|\+]+)\s*[\s|\-|\–|\-]*(\d+)(.+)
    #regex = /(#{domain_regex})\s*([0-9]+)\s*\(([K|0-9|\-|\–|\s])+\)[\s|\-|\–]*([A-Z|\s|\+]+)\s*[\s|\-|\–|\-]*(\d+)(.+)/mx

    regex = @assessment_target_regex

    matches = text.match(regex)
    if (matches)
      (domain_key,ek_key,grade_span,unifying_theme_key) = matches.captures
      ## Getting number and target seperately because number of matches
      ## for unifying_theme_key is variable
      (number, target) = matches.captures[-2..-1] 

      themes = unifying_theme_key.split(/[\+\s]+/);
      #unifying_theme_key = themes[0]

      domain = @domains[domain_key.strip]

      if (domain)
        knowledge_statement = RiGse::KnowledgeStatement.find(
        :first, 
        :conditions => { :domain_id => domain.id, :number => ek_key })
      else
        logger.warn "could not find domain for #{domain_key}"
      end

      assessment_target = RiGse::AssessmentTarget.new(:knowledge_statement => knowledge_statement, :number => number)
      #unifying_theme = @themes[unifying_theme_key.strip]
      #if (unifying_theme)
      #  assessment_target.unifying_theme = unifying_theme
      #else
      #  logger.warn "could not find unifying theme that matches: #{unifying_theme_key}"
      #end
      assessment_target.description = target.strip
      assessment_target.grade_span = grade_span
      assessment_target.save
      themes.each do |theme|
        assessment_target.add_unifying_theme(@themes[theme])
      end
      return assessment_target
    elsif !text.match(/\ANo further targets/i)
      logger.warn "can't parse assessment target text is #{text}"
    end
    nil
  end # end for method dec

  #
  #
  #
  def parse_grade_span_expectation(text, assessment_target)
    gse = nil
    regex = /.*?\(\s?(Ext\.?|[K|0-9].{1,5}[K|0-9])\s?\).{0,5}[0-9](.+)/mi
    matches = text.match(regex)
    if (matches)
      (grade_span,body) = matches.captures
      grade_span.gsub!(".","") # Ext. has a dot in it.. *sigh*
      old_body = body
      clean_text(body)
      (stem_string,body) = body.split(/\.\.\.|#{ELIPSIS}/)
      if body
        statement_strings = body.split(/[0-9]{1,2}[a-z]{1,4}/)
        statement_strings.each { |s| clean_text(s) }
        statement_strings.reject! { |s| s == "" || s == nil || s == " " }
        gse = RiGse::GradeSpanExpectation.new
        gse.grade_span = grade_span
        gse.assessment_target = assessment_target
        gse.save
        stem = RiGse::ExpectationStem.find_or_create_by_description(stem_string)
        stem.save # force an id
        expectation = RiGse::Expectation.find(:first, :conditions =>   { :expectation_stem_id => stem, :grade_span_expectation_id => gse })
        expectation ||= RiGse::Expectation.new(:expectation_stem => stem, :grade_span_expectation => gse)
        expectation.save
        ordinal = 'a'
        expectations = statement_strings.map { | ss | 
          expectation_indicator  = RiGse::ExpectationIndicator.new(:description => ss, :ordinal => ordinal)
          expectation_indicator.expectation = expectation
          expectation_indicator.save
          ordinal = ordinal.next
          expectation
        }
      else
        logger.warn("couldnt find elipse (#{ELIPSIS}) separating stem from body: #{old_body}")
      end
    else
      logger.warn "can't parse grade span expectation text = #{text}"
    end
    return gse
  end # end for method dec
  
  def is_gses_table(table)
    rows = table.search(:tr)
    heading = rows[0].at(:td).inner_text.strip
    unless heading =~ /^#{@domains.keys.join('|')}/
      table_number = table[:class].gsub("Table", "")
      logger.info("Not a GSES table: table \##{table_number}")
      return false
    end
    if rows[1] and rows[1].search(:td).size == 3
      return true
    else
      return false
    end
  end
  
  def build_assessment_target_regex(domain_keys)
    domain_ptn = domain_keys.join("|")
    grade_ptn = '1?[K0-9]-1?[K0-9]'
    theme_ptn = '[A-Z]{3}([\+\s]+[A-Z]{3})*'
    num_ptn = '\d+'
    
    ## group 1: domain key (e.g. 'LS')
    ## group 2: ek key (e.g. '1')
    ## group 3: grade span (e.g. 'K-2')
    ## group 4: unifying theme (e.g. 'INQ+POC')
    ## group -2: target number (e.g. '1')
    ## group -1: target text
    regex = /\A(#{domain_ptn})\s*([1-9]+)\s*\((#{grade_ptn})\)[\s\-]*(#{theme_ptn})[\s\-]*(#{num_ptn})(.*)/mo
  end
  
end # end for class
