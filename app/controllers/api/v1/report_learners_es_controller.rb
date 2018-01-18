class API::V1::ReportLearnersEsController < API::APIController

  public

  # Returns Elasticsearch query of report_learners, with filters and
  # aggregations.
  #
  # GET /api/v1/report_learners_es
  #   Returns count of all report_learners and named aggregations with no filters
  #
  # GET /api/v1/report_learners_es?schools={comma-separtated ids}&
  #                                teachers={comma-separtated ids}&
  #                                runnables={comma-separated type_id}&    (e.g. externalactivity_1)
  #                                permission_forms={comma-separtated ids}
  #   ... each query is optional.
  #   Returns filtered counts of all report_learners and named aggregations
  #
  # GET /api/v1/report_learners_es?schools={search-string}&{other-filters}
  #
  #   Search for a school/teacher/runnable/form containing search_string
  #
  # GET /api/v1/report_learners_es?{filters}&show_learners={maxSize}
  #   Returns list of report_learners matching filters, up to max size, no aggregations
  #
  def index
    authorize Portal::PermissionForm

    if !ENV['ELASTICSEARCH_URL']
      return error("Elasticsearch endpoint url not set")
    end

    esSearchResult = self.class.query_es(params, current_user)
    render :json => esSearchResult
  end

  def self.query_es(options, user)

    if user.has_role?('manager','admin','researcher')
      all_access = true
    else
      all_access = false
      viewable_permission_forms = Pundit.policy_scope(user, Portal::PermissionForm)
      viewable_permission_form_ids = viewable_permission_forms.map(&:id)
    end


    filters = []
    hits = 0

    if options[:schools] && !options[:schools].empty?
      if /\A(\d+,*)+\z/.match(options[:schools])
        schools = options[:schools].split(',').map(&:to_i)
        filters << {
          :terms => {
            :school_id => schools
          }
        }
      else
        filters << {
          :prefix => {
            :school_name => options[:schools].downcase
          }
        }
      end
    end
    if options[:teachers] && !options[:teachers].empty?
      if /\A(\d+,*)+\z/.match(options[:teachers])
        teachers = options[:teachers].split(',').map(&:to_i)
        filters << {
          :terms => {
            :teacher_ids => teachers
          }
        }
      else
        filters << {
          :prefix => {
            :teacher_name_and_id => options[:teachers].downcase
          }
        }
      end
    end
    if options[:runnables] && !options[:runnables].empty?
      runnables = options[:runnables].split(',')
      filters << {
        :terms => {
          "runnable_type_and_id.keyword" => runnables
        }
      }
    end

    # If we don't have all_access privilages:
    #   If we request specific permission forms, check we have access to them.
    #   If we don't request any, or we don't have access to any of the ones we
    #     requested, request all the ones we have access to.
    # If we have all_access privilages:
    #   Pass request through, including no filter (allows access to users without PF)
    pfs = []
    if options[:permission_forms] && !options[:permission_forms].empty?
      pfs = options[:permission_forms].split(',').map(&:to_i)
      if !all_access
        pfs = pfs.select {|pf| viewable_permission_form_ids.include? pf}
        pfs = viewable_permission_form_ids if pfs.empty?
      end
    elsif !all_access
      pfs = viewable_permission_form_ids
    end

    if !all_access || !pfs.empty?
      filters << {
        :terms => {
          :permission_form_ids => pfs
        }
      }
    end

    if options[:start_date] && !options[:start_date].empty?
      date = options[:start_date].split('/')
      date = "#{date[2]}-#{date[0]}-#{date[1]}"
      filters << {
        :range => {
          :last_run => {
            :gte => date
          }
        }
      }
    end
    if options[:end_date] && !options[:end_date].empty?
      date = options[:end_date].split('/')
      date = "#{date[2]}-#{date[0]}-#{date[1]}"
      if options[:start_date] && !options[:start_date].empty?
        filters.last[:range][:last_run][:lte] = date
      else
        filters << {
          ['range'] => {
            :last_run => {
              :lte => date
            }
          }
        }
      end
    end

    if options[:show_learners]
      hits = options[:show_learners]
      aggs = {}
    else
      largeAggSize = 1000
      smallAggSize = 500
      aggs = {
        :count_students => {
          :cardinality => {
            :field => "student_id"
          }
        },
        :count_classes => {
          :cardinality => {
            :field => "class_id"
          }
        },
        :count_teachers => {
          :cardinality => {
            :field => "teacher_name_and_id.keyword"
          }
        },
        :schools => {
          :terms => {
            :field => "school_name_and_id.keyword",
            :size => largeAggSize
          }
        },
        :teachers => {
          :terms => {
            :field => "teacher_name_and_id.keyword",
            :size => smallAggSize
          }
        },
        :runnables => {
          :terms => {
            :field => "runnable_type_id_name.keyword",
            :size => largeAggSize
          }
        },
        :permission_forms => {
          :terms => {
            :field => "permission_forms.keyword",
            :size => largeAggSize
          },
          :aggs => {
            :permission_form_ids => {
              :terms => {
                :field => "permission_form_ids.keyword"
              }
            }
          }
        }
      }
    end

    search_url = "#{ENV['ELASTICSEARCH_URL']}/report_learners/_search"

    esSearchResult = HTTParty.post(search_url,
      :body => {
        :size => hits,
        :aggs => aggs,
        :query => {
          :bool => {
            :filter => filters
          }
        }
      }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return esSearchResult
  end
end
