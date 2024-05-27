import React from 'react'
import Component from '../helpers/component'
import filters from '../helpers/filters'

import css from './subject-areas.scss'

const SubjectAreas = Component({

  render: function () {
    const resourceSubjectAreas = this.props.subjectAreas

    let subjectAreas: any = []
    filters.subjectAreas.forEach((subjectArea: any) => {
      subjectArea.searchAreas.forEach((searchArea: any) => {
        if (resourceSubjectAreas.indexOf(searchArea) !== -1) {
          subjectAreas.push(subjectArea.title)
        }
      })
    })

    return (
      <div className={this.props.className || css.finderResultSubjectAreas}>
        {subjectAreas.map((subject: any, index: any) => {
          return <div key={`subjectArea-${index}`} className={css.finderResultSubjectArea}>{subject}</div>
        })}
      </div>
    );
  }
})

export default SubjectAreas
