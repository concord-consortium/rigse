import React from 'react'
import Component from '../helpers/component'
import StandardsHelpers from '../helpers/standards-helpers'

const StemFinderResultStandards = Component({

  shouldComponentUpdate: function () {
    return false
  },

  render: function () {
    const { standardStatements } = this.props
    let helpers = {}
    let unhelped = []

    helpers.NGSS = StandardsHelpers.getStandardsHelper('NGSS')

    for (let i = 0; i < standardStatements.length; i++) {
      let statement = standardStatements[i]
      let helper = helpers[statement.type]

      if (helper) {
        helper.add(statement)
      } else {
        unhelped.push(statement)
      }
    }

    const unhelpedStandards = unhelped.map(function (statement) {
      let description = statement.description
      if (Array.isArray && Array.isArray(description)) {
        let formatted = ''
        for (let i = 0; i < description.length; i++) {
          if (description[i].endsWith(':')) {
            description[i] += ' '
          } else if (!description[i].endsWith('.')) {
            description[i] += '. '
          }
          formatted += description[i]
        }
        description = formatted
      }
      return (
        <div>
          <h3>{statement.notation}</h3>
          {description}
        </div>
      )
    })

    return (
      <>
        {helpers.NGSS.getDiv()}
        {unhelpedStandards}
      </>
    )
  }
})

export default StemFinderResultStandards
