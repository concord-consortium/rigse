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
  def search(search, page, user, includes={}, policy_scope=nil)
    sql_parameters = []
    sql_conditions = ""
    # pass in a username to limit the search to the users items
    if (!user.nil?) && (!user.id.nil?)
      if column_names.include? 'user_id'
        if self != User
          # sql_conditions = "(#{table_name}.user_id = ? or #{table_name}.public = '1') and "
          sql_conditions = "(#{table_name}.user_id = ?) and "
          sql_parameters << user.id
        end
      end
    end

    if !search.nil? && !search.empty?
      search_terms = get_search_terms(search)

      new_sql_conditions =  search_terms.map do
        ' (' + searchable_attributes.collect {|a| "#{table_name}.#{a} like ?"}.join(' or ') + ')'
      end
      sql_conditions = sql_conditions + new_sql_conditions.join(' and')

      search_terms.each do |st|
        searchable_attributes.length.times {sql_parameters << "%#{st}%"}
      end
    end

    conditions = [sql_conditions] + sql_parameters
    # this results
    # (user_id = ? or public = '1') and name like ? or description like ?, 1, %%, %%, 2
    # debugger

    per_page = self.per_page || 20
    if policy_scope
      policy_scope.where(conditions).includes(includes).page(page).per_page(per_page)
    else
      where(conditions).includes(includes).page(page).per_page(per_page)
    end
  end

  def get_search_terms(search)
    # split search string on white space not contained within a set of double quotes into an array of search terms
    search_terms = search.split(/\s(?=(?:[^"]|"[^"]*")*$)/)

    # remove any double quotation marks from search terms
    search_terms.each do |st|
      st.gsub!(/\"/, '')
    end
  end
end
