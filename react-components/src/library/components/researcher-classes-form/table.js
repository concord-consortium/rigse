import React from 'react'
import 'react-day-picker/lib/style.css'
import css from './style.scss'

export default class ResearcherClassesTable extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      sortedClasses: props.classes,
      // Default sort by id in descending order - this will show the most recent classes first
      sortBy: 'id',
      sortDirection: 'desc'
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

  render () {
    const { sortedClasses } = this.state
    if (sortedClasses.length === 0) {
      return null
    }
    return (
      <div className={css.researcherClassesTable}>
        <hr />
        <div className={css.resultsLabel}>Results</div>

        <table>
          <thead>
            <tr>
              <th onClick={this.handleHeaderClick.bind(this, 'cohort_names')}>
                <span className={css.header}>
                  Cohort <span className={`${css.sortIcon} ${this.fieldSortIcon('cohort_names')} icon-sort`} />
                </span>
              </th>
              <th onClick={this.handleHeaderClick.bind(this, 'teacher_names')}>
                <span className={css.header}>
                  Teacher <span className={`${css.sortIcon} ${this.fieldSortIcon('teacher_names')} icon-sort`} />
                </span>
              </th>
              <th onClick={this.handleHeaderClick.bind(this, 'name')}>
                <span className={css.header}>
                  Class <span className={`${css.sortIcon} ${this.fieldSortIcon('name')} icon-sort`} />
                </span>
              </th>
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
                  <td><a href={c.class_url} target='_blank'>View Class</a></td>
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
