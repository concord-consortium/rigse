import React from 'react'
import ExternalReportButton from '../common/external-report-button'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import 'react-day-picker/lib/style.css'
import css from './style.scss'
import Select from 'react-select'
import { debounce } from 'throttle-debounce'
import jQuery from 'jquery'

const title = str => (str.charAt(0).toUpperCase() + str.slice(1)).replace(/_/g, ' ')

// This param is used mostly for testing purposes. It allows to set a custom limit for the number of results,
// so staging environments can test how the dropdowns behave when the number of results is too high.
const getQueryLimitParam = () => {
  const urlParams = new URLSearchParams(window.location.search)
  return urlParams.get('queryLimit')
}

const queryCache = {}

export default class LearnerReportForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      counts: {},
      // the current values of the filters
      schools: [],
      teachers: [],
      runnables: [],
      permission_forms: [],
      start_date: '',
      end_date: '',
      hide_names: false,
      // all possible values for each pulldown
      filterables: {
        schools: [],
        teachers: [],
        runnables: [],
        permission_forms: []
      },
      // waiting for results
      waitingFor_schools: false,
      waitingFor_teachers: false,
      waitingFor_runnables: false,
      waitingFor_permission_forms: false,
      // too many results to display in the dropdown
      tooManyResults_schools: false,
      tooManyResults_teachers: false,
      tooManyResults_runnables: false,
      tooManyResults_permission_forms: false,
      // state of the text input within the dropdown
      textInput_schools: '',
      textInput_teachers: '',
      textInput_runnables: '',
      textInput_permission_forms: '',

      externalReportButtonDisabled: true,
      queryParams: {}
    }
  }

  // eslint-disable-next-line
  UNSAFE_componentWillMount () {
    this.updateFilters()
  }

  // Queries ES using the portal API
  // If we pass a field name, the filter box for that field will *not* be
  // updated, b ut all others will. This lets us find all possible values
  // for a dropdown given all the other filters.
  // If we don't pass a field name, the counts are updates.
  // All requests are cached, and if we make a duplicate request as one that
  // is still pending, the new callback is added as a chained promise, so that
  // no new request is made.
  query (_params, fieldName, searchString) {
    if (fieldName) {
      this.setState({ [`waitingFor_${fieldName}`]: true })
    }
    const params = jQuery.extend({}, _params) // clone
    if (fieldName) {
      // we remove the value of each field from the filter query for that
      // dropdown, as we want to know all possible values for that dropdown
      // given only the other filters
      delete params[fieldName]
    }
    if (searchString) {
      params[fieldName] = searchString
    }

    const cacheKey = JSON.stringify(params)

    const handleResponse = data => {
      let newState
      queryCache[cacheKey] = data
      const aggs = data.aggregations
      if (fieldName) {
        newState = { filterables: this.state.filterables }
        let { buckets, sum_other_doc_count: overLimitCount } = aggs[fieldName]
        const idsField = `${fieldName}_ids`

        if (overLimitCount === 0) {
          if (aggs[idsField]) {
            // some fields have a separate id aggregration that is filtered
            // based on the access of the current user
            // we use this to filter the buckets in the main field aggregration
            const filteredIds = aggs[idsField].buckets.map(b =>
              // sometimes this will be an integer and sometimes it will be a string
              // convert it to a string for consistency
              b.key.toString()
            )

            buckets = buckets.filter(b => filteredIds.indexOf(b.key.match(/\d+/)[0]) !== -1)
          }

          newState[`tooManyResults_${fieldName}`] = false
          newState.filterables[fieldName] = buckets
        } else {
          // ElasticSearch returns sum_other_doc_count (named overLimitCount here) if the number of buckets is over
          // a certain limit specified in the query. If this is the case, we don't display the results in the dropdown
          // and ask the user to refine their search.
          newState[`tooManyResults_${fieldName}`] = true
          newState.filterables[fieldName] = []
        }

        newState[`waitingFor_${fieldName}`] = false
      } else {
        newState = {
          counts: {
            learners: data.hits.total,
            students: aggs.count_students.value,
            classes: aggs.count_classes.value,
            teachers: aggs.count_teachers.value,
            runnables: aggs.count_runnables.value
          }
        }
      }
      this.setState(newState)
      return data
    }

    if (queryCache[cacheKey]?.then) { // already made a Promise that is still pending
      queryCache[cacheKey].then(handleResponse) // chain a new Then
    } else if (queryCache[cacheKey]) { // have data that has already returned
      handleResponse(queryCache[cacheKey]) // use it directly
    } else {
      queryCache[cacheKey] = jQuery.ajax({ // make req and add new Promise to cache
        url: '/api/v1/report_learners_es',
        type: 'GET',
        data: params
      }).then(handleResponse)
    }
  }

  getQueryParams () {
    const params = {}
    for (var filter of ['schools', 'teachers', 'runnables', 'permission_forms']) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) {
        params[filter] = this.state[filter].map(v => v.value).sort().join(',')
      }
    }
    for (filter of ['start_date', 'end_date']) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) { params[filter] = this.state[filter] }
    }
    const customQueryLimit = getQueryLimitParam()
    if (customQueryLimit) {
      params.query_limit = customQueryLimit
    }
    return params
  }

  updateQueryParams () {
    const queryParams = this.getQueryParams()
    const externalReportButtonDisabled = Object.keys(queryParams).length === 0
    this.setState({ queryParams, externalReportButtonDisabled })
  }

  updateFilters () {
    const params = this.getQueryParams()
    // update the counts, and the values in all the dropdowns. We have to do
    // them all separately, as each dropdown may require a different query,
    // depending on the other filters. If the queries are the same, however,
    // no additional requests are made over the network
    this.query(params)
    this.query(params, 'schools')
    this.query(params, 'teachers')
    this.query(params, 'runnables')
    this.query(params, 'permission_forms')
  }

  renderTopInfo () {
    const { counts } = this.state
    if ((Object.keys(counts)).length > 0) {
      return Object.keys(counts).map(k => {
        // rename runnables to resources
        const label = k === 'runnables' ? 'resources' : k
        return (
          <span key={k} style={{ paddingLeft: 12 }}>
            <span style={{ fontWeight: 'bold' }}>{label}</span>
            <span style={{ paddingLeft: 6 }}>{this.state.counts[k]}</span>
          </span>
        )
      })
    } else {
      return <i className='wait-icon fa fa-spinner fa-spin' />
    }
  }

  renderInput (name, titleOverride) {
    if (!this.state.filterables[name]) { return }
    const agg = this.state.filterables[name]

    const isLoading = this.state[`waitingFor_${name}`]
    const placeholder = !isLoading ? 'Select ...' : 'Loading ...'

    // convert to all strings
    let options = agg.map(function (f) { if (typeof f === 'string') { return f } else { return f.key } })

    // rm dupes
    options = options.filter((str, i) => options.indexOf(str) === i)

    // split into values/labels
    options = options.map(function (f) {
      const idName = typeof f === 'string' ? f.split(/:(.+)/) : f.key.split(/:(.+)/)
      return { value: idName[0], label: idName[1] }
    })

    // rm messed-up ES values
    options = options.filter(o => o.value.indexOf('%{') < 0)

    // average keystroke delay is 100-200ms
    const debouncedHandleTextInputChange = debounce(350, (value) => {
      const previousValue = this.state[`textInput_${name}`]
      this.setState({ [`textInput_${name}`]: value })

      if (value.startsWith(previousValue) && !this.state[`tooManyResults_${name}`]) {
        // Nothing to do, as the user keeps narrowing the search in a way that doesn't require querying the server.
        // Filtering will be done on the client side by the React Select component.
        return
      }
      // In any other scenario, such as the user deleting a character, completely clearing the search box, or changing
      // the search text, we need to query the server to obtain a new list of options. It's likely that some of these
      // queries are already cached.
      this.query(this.getQueryParams(), name, value)
    })

    const handleSelectChange = value => {
      this.setState({ [name]: value }, () => {
        this.updateFilters()
        this.updateQueryParams()
      })
    }

    const noOptionsMessage = ({ inputValue }) => {
      if (this.state[`tooManyResults_${name}`]) {
        return 'Too many results. Please refine your search to narrow down the list.'
      }
      return 'No results found.'
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <span>{titleOverride || title(name)}</span>
        <Select
          name={name}
          options={options}
          value={this.state[name]}
          isLoading={isLoading}
          isMulti
          placeholder={placeholder}
          noOptionsMessage={noOptionsMessage}
          onInputChange={debouncedHandleTextInputChange}
          onChange={handleSelectChange}
        />
      </div>
    )
  }

  renderDatePicker (name) {
    const label = name === 'start_date' ? 'Earliest date of last run' : 'Latest date of last run'

    const handleChange = value => {
      if (!value) {
        // Incorrect date.
        return
      }
      this.setState({ [name]: formatDate(value) }, () => {
        this.updateFilters()
        this.updateQueryParams()
      })
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <div>{label}</div>
        <DayPickerInput
          inputProps={{ name: name }}
          placeholder={'MM/DD/YYYY'}
          format={'MM/DD/YYYY'}
          parseDate={parseDate}
          formatDate={formatDate}
          selectedDay={this.state[name]}
          onDayChange={handleChange}
        />
      </div>
    )
  }

  renderCheck (name) {
    const handleChange = evt => {
      this.setState({ [name]: evt.target.checked })
    }
    return (
      <div>
        <input
          name={name}
          type='checkbox'
          checked={this.state[name]}
          onChange={handleChange}
        />
        {title(name)}
      </div>
    )
  }

  renderButton (name) {
    return (
      <input
        type='submit'
        name='commit'
        value={name}
      />
    )
  }

  renderForm () {
    const { externalReports } = this.props
    const { queryParams, externalReportButtonDisabled } = this.state
    // ...LEARNER_QUERY is the renamed ...REPORT_QUERY, use a fallback to wait for the portal to update
    const learnerQueryUrl = Portal.API_V1.EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY || Portal.API_V1.EXTERNAL_RESEARCHER_REPORT_QUERY
    const jwtQueryUrl = Portal.API_V1.EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY_JWT

    externalReports.sort((a, b) => a.label.localeCompare(b.label))
    const adminOnlyExternalReports = externalReports.filter(r => r.name.indexOf('[DEV]') !== -1)
    const nonAdminExternalReports = externalReports.filter(r => adminOnlyExternalReports.indexOf(r) === -1)

    const renderExternalReports = (reports) => {
      return reports.map(lr => {
        const queryUrl = lr.useQueryJwt ? jwtQueryUrl : learnerQueryUrl
        return <ExternalReportButton key={lr.url + lr.label} label={lr.label} reportUrl={lr.url} queryUrl={queryUrl} isDisabled={externalReportButtonDisabled} queryParams={queryParams} />
      })
    }

    return (
      <form method='get'>
        {this.renderInput('schools')}
        {this.renderInput('teachers')}
        {this.renderInput('runnables', 'Resources')}
        {this.renderInput('permission_forms')}

        {this.renderDatePicker('start_date')}
        {this.renderDatePicker('end_date')}

        {this.renderCheck('hide_names')}

        <div style={{ marginTop: '12px' }}>
          {renderExternalReports(nonAdminExternalReports)}
        </div>
        {Portal.currentUser.isAdmin && adminOnlyExternalReports.length > 0 && (
          <>
            <div style={{ marginTop: '12px' }}>
              <strong>For Developers Only:</strong>
            </div>
            <div>
              {renderExternalReports(adminOnlyExternalReports)}
            </div>
          </>
        )}
        <div style={{ marginTop: '24px' }}>
          Need help?  Read the <a target='_blank' href='https://docs.google.com/document/d/1jNKjSworR_1ARdSPT8vq6PElKqZ-7zw8BFanZiVcxPs/edit'>Researcher Reports &amp; Logs User Guide</a>.
        </div>
      </form>
    )
  }

  render () {
    return (
      <div className={css.learnerReportForm}>
        <div>
          <h3>Your filter matches:</h3>
          {this.renderTopInfo()}
        </div>
        {this.renderForm()}
        {/* Spacer element is added so there's some space for the date picker element. Portal footer doesn't
            work too well with this form otherwise. */}
        <div className={css.spacerForDayPicker} />
      </div>
    )
  }
}

LearnerReportForm.defaultProps = {
  externalReports: []
}
