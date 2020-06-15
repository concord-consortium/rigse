import React from 'react'
import ExternalReportButton from '../common/external-report-button'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import 'react-day-picker/lib/style.css'
import css from './style.scss'
import Select from 'react-select'
import jQuery from 'jquery'

const title = str => (str.charAt(0).toUpperCase() + str.slice(1)).replace(/_/g, ' ')

const queryCache = {}

export default class UserReportForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      // the current values of the filters
      teachers: [],
      cohorts: [],
      runnables: [],
      start_date: '',
      end_date: '',
      // all possible values for each pulldown
      filterables: {
        teachers: [],
        cohorts: [],
        runnables: []
      },
      // waiting for results
      waitingFor_teachers: false,
      waitingFor_cohorts: false,
      waitingFor_runnables: false,
      totals: {},
      // checkbox options
      removeCCTeachers: false,
      externalReportButtonDisabled: true,
      queryParams: {}
    }
  }

  // eslint-disable-next-line
  UNSAFE_componentWillMount () {
    this.getTotals()
  }

  getTotals () {
    jQuery.ajax({
      url: '/api/v1/report_users',
      type: 'GET',
      data: { totals: true, remove_cc_teachers: this.state.removeCCTeachers }
    }).then(data => {
      if (data.error) {
        window.alert(data.error)
      }
      if (data.totals) {
        this.setState({ totals: data.totals })
      }
    })
  }

  query (_params, _fieldName, searchString) {
    if (_fieldName) {
      this.setState({ [`waitingFor_${_fieldName}`]: true })
    }
    const params = jQuery.extend({}, _params) // clone
    if (_fieldName) {
      // we remove the value of each field from the filter query for that
      // dropdown, as we want to know all possible values for that dropdown
      // given only the other filters
      delete params[_fieldName]
    }
    if (searchString) {
      params[_fieldName] = searchString
    }

    const cacheKey = JSON.stringify(params)

    const handleResponse = (fieldName => {
      return data => {
        let newState = { filterables: this.state.filterables }

        queryCache[cacheKey] = data

        let hits = data.hits && data.hits[fieldName] ? data.hits[fieldName] : []
        if (searchString) {
          // merge results and remove dups
          let merged = (newState.filterables[fieldName] || []).concat(hits)
          newState.filterables[fieldName] = merged.filter((str, i) => merged.indexOf(str) === i)
        } else {
          newState.filterables[fieldName] = hits
        }

        newState.filterables[fieldName].sort((a, b) => a.label.localeCompare(b.label))

        newState[`waitingFor_${_fieldName}`] = false
        this.setState(newState)
        return data
      }
    })(_fieldName)

    if ((queryCache[cacheKey] != null ? queryCache[cacheKey].then : undefined)) { // already made a Promise that is still pending
      queryCache[cacheKey].then(handleResponse) // chain a new Then
    } else if (queryCache[cacheKey]) { // have data that has already returned
      handleResponse(queryCache[cacheKey]) // use it directly
    } else {
      queryCache[cacheKey] = jQuery.ajax({ // make req and add new Promise to cache
        url: '/api/v1/report_users',
        type: 'GET',
        data: params
      }).then(handleResponse)
    }
  }

  getQueryParams () {
    const params = { remove_cc_teachers: this.state.removeCCTeachers }
    for (var filter of ['teachers', 'cohorts', 'runnables']) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) {
        params[filter] = this.state[filter].map(v => v.value).sort().join(',')
      }
    }
    for (filter of ['start_date', 'end_date']) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) { params[filter] = this.state[filter] }
    }
    return params
  }

  updateQueryParams () {
    const queryParams = this.getQueryParams()
    // <= 1 is used because the params always has remove_cc_teachers defined
    const externalReportButtonDisabled = Object.keys(queryParams).length <= 1
    this.setState({ queryParams, externalReportButtonDisabled })
  }

  updateFilters () {
    const params = this.getQueryParams()
    this.query(params)
    this.query(params, 'teachers')
    this.query(params, 'cohorts')
    this.query(params, 'runnables')
  }

  renderInput (name) {
    if (!this.state.filterables[name]) { return }

    const hits = this.state.filterables[name]

    const isLoading = this.state[`waitingFor_${name}`]
    const placeholder = !isLoading ? (hits.length === 0 ? 'Search...' : 'Select or search...') : 'Loading ...'

    const options = hits.map(hit => {
      return { value: hit.id, label: hit.label }
    })

    const handleSelectInputChange = value => {
      if (value.length === 4) {
        const params = this.getQueryParams()
        this.query(params, name, value)
      }
    }

    const handleSelectChange = value => {
      this.setState({ [name]: value }, () => {
        this.updateFilters()
        this.updateQueryParams()
      })
    }

    const handleLoadAll = e => {
      e.preventDefault()
      this.query({ load_all: name, remove_cc_teachers: this.state.removeCCTeachers }, name)
    }

    const titleCounts = this.state.totals.hasOwnProperty(name) ? ` (${hits.length} of ${this.state.totals[name]})` : ''
    let loadAllLink
    if ((this.state.totals[name] > 0) && (hits.length !== this.state.totals[name])) {
      loadAllLink = <a href='#' onClick={handleLoadAll} style={{ marginLeft: 10 }}>load all</a>
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <span>{`${title(name)}${titleCounts}`}{loadAllLink}</span>
        <Select
          name={name}
          options={options}
          multi
          joinValues
          placeholder={placeholder}
          isLoading={isLoading}
          value={this.state[name]}
          onInputChange={handleSelectInputChange}
          onChange={handleSelectChange}
        />
      </div>
    )
  }

  renderDatePicker (name) {
    const label = name === 'start_date' ? 'Earliest date' : 'Latest date'

    const handleChange = value => {
      if (!value) {
        // Incorrect date.
        return
      }
      this.setState({ [name]: formatDate(value) }, () => {
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

  renderForm () {
    const { externalReports, portalToken } = this.props
    const { queryParams, externalReportButtonDisabled } = this.state
    const queryUrl = Portal.API_V1.EXTERNAL_RESEARCHER_REPORT_USER_QUERY

    const handleRemoveCCTeachers = e => {
      this.setState({ removeCCTeachers: e.target.checked }, () => {
        this.getTotals()
        this.updateFilters()
      })
    }

    return (
      <form method='get' style={{ minHeight: 700 }}>
        {this.renderInput('teachers')}
        <div style={{ marginTop: '6px' }}>
          <input type='checkbox' checked={this.state.removeCCTeachers} onChange={handleRemoveCCTeachers} /> Remove Concord Consortium Teachers? *
        </div>
        {this.renderInput('cohorts')}
        {this.renderInput('runnables')}

        {this.renderDatePicker('start_date')}
        {this.renderDatePicker('end_date')}

        <div style={{ marginTop: '12px' }}>
          {externalReports.map(lr =>
            <ExternalReportButton key={lr.url + lr.label} label={lr.label} reportUrl={lr.url} queryUrl={queryUrl} isDisabled={externalReportButtonDisabled} queryParams={queryParams} portalToken={portalToken} />
          )}
        </div>

        <div style={{ marginTop: '24px' }}>
          * Concord Consortium Teachers belong to schools named "Concord Consortium".
        </div>
      </form>
    )
  }

  render () {
    return (
      <div className={css.learnerReportForm}>
        {this.renderForm()}
        {/* Spacer element is added so there's some space for the date picker element. Portal footer doesn't
            work too well with this form otherwise. */}
        <div className={css.spacerForDayPicker} />
      </div>
    )
  }
}

UserReportForm.defaultProps = {
  externalReports: []
}
