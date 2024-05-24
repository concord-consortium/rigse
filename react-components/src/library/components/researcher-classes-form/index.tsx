import React from 'react'
import Select from 'react-select'
import jQuery from 'jquery'
import ResearcherClassesTable from './table'

// import 'react-day-picker/style.css'
import css from './style.scss'

const title = str => (str.charAt(0).toUpperCase() + str.slice(1)).replace(/_/g, ' ')
const pluralize = (count, singular, plural) => count === 1 ? `${count} ${singular}` : `${count} ${plural}`

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
        runnables: []
      },
      classes: [],
      stats: null,
      // waiting for results
      waitingFor_teachers: false,
      waitingFor_cohorts: false,
      waitingFor_runnables: false,
      // checkbox options
      removeCCTeachers: false
    }
  }

  noFilterSelected () {
    return this.state.teachers.length === 0 && this.state.cohorts.length === 0 && this.state.runnables.length === 0
  }

  // If we pass a field name, the filter box for that field will *not* be
  // updated, but all others will. This lets us find all possible values
  // for a dropdown given all the other filters.
  query (_params, _fieldName) {
    const params = jQuery.extend({}, _params) // clone
    if (_fieldName) {
      this.setState({ [`waitingFor_${_fieldName}`]: true })
      params.load_only = _fieldName
    }

    if (_fieldName) {
      // we remove the value of each field from the filter query for that
      // dropdown, as we want to know all possible values for that dropdown
      // given only the other filters
      delete params[_fieldName]
    }

    const cacheKey = JSON.stringify(params)

    const handleResponse = data => {
      queryCache[cacheKey] = data
      this.setState(prevState => {
        const hits = data.hits
        const totals = data.totals
        const newState = {}
        if (totals) {
          newState.stats = {
            cohorts: totals.cohorts,
            teachers: totals.teachers,
            runnables: totals.runnables,
            classes: totals.classes
          }
        }
        if (hits.classes) {
          newState.classes = hits.classes
        } else {
          newState.filterables = { ...prevState.filterables }
          newState.filterables[_fieldName] = hits[_fieldName]
          newState[`waitingFor_${_fieldName}`] = false
        }
        return newState
      })

      return data
    }

    if ((queryCache[cacheKey] != null ? queryCache[cacheKey].then : undefined)) { // already made a Promise that is still pending
      queryCache[cacheKey].then(handleResponse) // chain a new Then
    } else if (queryCache[cacheKey]) { // have data that has already returned
      handleResponse(queryCache[cacheKey]) // use it directly
    } else {
      queryCache[cacheKey] = jQuery.ajax({ // make req and add new Promise to cache
        url: '/api/v1/research_classes',
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
    if (this.noFilterSelected()) {
      // Avoid making biggest query possibly and instead reset everything. Once user selects a filter, we will make
      // the query to fill this first dropdown.
      this.setState({
        classes: [],
        stats: null,
        filterables: {
          teachers: [],
          cohorts: [],
          runnables: []
        }
      })
      return
    }
    const params = this.getQueryParams()
    this.query(params)
    this.query(params, 'teachers')
    this.query(params, 'cohorts')
    this.query(params, 'runnables')
  }

  renderInput (name, titleOverride) {
    if (!this.state.filterables[name]) { return }

    const hits = this.state.filterables[name]

    const isLoading = this.state[`waitingFor_${name}`]
    const placeholder = !isLoading ? 'Select or search...' : 'Loading ...'

    const options = hits.map(hit => {
      return { value: hit.id, label: hit.label }
    })

    const handleSelectChange = value => {
      this.setState({ [name]: value || [] }, () => {
        this.updateFilters()
      })
    }

    const handleLoadAll = () => {
      if (this.noFilterSelected()) {
        this.query({ load_only: name, remove_cc_teachers: this.state.removeCCTeachers, project_id: this.props.projectId }, name)
      }
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <span>{`${titleOverride || title(name)}`}</span>
        <Select
          name={name}
          options={options}
          isMulti
          placeholder={placeholder}
          isLoading={isLoading}
          value={this.state[name]}
          onMenuOpen={handleLoadAll}
          onChange={handleSelectChange}
          maxMenuHeight={200}
        />
      </div>
    )
  }

  renderForm () {
    const handleRemoveCCTeachers = e => {
      this.setState({ removeCCTeachers: e.target.checked }, () => {
        this.updateFilters()
      })
    }

    return (
      <form method='get'>
        {this.renderInput('cohorts')}
        {this.renderInput('teachers')}
        <div>
          <input type='checkbox' checked={this.state.removeCCTeachers} onChange={handleRemoveCCTeachers} /> Remove Concord Consortium Teachers? *
        </div>
        <div style={{ fontSize: '0.8em' }}>
          * Concord Consortium Teachers belong to schools named "Concord Consortium".
        </div>
        {this.renderInput('runnables', 'Resources')}
      </form>
    )
  }

  // Render summary of the filters that lists all of the filter counts.
  renderSummary () {
    if (!this.state.stats) {
      return null
    }
    const { cohorts, teachers, runnables, classes } = this.state.stats

    // Use the pluralize function for each filterable entity
    const cohortsCount = pluralize(cohorts, 'cohort', 'cohorts')
    const teachersCount = pluralize(teachers, 'teacher', 'teachers')
    const resourcesCount = pluralize(runnables, 'resource', 'resources')
    const classesCount = pluralize(classes, 'class', 'classes')

    const handleResetAllFilters = () => {
      this.setState({
        teachers: [],
        cohorts: [],
        runnables: []
      }, () => {
        this.updateFilters()
      })
    }

    return (
      <div className={css.summary}>
        <div>Your filter matches: {cohortsCount}, {teachersCount}, {resourcesCount}, {classesCount}.</div>
        <button onClick={handleResetAllFilters}>Reset All</button>
      </div>
    )
  }

  render () {
    const classes = this.state.classes

    return (
      <div className={css.researcherClassesForm}>
        {this.renderForm()}
        <div className={css.bottom}>
          {this.renderSummary()}
          {
            classes.length > 0 &&
            <ResearcherClassesTable classes={classes} />
          }
        </div>
      </div>
    )
  }
}

ResearcherClassesForm.defaultProps = {
  projectId: ''
}
