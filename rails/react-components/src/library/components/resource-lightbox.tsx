import React from "react";
import Component from "../helpers/component";
import RelatedResourceResult from "./related-resource-result";
import portalObjectHelpers from "../helpers/portal-object-helpers";
import StandardsHelpers from "../helpers/standards-helpers";
import { MakeTeacherEditionLink } from "../helpers/make-teacher-edition-links";
import ParseQueryString from "../helpers/parse-query-string";
import ResourceRequirements from "./browse-page/resource-requirements";
import ResourceLicense from "./browse-page/resource-license";
import ResourceProjects from "./browse-page/resource-projects";

const ResourceLightbox = Component({
  getInitialState () {
    const params = ParseQueryString();
    // The parentPage is used to change the URL when the lightbox is closed.
    // If there is a URL parameter with a parentPage it will override any other value.
    // The lightbox may be opened automatically by the portal, in which case a parentPage property will be set.
    // Or if the lightbox is opened from a collection page the parentPage property will be set from that code.
    // If the parentPage value is not '/' it will be added to the URL. So if the page is reloaded, this parentPage is remembered.
    let parentPage = this.props.parentPage || "/";
    if (params.parentPage) {
      parentPage = params.parentPage;
    }

    // The savedTitle is used to reset the page title when the lightbox is closed.
    // The portal will set PortalComponents.settings.savedTitle to be the portal's main title when it automatically opens a lightbox from a URL for the resource that was loaded.
    // When the parent page is a collection page, we force a browser reload when closing the lightbox. So in that case, the savedTitle is ignored.
    return {
      parentPage,
      savedTitle: PortalComponents.settings.savedTitle || document.title,
      resource: this.props.resource
    };
  },

  getDefaultProps () {
    return {
      showTeacherResourcesButton: true
    };
  },

  UNSAFE_componentWillMount () {
    jQuery("html, body").css("overflow", "hidden");
    jQuery(".home-page-content").addClass("blurred");

    const resource = this.props.resource;
    // If the lightbox is shown directly the resource might not have been
    // processed yet
    portalObjectHelpers.processResource(resource);

    this.titleSuffix = document.title.split("|")[1] || "";
    this.setState({
      openAssign: false
    });
    this.replaceResource(resource);
  },

  componentDidMount () {
    if (this.state.openAssign) {
      jQuery("#assign-button")[0].click();
    }
    jQuery(".portal-pages-resource-lightbox-background, .portal-pages-resource-lightbox-container").fadeIn();
  },

  componentWillUnmount () {
    document.title = this.state.savedTitle;
    try {
      // When the parentPage is not / and it doesn't match the initiaPath then
      // reload the page. This can happen when a resource URL is opened directly.
      // The parentPage URL parameter can be set to be a collection page but the
      // initialPath will be the direct resource URL. If the lightbox was opened
      // from a collection page, the initialPath will be the collection page and
      // the parentPage will be the collection page, so then we can just update
      // the URL and close the lightbox.
      if (this.state.parentPage !== "/" && this.state.parentPage !== PortalComponents.initialPath) {
        jQuery(".landing-container").css("opacity", 0);
        window.location.href = this.state.parentPage;
      } else {
        window.history.replaceState({}, document.title, this.state.parentPage);
        jQuery("html, body").css("overflow", "auto");
        jQuery(".home-page-content").removeClass("blurred");
        // FIXME: Not sure if this is going to work because the component will be removed
        jQuery(".portal-pages-resource-lightbox-background, .portal-pages-resource-lightbox-container").fadeOut();
      }
    } catch (e) {
      // noop
    }
  },

  replaceResource (resource: any) {
    const params = ParseQueryString();
    const openAssign = params.openAssign;

    if (!resource) {
      return;
    }

    document.title = this.titleSuffix ? resource.name + " | " + this.titleSuffix : resource.name;
    try {
      let parentPageSuffix = "";
      if (this.state.parentPage !== "/") {
        parentPageSuffix = "?parentPage=" + this.state.parentPage;
      }
      window.history.replaceState({}, document.title, resource.stem_resource_url + parentPageSuffix);
    } catch (e) {
      // noop
    }
    this.setState({
      resource,
      openAssign
    });
  },

  handlePreviewClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Resource Preview Button",
      "resource": resource.name
    });
  },

  handleTeacherEditionClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Resource Teacher Edition Button",
      "resource": resource.name
    });
  },

  handleTeacherResourcesClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Resource Teacher Resources Button",
      "resource": resource.name
    });
  },

  handleAssignClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Assign to Class Button",
      "resource": resource.name
    });
  },

  handleTeacherGuideClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Teacher Guide Link",
      "resource": resource.name
    });
  },

  handleRubricDocClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Rubric Doc Link",
      "resource": resource.name
    });
  },

  handleAddToCollectionClick (e: any) {
    const resource = this.state.resource;
    gtag("event", "click", {
      "category": "Add to Collection Button",
      "resource": resource.name
    });
  },

  handleClose (e: any) {
    if (jQuery(e.target).is(".portal-pages-resource-lightbox") ||
      jQuery(e.target).is(".portal-pages-resource-lightbox-background-close")) {
      // only close lightbox if lightbox wrapper or X is clicked
      this.props.toggleLightbox(e);
      return;
    }

    //
    // Handle closing lightbox from "not found" view.
    //
    if (e.target.id === "portal-pages-lightbox-close-not-found") {
      this.props.toggleLightbox(e);
      e.preventDefault();
    }
  },

  handleSocialMediaShare (e: any) {
    e.preventDefault();
    const width = 575;
    const height = 400;
    const left = ((jQuery(window).width() ?? 0) - width) / 2;
    const top = ((jQuery(window).height() ?? 0) - height) / 2;
    const url = e.target.href;
    const opts = "status=1" +
      ",width=" + width +
      ",height=" + height +
      ",top=" + top +
      ",left=" + left;
    window.open(url, "social-media-share", opts);
    gtag("event", "click", {
      "category": "Resource Lightbox " + e.target.text + " Button",
      "resource": this.props.resource.name
    });
  },

  renderIncludedActivities () {
    const resource = this.state.resource;
    if (resource.activities.length === 0) {
      return null;
    }
    const activities = resource.activities;

    const includedActivities = activities.map(function (activity: any, index: any) {
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

  renderStandards () {
    const resource = this.state.resource;
    if (!resource.standard_statements || resource.standard_statements.length === 0) {
      return null;
    }

    const allStatements = resource.standard_statements;
    const helpers: any = {};
    const unhelped = [];

    helpers.NGSS = StandardsHelpers.getStandardsHelper("NGSS");

    for (let i = 0; i < allStatements.length; i++) {
      const statement = allStatements[i];
      const helper = helpers[statement.type];

      if (helper) {
        helper.add(statement);
      } else {
        unhelped.push(statement);
      }
    }

    const unhelpedStandards = unhelped.map(function (statement, idx) {
      let description = statement.description;
      if (Array.isArray(description)) {
        let formatted = "";
        for (let i = 0; i < description.length; i++) {
          if (description[i].endsWith(":")) {
            description[i] += " ";
          } else if (!description[i].endsWith(".")) {
            description[i] += ". ";
          }
          formatted += description[i];
        }
        description = formatted;
      }
      return (
        <div key={idx}>
          <h3>{ statement.notation }</h3>
          { description }
        </div>
      );
    });

    return (
      <div className="portal-pages-resource-lightbox-standards">
        <hr />
        <h2>Standards</h2>
        { helpers.NGSS.getDiv() }
        { unhelpedStandards }
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

  //
  // TODO: add links
  //
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
      <div className="portal-pages-resource-lightbox-modal-sharing">
        <a className="share-facebook" href={facebookLink} target="_blank" onClick={this.handleSocialMediaShare} rel="noreferrer">Facebook</a>
        <a className="share-twitter" href={twitterLink} target="_blank" onClick={this.handleSocialMediaShare} rel="noreferrer">Twitter</a>
        <a className="share-email" href={emailLink} target="_blank" onClick={this.handleSocialMediaShare} rel="noreferrer">Email</a>
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

  renderIcons () {
    const resource = this.state.resource;
    const links = resource.links;

    const makeIcon = (type: any, link: any) => link ? <a className={type} href={type === "settings" ? link.url : link}>{ type }</a> : null;
    // let printIcon = makeIcon('print', links.print_url);
    const copyIcon = makeIcon("copy", links.external_copy);
    const settingsIcon = makeIcon("settings", links.edit);
    let editLink = null;
    if (resource.lara_activity_or_sequence && links.external_lara_edit) {
      editLink = links.external_lara_edit.url;
    } else if (links.external_edit) {
      editLink = links.external_edit.url;
    }

    const editIcon = editLink ? <a className="edit" href={editLink}>edit</a> : null;
    const icons = [copyIcon, editIcon, settingsIcon];
    let iconIndex = 0;
    const iconsListItems = icons.map((icon) => {
      return icon !== null ? <li key={"utility-icon-" + iconIndex++}>{ icon }</li> : null;
    });

    if (copyIcon || editIcon || settingsIcon) {
      return (
        <ul>{ iconsListItems }</ul>
      );
    } else {
      return null;
    }
  },

  renderAdditionalInfo () {
    const resource = this.state.resource;
    return (
      <div>
        <ResourceRequirements materialProperties={resource.material_properties} sensors={resource.sensors} />
        { this.renderStandards() }
        <ResourceLicense resourceName={resource.name} license={resource.license} credits={resource.cerdits} />
        <ResourceProjects projects={resource.projects} />
      </div>
    );
  },

  renderAssignableLinks () {
    const resource = this.state.resource;
    const showTeacherResourcesButton = this.props.showTeacherResourcesButton;
    const links = resource.links;
    const isCollection = resource.material_type === "Collection";

    // no assignable links for collections
    if (isCollection) {
      return null;
    }

    return (
      <span>
        { Portal.currentUser.isTeacher && resource.has_teacher_edition ? <a className="teacherEditionLink portal-pages-secondary-button" href={MakeTeacherEditionLink(resource.external_url)} target="_blank" onClick={this.handleTeacherEditionClick} rel="noreferrer">Teacher Edition</a> : null }
        { links.rubric_doc ? <a className="portal-pages-secondary-button" href={links.rubric_doc.url} target="_blank" onClick={this.handleRubricDocClick} rel="noreferrer">{ links.rubric_doc.text }</a> : null }
        { links.teacher_resources && showTeacherResourcesButton ? <a className="teacherResourcesLink portal-pages-secondary-button" href={links.teacher_resources.url} target="_blank" onClick={this.handleTeacherResourcesClick} rel="noreferrer">{ links.teacher_resources.text }</a> : null }
        { links.assign_material ? <a id={"assign-button"} className="portal-pages-secondary-button" href={`javascript: ${links.assign_material.onclick}`} onClick={this.handleAssignClick}>{ links.assign_material.text }</a> : null }
        { links.assign_collection ? <a className="portal-pages-secondary-button" href={`${links.assign_collection.url}`} onClick={this.handleAddToCollectionClick} target="_blank" rel="noreferrer">{ links.assign_collection.text }</a> : null }
        { links.teacher_guide ? <a className="portal-pages-secondary-button" href={links.teacher_guide.url} target="_blank" onClick={this.handleTeacherGuideClick} rel="noreferrer">{ links.teacher_guide.text }</a> : null }
      </span>
    );
  },

  longDescription () {
    const resource = this.state.resource;
    return { __html: resource.longDescription };
  },

  renderResource () {
    const resource = this.state.resource;
    const links = resource.links;
    const isCollection = resource.material_type === "Collection";
    const previewButtonText = isCollection ? "View Collection" : links.preview.text;

    return (
      <div className="portal-pages-resource-lightbox-modal-content">
        <div className="portal-pages-resource-lightbox-modal-content-top">
          <div className="portal-pages-resource-lightbox-modal-utility">
            { this.renderIcons() }
          </div>
          <h1>{ resource.name }</h1>
          <div className="preview-image">
            <img src={resource.icon.url} />
          </div>
          <div className="portal-pages-action-buttons">
            { links.preview ? <a className="portal-pages-primary-button" href={links.preview.url} target="_blank" onClick={this.handlePreviewClick} rel="noreferrer">{ previewButtonText }</a> : null }
            { !isCollection && this.renderAssignableLinks() }
          </div>
          <p className="portal-pages-resource-lightbox-description" dangerouslySetInnerHTML={this.longDescription()} />
          { resource.has_pretest ? <p className="portal-pages-resource-lightbox-description">Pre- and Post-tests available</p> : null }
          { resource.saves_student_data === false ? <div className="portal-pages-resource-lightbox-no-save-warning"><strong>PLEASE NOTE:</strong> This resource can be assigned, but student responses will not be saved.</div> : null }
          { this.renderIncludedActivities() }
          <hr />
          { !isCollection && this.renderAdditionalInfo() }
        </div>
        { !isCollection && this.renderRelatedContent() }
      </div>
    );
  },

  render () {
    const resource = this.state.resource;

    return (
      <div>
        <div className="portal-pages-resource-lightbox-background" />
        <div className="portal-pages-resource-lightbox-container">
          <div className="portal-pages-resource-lightbox" onClick={this.handleClose}>
            <div className="portal-pages-resource-lightbox-background-close" onClick={this.handleClose}>
              x
            </div>
            <div className="portal-pages-resource-lightbox-modal">
              { resource ? this.renderResource() : this.render404() }
            </div>
            { resource ? this.renderSharing() : null }
          </div>
        </div>
      </div>
    );
  }
});

export default ResourceLightbox;
