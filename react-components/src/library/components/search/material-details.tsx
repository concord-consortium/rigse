import React from 'react'

export default class SMaterialDetails extends React.Component {
  constructor (props) {
    super(props)
    this.toggle = this.toggle.bind(this)
    this.toggleFromChild = this.toggleFromChild.bind(this)
  }

  toggle (event) {
    window.toggleDetails(jQuery(event.target))
  }

  toggleFromChild (event) {
    window.toggleDetails(jQuery(event.target.parentElement))
  }

  hasActivitiesOrPretest () {
    return this.props.material.has_activities || this.props.material.has_pretest
  }

  getMaterialDescClass () {
    return `material-description ${this.hasActivitiesOrPretest() ? 'two-cols' : 'one-col'}`
  }

  renderActivities () {
    const activities = (this.props.material.activities || [])
    return activities.map(function (activity) {
      if (activity != null) {
        return <li key={activity.id}>{activity.name}</li>
      }
    })
  }

  render () {
    const { material } = this.props
    return (
      <div className='toggle-details' onClick={this.toggle}>
        <i className='toggle-details-icon fa fa-chevron-down' onClick={this.toggleFromChild} />
        <i className='toggle-details-icon fa fa-chevron-up' style={{ display: 'none' }} onClick={this.toggleFromChild} />
        <div className='material-details' style={{ display: 'none' }}>
          <div className={this.getMaterialDescClass()}>
            <h3>Description</h3>
            <div dangerouslySetInnerHTML={{ __html: material.short_description }} />
          </div>
          <div className='material-activities'>
            {material.has_pretest ? <h4>Pre- and Post-tests available.</h4> : undefined}
            {material.activities.length > 0
              ? <div>
                <h3>Activities</h3>
                {this.renderActivities()}
              </div> : undefined}
          </div>
        </div>
      </div>
    )
  }
}
