import React from "react";
import ResourceFinderLightbox from "../resource-finder-lightbox";
import CollectionLightbox from "../collection-lightbox";
import Lightbox from "../../helpers/lightbox";

import css from "./style.scss";
import commonCss from "../../styles/common-css-modules.scss";

export default class ClassAssignments extends React.Component<any, any> {
  assignMaterialsRef: any;
  constructor (props: any) {
    super(props);
    this.state = {
      showAssignOptions: false,
      collectionViews: []
    };
    this.assignMaterialsRef = React.createRef();
    this.closeLightbox = this.closeLightbox.bind(this);
    this.handleExternalClick = this.handleExternalClick.bind(this);
    this.handleAssignMaterialsButtonClick = this.handleAssignMaterialsButtonClick.bind(this);
    this.handleAssignMaterialsOptionClick = this.handleAssignMaterialsOptionClick.bind(this);
    this.handleAssignButtonMouseEnter = this.handleAssignButtonMouseEnter.bind(this);
    this.handleAssignButtonMouseLeave = this.handleAssignButtonMouseLeave.bind(this);
    this.renderAssignOptions = this.renderAssignOptions.bind(this);
  }

  componentDidMount () {
    jQuery.ajax({
      url: Portal.API_V1.GET_TEACHER_PROJECT_VIEWS,
      dataType: "json",
      success: function (data: any) {
        this.setState({
          collectionViews: data
        });
      }.bind(this)
    });
    document.addEventListener("mousedown", this.handleExternalClick);
  }

  componentWillUnmount () {
    document.removeEventListener("mousedown", this.handleExternalClick);
  }

  closeLightbox (e: any) {
    this.props.handleNewAssignment();
    Lightbox.close();
  }

  handleAssignMaterialsButtonClick (e: any) {
    this.setState((prevState: any) => ({ showAssignOptions: !prevState.showAssignOptions }));
  }

  handleExternalClick (e: any) {
    if (this.assignMaterialsRef.current && !this.assignMaterialsRef.current.contains(e.target)) {
      this.setState({ showAssignOptions: false });
    }
  }

  handleAssignMaterialsOptionClick (e: any, collectionId: any) {
    if (document.getElementById("portal-pages-lightbox-mount")) {
      // @ts-expect-error TS(2554): Expected 1 arguments, but got 0.
      this.closeLightbox();
    }
    this.setState({ showAssignOptions: false });
    const lightboxOptions = collectionId === "all" || typeof collectionId === "undefined"
      ? ResourceFinderLightbox({
        closeLightbox: this.closeLightbox,
        collectionViews: this.state.collectionViews,
        handleNav: this.handleAssignMaterialsOptionClick
      })
      : CollectionLightbox({
        closeLightbox: this.closeLightbox,
        collectionId,
        collectionViews: this.state.collectionViews,
        handleNav: this.handleAssignMaterialsOptionClick
      });
    Lightbox.open(lightboxOptions);
  }

  handleAssignButtonMouseEnter (e: any) {
    this.setState({ showAssignOptions: true });
  }

  handleAssignButtonMouseLeave (e: any) {
    this.setState({ showAssignOptions: false });
  }

  renderAssignOption () {
    const { collectionViews } = this.state;
    return collectionViews.map((collection: any) => <li key={`assign-collection-${collection.id}`}><button id={`assignMaterialsCollection${collection.id}`} onClick={(e) => this.handleAssignMaterialsOptionClick(e, collection.id)}>{ collection.name } Collection</button></li>);
  }

  renderAssignOptions () {
    const { collectionViews } = this.state;
    const recentCollectionItems = collectionViews.length > 0 ? this.renderAssignOption() : null;
    return (
      <ul>
        <li><button id="assignMaterialsAllResources" onClick={(e) => this.handleAssignMaterialsOptionClick(e, "all")}>All Resources</button></li>
        { recentCollectionItems }
      </ul>
    );
  }

  renderFindMoreResources () {
    if (Portal.theme === "ngss-assessment") {
      return;
    }
    const { showAssignOptions } = this.state;
    const assignOptions = showAssignOptions ? this.renderAssignOptions() : null;
    return (
      <div className={css.assignMaterials} ref={this.assignMaterialsRef}>
        <button id="assignMaterialsMoreResources" onClick={this.handleAssignMaterialsButtonClick}>Find More Resources</button>
        { assignOptions }
      </div>
    );
  }

  get assignMaterialsPath () {
    const { clazz } = this.props;
    if (Portal.theme === "itsi-learn") {
      return `/itsi?assign_to_class=${clazz.id}`;
    }
    if (Portal.theme === "ngss-assessment") {
      return `/about`;
    }
    return clazz.assignMaterialsPath;
  }

  render () {
    const { clazz } = this.props;
    return (
      <div className={css.classAssignments}>
        <header>
          <h1>Assignments for { clazz.name }</h1>
          { this.renderFindMoreResources() }
        </header>
        <table className={css.classInfo}>
          <tbody>
            <tr>
              <td>Teacher:</td><td> { clazz.teachers }</td>
            </tr>
            <tr>
              <td>Class word:</td><td> { clazz.classWord }</td>
            </tr>
          </tbody>
        </table>
        <div className={css.reports}>
          {
            clazz.externalClassReports.map((r: any) => <a key={r.url} href={r.url} target="_blank" className={commonCss.smallButton} title={r.name} rel="noreferrer">{ r.launchText }</a>)
          }
        </div>
      </div>
    );
  }
}
