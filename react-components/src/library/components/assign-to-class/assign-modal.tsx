import React from "react";
import ReactModal from "react-modal";

import css from "./style.scss";

export default class AssignModal extends React.Component<any, any> {
  constructor (props: any) {
    super(props);

    this.state = {
      assignedClassIds: [],
      classes: {
        assigned_classes: [],
        unassigned_classes: []
      },
      copyButtonClicked: false,
      errorMessage: null,
      resourceAssigned: false,
      showModal: false
    };

    this.assignMaterial = this.assignMaterial.bind(this);
    this.copyToClipboard = this.copyToClipboard.bind(this);
    this.updateClassList = this.updateClassList.bind(this);
    this.closeConfirmModal = this.closeConfirmModal.bind(this);
  }

  componentDidMount () {
    if (!Portal.currentUser.isAnonymous) {
      const data = {
        material_id: this.props.material_id,
        material_type: this.props.material_type
      };
      jQuery.post(Portal.API_V1.MATERIAL_UNASSIGNED_CLASSES, data).done(response => {
        this.setState({ classes: response });
      }).fail(function (err) {
        if (err?.responseText) {
          const response = jQuery.parseJSON(err.responseText);
          this.setState({ errorMessage: "There was an error: " + response.message + ". Please try again." });
        }
      });
    }
  }

  copyToClipboard (e: any) {
    e.preventDefault();
    const textItemId = "#" + css.shareUrl;
    const temp = jQuery("<input>");
    jQuery("body").append(temp);
    // @ts-expect-error TS(2345): Argument of type 'string | number | string[] | und... Remove this comment to see the full error message
    temp.val(jQuery(textItemId).val()).select();
    document.execCommand("copy");
    temp.remove();

    this.setState({ copyButtonClicked: true }, () => {
      setTimeout(() => {
        this.setState({ copyButtonClicked: false });
      }, 4000);
    });
  }

  assignMaterial () {
    const authToken = jQuery('meta[name="csrf-token"]').attr("content");

    if (this.state.assignedClassIds.length < 1) {
      this.setState({ errorMessage: "Select at least one class to assign this resource." });
    } else {
      for (const classId of this.state.assignedClassIds) {
        const params = {
          assign: 1,
          class_id: classId,
          material_id: this.props.material_id,
          material_type: this.props.material_type,
          authenticity_token: authToken
        };
        jQuery.post(Portal.API_V1.ASSIGN_MATERIAL_TO_CLASS, params)
          .done(response => {
            this.setState({ resourceAssigned: true, showModal: true });
          })
          .fail(function (err) {
            if (err?.responseText) {
              const response = jQuery.parseJSON(err.responseText);
              this.setState({ errorMessage: "There was an error: " + response.message + ". Please try again." });
            }
          });
      }
    }
  }

  noClasses () {
    const hasNoClasses = this.state.classes.unassigned_classes.length === 0 &&
                         this.state.classes.assigned_classes.length === 0;
    if (hasNoClasses) {
      return (
        <p className="messagetext">
          You don't have any active classes. Once you have created your class(es), you will be able to assign materials to them.
        </p>
      );
    }
  }

  assignedClassesList () {
    const assignedClasses = this.state.classes.assigned_classes;
    if (assignedClasses.length > 0) {
      return (
        <div>
          <div className={css.alreadyAssignedClassHeader}>Already assigned to the following class(es)</div>
          <div>
            <div className={css.classListContainer + " webkit_scrollbars"}>
              <ul>
                {
                  assignedClasses.map((ac: any) => <li key={ac.id}>{ ac.name }</li>)
                }
              </ul>
            </div>
          </div>
        </div>
      );
    }
  }

  unassignedClassesForm () {
    const unassignedClasses = this.state.classes.unassigned_classes;
    if (unassignedClasses.length > 0) {
      return (
        <form id={css.addMaterialForm}>
          <div className={css.classListContainer + " webkit_scrollbars"}>
            <ul>
              {
                unassignedClasses.map((uac: any) =>
                  <li key={uac.id}>
                    <input className="unassigned_activity_class" id={"clazz_" + uac.id} name="clazz_id[]" type="checkbox" value={uac.id} onChange={this.updateClassList} />
                    <label className="clazz_name" htmlFor={"clazz_" + uac.id}>{ uac.name }</label>
                  </li>
                )
              }
            </ul>
          </div>
        </form>
      );
    }
  }

  updateClassList (e: any) {
    this.setState((prevState: any) => {
      const assignedClassIds = prevState.assignedClassIds;
      const classId = e.target.value;
      if (e.target.checked) {
        assignedClassIds.push(classId);
      } else {
        const index = assignedClassIds.indexOf(classId);
        assignedClassIds.splice(index, 1);
      }
      return { assignedClassIds };
    });
  }

  handleRegisterClick (e: any) {
    e.preventDefault();
    PortalComponents.renderSignupModal({
      oauthProviders: Portal.oauthProviders,
      closeable: true
    });
  }

  handleLoginClick (e: any) {
    e.preventDefault();
    // @ts-expect-error TS(2345): Argument of type 'Location' is not assignable to p... Remove this comment to see the full error message
    const currentUrl = new URL(window.location);
    currentUrl.searchParams.set("openAssign", "true");
    const assignPath = currentUrl.pathname + currentUrl.search;
    PortalComponents.renderLoginModal({
      oauthProviders: Portal.oauthProviders,
      closeable: true,
      afterSigninPath: assignPath
    });
  }

  saveButton () {
    if (this.state.classes.unassigned_classes.length < 1) {
      return (
        <a className={css.button + " button"} href="/portal/classes/new">
          Create a Class
        </a>
      );
    } else {
      return (
        <a className={css.button + " button"} href="#" onClick={this.assignMaterial}>
          Save
        </a>
      );
    }
  }

  contentForAnonymous () {
    return (
      <div>
        <p>To assign this resource to classes and track student work on learn.concord.org, log in or register as a teacher.</p>
        <a className={css.button + " button"} href="/signup" onClick={this.handleRegisterClick}>Register</a>
        <a className={css.button + " button"} href="/login" onClick={this.handleLoginClick}>Log In</a>
        <button className={css.cancel} onClick={this.props.closeFunc}>Cancel</button>
      </div>
    );
  }

  contentForTeacher () {
    const errorMessageClass = this.state.errorMessage ? css.errorMessage + " " + css.visible : css.errorMessage;
    const { savesStudentData } = this.props;
    return (
      <div>
        {
          !savesStudentData &&
          <div className={css.studentDataWarning}><strong>PLEASE NOTE:</strong> This resource can be assigned, but student responses will not be saved.</div>
        }
        <p>Select the class(es) you want to assign this resource to below.</p>
        <div id="clazz_summary_data">
          <div id={css.scrollableClassSummaryData}>
            <div className={errorMessageClass}>
              { this.state.errorMessage }
            </div>
            <div className={css.assignClassHeader}>Your Classes</div>
            { this.noClasses() }
            { this.unassignedClassesForm() }
            { this.assignedClassesList() }
          </div>
          { this.saveButton() }
          <button className={css.cancel} onClick={this.props.closeFunc}>Cancel</button>
        </div>
      </div>
    );
  }

  closeConfirmModal () {
    this.setState({ showModal: false });
    this.props.closeFunc();
  }

  resourceAssigned () {
    return (
      <ReactModal ariaHideApp={false} isOpen={this.state.showModal} onRequestClose={this.props.closeFunc} className={css.confirmDialog} overlayClassName={css.confirmDialogOverlay} portalClassName={css.confirmDialogPortal}>
        <p>The { this.props.resourceType } <strong>{ this.props.resourceTitle }</strong> is assigned to the selected class(es) successfully.</p>
        <button onClick={this.closeConfirmModal}>OK</button>
      </ReactModal>
    );
  }

  render () {
    if (this.state.resourceAssigned) {
      return (
        this.resourceAssigned()
      );
    }

    return (
      <div className={css.assignModalContent}>
        <div className={css.assignShareCol} id={css.assignCol}>
          <h2>Assign<span>…</span></h2>
          { Portal.currentUser.isAnonymous ? this.contentForAnonymous() : this.contentForTeacher() }
        </div>
        <div className={css.assignShareCol} id={css.shareCol}>
          <h2><span>or</span> Share</h2>
          <p>Copy the URL below to assign this resource in your own LMS or to share with colleagues.</p>
          <form>
            { this.state.copyButtonClicked ? <div className={css.textCopiedAlert}><span>Copied to clipboard!</span></div> : null }
            <label>Shareable URL</label><br />
            <input id={css.shareUrl} type="url" defaultValue={this.props.previewUrl} />
            <button className={css.button + " button"} onClick={this.copyToClipboard}>Copy</button>
          </form>
          <p className={css.small}><strong>NOTE:</strong> Only use this option if you do not want to track student work on learn.concord.org</p>
        </div>
      </div>
    );
  }
}
