import React from 'react'

import MBMaterial from './material'

export default class MBMaterialsCollection extends React.Component {
  renderTeacherGuide () {
    if (Portal.currentUser.isTeacher && (this.props.teacherGuideUrl != null)) {
      return <a href={this.props.teacherGuideUrl} target='_blank'>Teacher Guide</a>
    }
  }

  render () {
    return (
      <div className='mb-collection'>
        <div className='mb-collection-name'>{this.props.name}</div>
        {this.renderTeacherGuide()}
        {(this.props.materials || []).map((material) =>
          <MBMaterial
            key={`${material.class_name}${material.id}`}
            material={material}
            archive={this.props.archive}
            assignToSpecificClass={this.props.assignToSpecificClass}
          />)}
      </div>
    )
  }
}
