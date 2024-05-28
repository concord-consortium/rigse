import React from "react";
import MBMaterial from "./material";

export default class MBMaterialsCollection extends React.Component<any, any> {
  componentDidMount () {
    const isAssignWrapped = window.self !== window.top && window.self.location.hostname === window.top?.location.hostname;
    if (isAssignWrapped) {
      const iframe = window.parent.document.getElementById("collectionIframe");
      if (iframe) {
        iframe.style.height = document.body.scrollHeight + "px";
        iframe.style.visibility = "visible";
      }
      const iframeLoading = window.parent.document.getElementById("collectionIframeLoading");
      if (iframeLoading) {
        iframeLoading.style.display = "none";
      }
    }
  }

  renderTeacherGuide () {
    if (Portal.currentUser.isTeacher && (this.props.teacherGuideUrl != null)) {
      return <a href={this.props.teacherGuideUrl} target="_blank" rel="noreferrer">Teacher Guide</a>;
    }
  }

  render () {
    return (
      <section className="mb-collection">
        <header>
          <h3 className="mb-collection-name">{ this.props.name }</h3>
          { this.renderTeacherGuide() }
        </header>

        { (this.props.materials || []).map((material: any) => <MBMaterial
          key={`${material.class_name}${material.id}`}
          material={material}
          archive={this.props.archive}
          assignToSpecificClass={this.props.assignToSpecificClass}
        />) }
      </section>
    );
  }
}
