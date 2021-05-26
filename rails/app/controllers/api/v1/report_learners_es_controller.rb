require 'digest/md5'

class API::V1::ReportLearnersEsController < API::APIController

  PAGINATED_ELASTIC_SEARCH_SIZE = 1000

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

  # Returns a signed set of learners from a query that can be used by the external researcher report.
  def external_report_query
    authorize Portal::PermissionForm

    # Note that Report::Learner::Selector is a little helper that actually calls
    # API::V1::ReportLearnersEsController.query_es.
    learner_selector = Report::Learner::Selector.new(params, current_user, {:include_runnable_and_learner => true})
    # In the future, we might want to extend this query format and add other filters, e.g. dates.
    response = {
      type: "learners",
      version: "1.1",
      learners: learner_selector.learners.map do |l|
        {
          run_remote_endpoint: l.learner ? l.learner.remote_endpoint_url : nil,
          class_id: l.class_id,
          runnable_url: l.runnable && l.runnable.respond_to?(:url) ? l.runnable.url : nil
        }
      end,
      user: {
        id: url_for(current_user),
        email: current_user.email
      }
    }
    # Note that we're not generating JWT. We're only signing generated query JSON, so the external report can verify
    # that it's coming from the Portal and it hasn't been modified on the way. The external report app needs to know
    # hmac_secret to verify query and signature.
    signature = OpenSSL::HMAC.hexdigest("SHA256", SignedJWT.hmac_secret, response.to_json)
    render json: {
      json: response,
      signature: signature
    }.to_json
  end

  skip_before_filter :verify_authenticity_token
  rescue_from SignedJWT::Error, with: :error_500

  # returns a JWT containing the uuid of the requester, alongside the original query and some other parameters.
  # By sending back the JWT and query to external_report_learners_from_jwt, we can make an authorized request
  # for the learner data details (with the permissions available to the user named in the jwt).
  # The JSON containing the query doesn't get signed because a report will ask for it directly from the portal
  # API (unlike the external_report_query route above, which is queried internally by the portal report filter
  # page, and then the results are handed to the external request as POST from a form, so the report doesn't
  # actually know where they came from.)
  def external_report_query_jwt
    authorize Portal::PermissionForm

    response = {
      token: SignedJWT::create_portal_token(current_user, {}, 3600),   # just sets uid
      json: {
        query: params,
        type: "learners",
        version: "2",
        user: {
          id: url_for(current_user),
          email: current_user.email
        },
        reportServiceUrl: external_report_learners_from_jwt_api_v1_report_learners_es_url,
        paginationSize: PAGINATED_ELASTIC_SEARCH_SIZE
      }
    }

    render json: response.to_json
  end

  # returns an array of learer-details, given a query and a jwt
  # The JWT is parsed by the common api controller, and if it contains a user's uid it will assign
  # current_user to that user.
  # The query is the same query from the report filter page that would otherwise be passed to external_report_query.
  # This will return a list of learner-details no larger than PAGINATED_ELASTIC_SEARCH_SIZE
  # in order to retrieve more results, this same route can be requested multiple times with a start_from parameter.
  # Note that this version of the pagination is capped at 100,000 results:
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html
  def external_report_learners_from_jwt
    query = params["query"]
    start_from = params["start_from"] || 0

    query[:size_limit] = PAGINATED_ELASTIC_SEARCH_SIZE

    learner_selector = Report::Learner::Selector.new(query, current_user, {
      :include_runnable_and_learner => true,
      :start_from => start_from
    })

    response = {
      json: {
        version: "1",
        learners: learner_selector.learners.map {|l| self.class.detailed_learner_info l}
      }
    }
    render json: response.to_json
  end

  # Query elastic search to get the learners we want, with the permissions we have available
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

    # Based on this code sometimes schools is a list of ids and sometimes
    # it might be just one id, or it might be an id:name
    # FIXME: document what types of data schools can be better
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

    # Based on this code sometimes teachers is a list of ids and sometimes
    # it might be just one id, or it might be an id:name
    # FIXME: document what types of data teachers can be better
    if options[:teachers] && !options[:teachers].empty?
      if /\A(\d+,*)+\z/.match(options[:teachers])
        teachers = options[:teachers].split(',').map(&:to_i)
        filters << {
          :terms => {
            :teachers_id => teachers
          }
        }
      else
        filters << {
          :prefix => {
            :teachers_map => options[:teachers].downcase
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
          :permission_forms_id => pfs
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
            :field => "teachers_map.keyword"
          }
        },
        :count_runnables => {
          :cardinality => {
            :field => "runnable_id"
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
            :field => "teachers_map.keyword",
            :size => smallAggSize
          }
        },
        :runnables => {
          :terms => {
            :field => "runnable_type_id_name.keyword",
            :size => largeAggSize
          }
        },
        # The permission form buckets returned here may include forms the current user
        # does not has access too. This can happen because some students might have
        # multiple permission forms assigned to them. Both of these permission forms will
        # be added to the document in elasticsearch, so both will show up in the aggregration
        # this is addressed through the use of the 'include' which is added down below
        :permission_forms => {
          :terms => {
            :field => "permission_forms_map.keyword",
            :size => largeAggSize
          },
        },
        :permission_forms_ids => {
          :terms => {
            :field => "permission_forms_id",
            :size => largeAggSize,
          }
        }
      }

      # limit the ids of the returned permission form ids based on what the user
      # has access to
      if !all_access
        aggs[:permission_forms_ids][:terms][:include] = viewable_permission_form_ids
      end
    end

    search_url = "#{ENV['ELASTICSEARCH_URL']}/report_learners/_search"

    query = {
      :size => hits,
      :aggs => aggs,
      :query => {
        :bool => {
          :filter => filters
        }
      }
    }

    if options[:start_from]
      query[:from] = options[:start_from]
    end

    logger.info "ES Query:"
    logger.info query

    esSearchResult = HTTParty.post(search_url,
      :body => query.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return esSearchResult
  end

  def self.detailed_learner_info(learner)
    {
      student_id: learner.student_id,
      learner_id: learner.learner_id,
      class_id: learner.class_id,
      class: learner.class_name,
      school: learner.school_name,
      user_id: learner.user_id,
      permission_forms: learner.permission_forms,
      username: learner.username,
      student_name: learner.student_name,
      teacher_name: learner.teachers_name,
      teacher_id: learner.teachers_id,
      teacher_district: learner.teachers_district,
      teacher_state: learner.teachers_state,
      teacher_email: learner.teachers_email,
      last_run: learner.last_run,
      run_remote_endpoint: learner.learner ? learner.learner.remote_endpoint_url : nil,
      runnable_url: learner.runnable && learner.runnable.respond_to?(:url) ? learner.runnable.url : nil
    }
  end
end
