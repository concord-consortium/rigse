import React from 'react'
// import 'react-day-picker/style.css'
import css from './style.scss'

export default class ResearcherClassesTable extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      sortedClasses: props.classes,
      // Default sort by id in descending order - this will show the most recent classes first
      sortBy: 'id',
      sortDirection: 'desc',
      showSchoolName: false
    }
  }

  componentDidMount () {
    this.sortClasses()
  }

  componentDidUpdate (prevProps) {
    if (this.props.classes !== prevProps.classes) {
      this.sortClasses(this.props.classes)
    }
  }

  sortClasses (classesToSort = this.state.sortedClasses) {
    const fieldName = this.state.sortBy
    const direction = this.state.sortDirection
    this.setState({
      sortedClasses: classesToSort.slice().sort((a, b) => {
        // Using localeCompare for a more natural sort order
        const comparison = a[fieldName].toString().localeCompare(b[fieldName].toString(), 'en', { sensitivity: 'base' })
        return direction === 'asc' ? comparison : -comparison
      })
    })
  }

  fieldSortIcon (fieldName) {
    if (this.state.sortBy === fieldName) {
      return this.state.sortDirection === 'asc' ? css.asc : css.desc
    }
    return ''
  }

  handleHeaderClick (fieldName) {
    const direction = this.state.sortBy === fieldName && this.state.sortDirection === 'asc' ? 'desc' : 'asc'
    this.setState({
      sortBy: fieldName,
      sortDirection: direction
    }, () => this.sortClasses())
  }

  handleShowSchoolNameChange (e) {
    this.setState({ showSchoolName: e.target.checked })
  }

  renderHeader (label, fieldName) {
    return (
      <th onClick={this.handleHeaderClick.bind(this, fieldName)}>
        <span className={css.header}>
          {label} <span className={`${css.sortIcon} ${this.fieldSortIcon(fieldName)} icon-sort`} />
        </span>
      </th>
    )
  }

  render () {
    const { sortedClasses, showSchoolName } = this.state
    if (sortedClasses.length === 0) {
      return null
    }
    return (
      <div className={css.researcherClassesTable}>
        <hr />
        <div className={css.top}>
          <div className={css.resultsLabel}>Results</div>
          <span>
            <input type='checkbox' checked={showSchoolName} onChange={this.handleShowSchoolNameChange.bind(this)} /> Show School Name
          </span>
        </div>

        <table>
          <thead>
            <tr>
              { this.renderHeader('Cohort', 'cohort_names') }
              { this.renderHeader('Teacher', 'teacher_names') }
              { this.renderHeader('Class', 'name') }
              { showSchoolName && this.renderHeader('School', 'school_name') }
              <th />
            </tr>
          </thead>
          <tbody>
            {
              sortedClasses.map((c, i) => (
                <tr key={i}>
                  <td>{c.cohort_names}</td>
                  <td>{c.teacher_names}</td>
                  <td>{c.name}</td>
                  { showSchoolName && <td>{c.school_name}</td> }
                  <td className={css.linkCell}><a href={c.class_url} target='_blank'>View Class</a></td>
                </tr>
              ))
            }
          </tbody>
        </table>
      </div>
    )
  }
}

ResearcherClassesTable.defaultProps = {
  classes: []
}