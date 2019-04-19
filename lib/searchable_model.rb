# === Module SearchableModel
#
# An extension of code described here:
#
#   http://github.com/mislav/will_paginate/wikis/simple-search
#
# Extend a model class with SearchableModel to support paginated searching
#
#    self.extend SearchableModel
#
# Specify attributes to be searched in a class variable and accessor called:
#
#    @@searchable_attributes = %w{name description model_type.name}
#    class <<self
#      def searchable_attributes
#        @@searchable_attributes
#      end
#    end
#
# Create @searchable_attributes instance variable in controller for model
# for later use in view.
#
#   @searchable_attributes = Investigation.searchable_attributes
#
# Create controller paginated model instance variable like this:
#
#    @investigations = Investigation.search(params[:search], params[:page], current_visitor)
#
# Optionally add an include parameter to eagerly load asociations:
#
#   @investigations = Investigation.search(params[:search], params[:page], current_visitor, [{:learners => :learner_sessions}])
#
module SearchableModel
  # see: http://github.com/mislav/will_paginate/wikis/simple-search
  def search(search, page, user, includes={})
    sql_parameters = []
    sql_conditions = ""
    # pass in a username to limit the search to the users items
    if (!user.nil?) && (!user.id.nil?)
      if column_names.include? 'user_id'
        if self == User
          sql_conditions = ""
        else
          # sql_conditions = "(#{table_name}.user_id = ? or #{table_name}.public = '1') and "
          sql_conditions = "(#{table_name}.user_id = ?) and "
          sql_parameters << user.id
        end
      end
    end

    # debugger

    if !search.nil? && !search.empty?
      # split search into separate terms on white space not contained within a set of double quotes
      search_terms = search.split(/\s(?=(?:[^"]|"[^"]*")*$)/)
      # remove any double quotation marks
      search_terms.each do |st|
        st.gsub!(/\"/, '')
      end

      sql_conditions = sql_conditions + '(' + searchable_attributes.collect {|a| "#{table_name}.#{a} like ?"}.join(' or ') + ')'

      # FIXME - This search should do the following: split the terms based on whitespace, then perform the search
      # like this.  Given fields a, b, and c, and terms x and y we want to query in this way:
      # (a like x OR b like x OR c like x) AND (a like y OR b like y OR c like y)
      # we should also allow the search not to break on whitespace enclosed in quotes... maybe tokenize it?
      # iterate over the string, look for quote or just start the strings into an array
      # we could first split then check each part and see if it has a quote or not.  If one has a quote, it needs to be combined with the subsequent one until the other quote is found
      # do a search to see if we have quoted strings, and then replace the whitespace in the quoted strings with another character, then do the split, then fix the whitespace
      # or just only allow quotes at start and end
      # maybe we'll need to add a nested block.

      if search_terms.length > 1
        # skip first item of array since that's covered by first update of sql_conditions string above
        search_terms.drop(1).each do |st|
          sql_conditions = sql_conditions + ' and (' + searchable_attributes.collect {|a| "#{table_name}.#{a} like ?"}.join(' or ') + ')'
        end
      end

      search_terms.each do |st|
        searchable_attributes.length.times {sql_parameters << "%#{st}%"}
      end
    end

    conditions = [sql_conditions] + sql_parameters
    # this results
    # (user_id = ? or public = '1') and name like ? or description like ?, 1, %%, %%, 2
    # debugger

    per_page = self.per_page || 20
    paginate(:per_page => per_page, :page => page, :conditions => conditions, :include => includes)
  end
end
