import React from 'react'
import MBMaterial from './material'

export default class MBMaterialsCollection extends React.Component<any, any> {
  componentDidMount () {
    // @ts-expect-error TS(2531): Object is possibly 'null'.
    const isAssignWrapped = window.self !== window.top && window.self.location.hostname === window.top.location.hostname
    if (isAssignWrapped) {
      // @ts-expect-error TS(2531): Object is possibly 'null'.
      window.parent.document.getElementById('collectionIframe').style.height = document.body.scrollHeight + 'px'
      // @ts-expect-error TS(2531): Object is possibly 'null'.
      window.parent.document.getElementById('collectionIframe').style.visibility = 'visible'
      // @ts-expect-error TS(2531): Object is possibly 'null'.
      window.parent.document.getElementById('collectionIframeLoading').style.display = 'none'
    }
  }

  renderTeacherGuide () {
    if (Portal.currentUser.isTeacher && (this.props.teacherGuideUrl != null)) {
      return <a href={this.props.teacherGuideUrl} target='_blank'>Teacher Guide</a>
    }
  }

  render () {
    return (
      <section className='mb-collection'>
        <header>
          <h3 className='mb-collection-name'>{this.props.name}</h3>
          {this.renderTeacherGuide()}
        </header>

        {(this.props.materials || []).map((material: any) => <MBMaterial
          key={`${material.class_name}${material.id}`}
          material={material}
          archive={this.props.archive}
          assignToSpecificClass={this.props.assignToSpecificClass}
        />)}
      </section>
    );
  }
}
