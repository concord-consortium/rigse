import Component from '../helpers/component'
import filters from '../helpers/filters'

import css from './subject-areas.scss'

const SubjectAreas = Component({

  render: function () {
    const resourceSubjectAreas = this.props.subjectAreas
    const subjectAreas = filters.subjectAreas.reduce(function (subjectAcc, subjectArea) {
      var matching = subjectArea.searchAreas.reduce(function (matchingAcc, subject) {
        if (resourceSubjectAreas && resourceSubjectAreas.indexOf(subject) !== -1) {
          matchingAcc.push(subject)
        }
        return matchingAcc
      }, [])
      if (matching.length > 0) {
        subjectAcc.push(subjectArea.title)
      }
      return subjectAcc
    }, [])

    if (subjectAreas.length === 0) {
      return null
    }

    return (
      <div className={this.props.className || css.finderResultSubjectAreas}>
        {subjectAreas.map((subject, index) => {
          return <div key={`subjectArea-${index}`} className={css.finderResultSubjectArea}>{subject}</div>
        })}
      </div>
    )
  }
})

export default SubjectAreas
