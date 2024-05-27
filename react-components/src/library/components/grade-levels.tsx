import React from 'react'
import Component from '../helpers/component'
import filters from '../helpers/filters'

import css from './grade-levels.scss'

const GradeLevels = Component({

  render: function () {
    const resource = this.props.resource
    const levels = filters.gradeFilters.reduce(function (levelAcc: any, gradeFilter: any) {
      const matching = gradeFilter.grades.reduce(function (matchingAcc: any, grade: any) {
        if (resource.grade_levels && resource.grade_levels.indexOf(grade) !== -1) {
          matchingAcc.push(grade)
        }
        return matchingAcc
      }, [])
      if (matching.length > 0) {
        levelAcc.push(gradeFilter.label)
      }
      return levelAcc
    }, [])

    if (levels.length === 0) {
      return null
    }

    return (
      <div className={this.props.className || css.finderResultGradeLevels}>
        {levels.map((level: any, index: any) => {
          if (level === 'Higher Education') {
            level = 'Higher Ed'
          }
          return <div key={`gradeLevel-${index}`} className={css.finderResultGradeLevel}>{level}</div>
        })}
      </div>
    );
  }
})

export default GradeLevels
