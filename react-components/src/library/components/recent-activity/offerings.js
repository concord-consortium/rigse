import React from 'react'
import Offering from './offering'
import Legend from './legend'

export default class Offerings extends React.Component {
  render () {
    const { offerings, anyData, anyStudents } = this.props
    if (!anyData) {
      return (
        <div>
          <div>You need to assign investigations to your classes.</div>
          <div>As your students get started, their progress will be displayed here.</div>
        </div>
      )
    }
    if (anyData && !anyStudents) {
      return (
        <div>
          <div>You have not yet assigned students to your classes.</div>
          <div>As your students get started, their progress will be displayed here.</div>
        </div>
      )
    }
    if (offerings.length === 0) {
      return <div>As your students get started, their progress will be displayed here.</div>
    }
    return (
      <div>
        <Legend />
        { offerings.map(offering => <Offering key={offering.id} offering={offering} />) }
      </div>
    )
  }
}
