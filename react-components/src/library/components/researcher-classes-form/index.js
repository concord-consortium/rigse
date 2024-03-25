import React from 'react'
import Select from 'react-select'
import jQuery from 'jquery'
import ResearcherClassesTable from './table'

import 'react-day-picker/lib/style.css'
import css from './style.scss'

const title = str => (str.charAt(0).toUpperCase() + str.slice(1)).replace(/_/g, ' ')

const queryCache = {}

export default class ResearcherClassesForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      // the current values of the filters
      teachers: [],
      cohorts: [],
      runnables: [],
      // all possible values for each pulldown
      filterables: {
        teachers: [],
        cohorts: [],
        runnables: [],
        classes: []
      },
      // waiting for results
      waitingFor_teachers: false,
      waitingFor_cohorts: false,
      waitingFor_runnables: false,
      waitingFor_classes: false,
      totals: {},
      // checkbox options
      removeCCTeachers: false,
      queryParams: {}
    }
  }

  // eslint-disable-next-line
  UNSAFE_componentWillMount () {
    this.getTotals()
  }

  getTotals () {
    jQuery.ajax({
      url: '/api/v1/researcher_classes',
      type: 'GET',
      data: { totals: true, remove_cc_teachers: this.state.removeCCTeachers, project_id: this.props.projectId }
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
        url: '/api/v1/researcher_classes',
        type: 'GET',
        data: params
      }).then(handleResponse)
    }
  }

  getQueryParams () {
    const params = { remove_cc_teachers: this.state.removeCCTeachers, project_id: this.props.projectId }
    for (var filter of ['teachers', 'cohorts', 'runnables']) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) {
        params[filter] = this.state[filter].map(v => v.value).sort().join(',')
      }
    }
    return params
  }

  updateFilters () {
    const params = this.getQueryParams()
    this.query(params)
    this.query(params, 'teachers')
    this.query(params, 'cohorts')
    this.query(params, 'runnables')
    this.query(params, 'classes')
  }

  renderInput (name, titleOverride) {
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
      })
    }

    const handleLoadAll = e => {
      e.preventDefault()
      this.query({ load_all: name, remove_cc_teachers: this.state.removeCCTeachers, project_id: this.props.projectId }, name)
    }

    const titleCounts = this.state.totals.hasOwnProperty(name) ? ` (${hits.length} of ${this.state.totals[name]})` : ''
    let loadAllLink
    if ((this.state.totals[name] > 0) && (hits.length !== this.state.totals[name])) {
      loadAllLink = <a href='#' onClick={handleLoadAll} style={{ marginLeft: 10 }}>load all</a>
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <span>{`${titleOverride || title(name)}${titleCounts}`}{loadAllLink}</span>
        <Select
          name={name}
          options={options}
          isMulti
          placeholder={placeholder}
          isLoading={isLoading}
          value={this.state[name]}
          onInputChange={handleSelectInputChange}
          onChange={handleSelectChange}
        />
      </div>
    )
  }

  renderForm () {
    const handleRemoveCCTeachers = e => {
      this.setState({ removeCCTeachers: e.target.checked }, () => {
        this.getTotals()
        this.updateFilters()
      })
    }

    return (
      <form method='get'>
        {this.renderInput('cohorts')}
        {this.renderInput('teachers')}
        <div style={{ marginTop: '6px' }}>
          <input type='checkbox' checked={this.state.removeCCTeachers} onChange={handleRemoveCCTeachers} /> Remove Concord Consortium Teachers? *
        </div>
        {this.renderInput('runnables', 'Resources')}

        <div style={{ marginTop: '24px' }}>
          * Concord Consortium Teachers belong to schools named "Concord Consortium".
        </div>
      </form>
    )
  }

  render () {
    const classes = this.state.filterables.classes

    return (
      <div className={css.researcherClassesForm}>
        {this.renderForm()}
        {
          classes.length > 0 &&
          <ResearcherClassesTable classes={classes} />
        }
      </div>
    )
  }
}

ResearcherClassesForm.defaultProps = {
  projectId: ''
}
