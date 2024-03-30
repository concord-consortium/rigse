import React from 'react'
import 'react-day-picker/lib/style.css'
import css from './style.scss'

export default class ResearcherClassesTable extends React.Component {
  render () {
    const { classes } = this.props
    if (classes.length === 0) {
      return null
    }
    return (
      <div className={css.researcherClassesTable}>
        <hr />
        <div className={css.resultsLabel}>Results</div>

        <table>
          <thead>
            <tr>
              <th>Cohort</th>
              <th>Teacher</th>
              <th>Class</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {
              classes.map((c, i) => (
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
