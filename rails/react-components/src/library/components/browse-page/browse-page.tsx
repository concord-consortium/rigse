import React from "react";
import Component from "../../helpers/component";
import RelatedResourceResult from "../related-resource-result";
import portalObjectHelpers from "../../helpers/portal-object-helpers";
import { MakeTeacherEditionLink } from "../../helpers/make-teacher-edition-links";
import ResourceRequirements from "./resource-requirements";
import ResourceLicense from "./resource-license";
import ResourceProjects from "./resource-projects";
import StemFinderResultStandards from "../stem-finder-result-standards";
import SubjectAreas from "../subject-areas";
import GradeLevels from "../grade-levels";

import css from "./style.scss";

const BrowsePage = Component({
  getInitialState () {
    return {
      resource: this.props.resource
    };
  },

  UNSAFE_componentWillMount () {
    const resource = this.props.resource;
    // If the page is shown directly the resource might not have been
    // processed yet
    portalObjectHelpers.processResource(resource);

    this.setState({
      openAssign: false
    });
  },

  componentDidMount () {
    if (this.state.openAssign) {
      jQuery("#assign-button")[0].click();
    }
  },

  handlePreviewClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Browse Page - Resource Preview Button",
      "resource": resource.name
    });
  },

  handleTeacherEditionClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Browse Page - Resource Teacher Edition Button",
      "resource": resource.name
    });
  },

  handleTeacherResourcesClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "browse page - resource teacher resources button",
      "resource": resource.name
    });
  },

  handleAssignClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Browse Page - Assign to Class Button",
      "resource": resource.name
    });
  },

  handleTeacherGuideClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Browse Page - Teacher Guide Link",
      "resource": resource.name
    });
  },

  handleRubricDocClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Browse Page - Rubric Doc Link",
      "resource": resource.name
    });
  },

  handleAddToCollectionClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Browse Page - Add to Collection Button",
      "resource": resource.name
    });
  },

  handleSocialMediaShare (e: any) {
    const jQueryWindow = jQuery(window);
    e.preventDefault();
    const width = 575;
    const height = 400;
    const left = ((jQueryWindow.width() ?? 0) - width) / 2;
    const top = ((jQueryWindow.height() ?? 0) - height) / 2;
    const url = e.target.href;
    const opts = "status=1" +
      ",width=" + width +
      ",height=" + height +
      ",top=" + top +
      ",left=" + left;
    window.open(url, "social-media-share", opts);
    gtag("event", "click", {
      "category": "Browse Page - Resource ",
      "resource": this.props.resource.name
    });
  },

  renderIncludedActivities () {
    const resource = this.state.resource;
    if (resource.activities.length === 0) {
      return null;
    }
    const activities = resource.activities;

    const includedActivities = activities.map(function (activity: any, index: number) {
      return (
        <span key={index}>
          <em>
            { activity.name }
          </em>
          { index === activities.length - 1 ? "." : "; " }
        </span>
      );
    });

    return (
      <div className="portal-pages-resource-lightbox-included-activities">
        <hr />
        <h2>Included Activities</h2>
        <div>
          This sequence includes the following activities: { includedActivities }
        </div>
      </div>
    );
  },

  renderRelatedContent () {
    const resource = this.state.resource;
    if (resource.related_materials.length === 0) {
      return null;
    }

    const relatedResources = resource.related_materials.map((_resource: any, i: any) => {
      if (i < 2) {
        return RelatedResourceResult({ key: i, resource: _resource, replaceResource: this.replaceResource });
      }
    });

    return (
      <div className="portal-pages-resource-lightbox-related-content cols">
        <h2>You may also like:</h2>
        { relatedResources }
      </div>
    );
  },

  renderSharing () {
    const resource = this.state.resource;
    const resourceUrl = window.location.href;
    const facebookLink = "https://www.facebook.com/sharer/sharer.php?u=" + resourceUrl;
    const twitterLink = "http://twitter.com/share?text=" + resource.name + "&url=" + resourceUrl;
    const emailLink = "mailto:?subject=" + resource.name + "&body=" + resourceUrl;

    if (!resource.enable_sharing) {
      return null;
    }

    return (
      <div className={css.resourceSharing}>
        <a className={css.resourceSharingFacebook} href={facebookLink} target="_blank" onClick={this.handleSocialMediaShare} rel="noreferrer">Facebook</a>
        <a className={css.resourceSharingTwitter} href={twitterLink} target="_blank" onClick={this.handleSocialMediaShare} rel="noreferrer">Twitter</a>
        <a className={css.resourceSharingEmail} href={emailLink} target="_blank" onClick={this.handleSocialMediaShare} rel="noreferrer">Email</a>
      </div>
    );
  },

  render404 () {
    return (
      <div className="portal-pages-resource-lightbox-modal-content">
        <div className="portal-pages-resource-lightbox-not-found">
          Sorry, the requested resource was not found.
        </div>
        <div>
          <a id="portal-pages-lightbox-close-not-found" href="#" onClick={this.handleClose}>Click here</a> to close this lightbox and use the search box on this page to find another resource.
        </div>
      </div>
    );
  },

  renderAssignableLinks () {
    const resource = this.state.resource;
    const links = resource.links;
    const isCollection = resource.material_type === "Collection";

    const editLink = resource.lara_activity_or_sequence && links.external_lara_edit
      ? links.external_lara_edit.url
      : links.external_edit
        ? links.external_edit.url
        : null;

    // only allow admin links for collections
    if (isCollection) {
      return (
        <>
          { links.external_copy ? <a className="portal-pages-secondary-button" href={links.external_copy.url}>Copy</a> : null }
          { editLink ? <a className="portal-pages-secondary-button" href={editLink}>Edit</a> : null }
          { links.edit ? <a className="portal-pages-secondary-button" href={links.edit.url}>Settings</a> : null }
        </>
      );
    }

    return (
      <>
        { links.assign_material ? <a id={"assign-button"} className="portal-pages-secondary-button" href={`javascript: ${links.assign_material.onclick}`} onClick={this.handleAssignClick}>{ links.assign_material.text }</a> : null }
        { Portal.currentUser.isTeacher && resource.has_teacher_edition ? <a className="teacherEditionLink portal-pages-secondary-button" href={MakeTeacherEditionLink(resource.external_url)} target="_blank" onClick={this.handleTeacherEditionClick} rel="noreferrer">Teacher Edition</a> : null }
        { links.rubric_doc ? <a className="portal-pages-secondary-button" href={links.rubric_doc.url} target="_blank" onClick={this.handleRubricDocClick} rel="noreferrer">{ links.rubric_doc.text }</a> : null }
        { links.teacher_resources ? <a className="teacherResourcesLink portal-pages-secondary-button" href={links.teacher_resources.url} target="_blank" onClick={this.handleTeacherResourcesClick} rel="noreferrer">{ links.teacher_resources.text }</a> : null }
        { links.assign_collection ? <a className="portal-pages-secondary-button" href={`${links.assign_collection.url}`} onClick={this.handleAddToCollectionClick} target="_blank" rel="noreferrer">{ links.assign_collection.text }</a> : null }
        { links.teacher_guide ? <a className="portal-pages-secondary-button" href={links.teacher_guide.url} target="_blank" onClick={this.handleTeacherGuideClick} rel="noreferrer">{ links.teacher_guide.text }</a> : null }
        { links.print_url ? <a className="portal-pages-secondary-button" href={links.print_url.url}>Print</a> : null }
        { links.external_copy ? <a className="portal-pages-secondary-button" href={links.external_copy.url}>Copy</a> : null }
        { editLink ? <a className="portal-pages-secondary-button" href={editLink}>Edit</a> : null }
        { links.edit ? <a className="portal-pages-secondary-button" href={links.edit.url}>Settings</a> : null }
      </>
    );
  },

  renderStandards () {
    const resource = this.state.resource;
    if (!resource.standard_statements || resource.standard_statements.length === 0) {
      return null;
    }

    return (
      <div className="portal-pages-resource-lightbox-standards">
        <hr />
        <h2>Standards</h2>
        <StemFinderResultStandards standardStatements={resource.standard_statements} />
      </div>
    );
  },

  longDescription () {
    const resource = this.state.resource;
    return { __html: resource.longDescription };
  },

  renderResource () {
    const resource = this.state.resource;
    const links = resource.links;
    const previewLink = links.preview ? <a className="portal-pages-primary-button" href={links.preview.url} target="_blank" onClick={this.handlePreviewClick} rel="noreferrer">{ links.preview.text }</a> : null;
    const prePostTestAvailable = resource.has_pretest ? <p className="portal-pages-resource-lightbox-description">Pre- and Post-tests available</p> : null;
    const savesStudentData = resource.saves_student_data === false ? <div className="portal-pages-resource-lightbox-no-save-warning"><strong>PLEASE NOTE:</strong> This resource can be assigned, but student responses will not be saved.</div> : null;

    return (
      <>
        <div className={css.resourceInfo}>
          <div className={css.resourcePrimaryInfo}>
            <h1>{ resource.name }</h1>
            <p className="portal-pages-resource-lightbox-description" dangerouslySetInnerHTML={this.longDescription()} />
            <div className="portal-pages-action-buttons">
              { previewLink }
              { this.renderAssignableLinks() }
            </div>
            { prePostTestAvailable }
            { savesStudentData }
            { this.renderIncludedActivities() }
            <ResourceRequirements materialProperties={resource.material_properties} sensors={resource.sensors} />
            { this.renderStandards() }
            <ResourceLicense resourceName={resource.name} license={resource.license} credits={resource.cerdits} />
          </div>
          <div className={css.resourceSecondaryInfo}>
            {
              resource.icon.url &&
              <div className={css.resourcePreviewImage}>
                <img src={resource.icon.url} alt={resource.name} />
              </div>
            }
            {
              resource.subject_areas.length !== 0 &&
              <div className={css.resourceMetadataGroup}>
                <h2>Subject Areas</h2>
                <SubjectAreas subjectAreas={resource.subject_areas} />
              </div>
            }
            {
              resource.grade_levels.length !== 0 &&
              <div className={css.resourceMetadataGroup}>
                <h2>Grade Levels</h2>
                <GradeLevels resource={resource} />
              </div>
            }
            <ResourceProjects projects={resource.projects} />
          </div>
        </div>
        { this.renderRelatedContent() }
      </>
    );
  },

  render () {
    const resource = this.state.resource;
    return (
      <>
        { resource ? this.renderResource() : this.render404() }
        { resource ? this.renderSharing() : null }
      </>
    );
  }
});

export default BrowsePage;
