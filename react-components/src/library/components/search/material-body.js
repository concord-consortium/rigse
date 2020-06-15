import React from 'react'

export default class SMaterialBody extends React.Component {
  renderMaterialUsage () {
    const classCount = this.props.material.class_count
    if (classCount != null) {
      const usage = classCount === 0
        ? 'Not used in any class.'
        : (classCount === 1 ? 'Used in 1 class.' : `Used in ${classCount} classes.`)
      return (
        <div>
          <i>
            {usage}
          </i>
        </div>
      )
    }
  }

  renderRequiredSensors () {
    const { sensors } = this.props.material
    if ((sensors != null) && (sensors.length > 0)) {
      return (
        <div className='required_equipment_container'>
          <span>Required sensor(s):</span>
          <span style={{ fontWeight: 'bold' }}>{sensors.join(', ')}</span>
        </div>
      )
    }
  }

  render () {
    return (
      <div className='material_body'>
        {this.renderMaterialUsage()}
        {this.renderRequiredSensors()}
      </div>
    )
  }
}
