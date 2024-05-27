import React from "react";
import css from "./style.scss";
import Component from "../../helpers/component";

const Collaborator = Component({

  handleRemoveCollaborator () {
    this.props.handleRemoveCollaborator(this.props.collaborator);
  },

  render () {
    const c = this.props.collaborator;
    return (
      <li><i className="fa fa-trash-o control" onClick={this.handleRemoveCollaborator} />{ c.name }</li>
    );
  }
});

const RunWithCollaborators = Component({

  buttonElement: null,

  getInitialState () {
    return {
      showingDialog: false,
      selectedCollaborator: null,
      availableCollaborators: [],
      collaborators: [],
      runStarted: false
    };
  },

  UNSAFE_componentWillMount () {
    this.loadAvailableCollaborators();
  },

  loadAvailableCollaborators () {
    jQuery.ajax({
      type: "GET",
      url: Portal.API_V1.AVAILABLE_COLLABORATORS,
      data: { offering_id: this.props.offeringId },
      success: (data) => {
        this.setState({ availableCollaborators: data });
      },
      error () {
        window.alert("Error loading available collaborators");
      }
    });
  },

  handleShowDialog (e: any) {
    e.preventDefault();
    this.setState({ showingDialog: true });
  },

  handleHideDialog (e: any) {
    e.preventDefault();
    this.setState({ showingDialog: false });
  },

  handleSelectCollaborator (e: any) {
    const id = parseInt(e.target.value, 10);
    this.setState({ selectedCollaborator: this.state.availableCollaborators.find(function (c: any) {
      return c.id === id;
    }) });
  },

  handleAddCollaborator (e: any) {
    e.preventDefault();
    const selectedCollaborator = this.state.selectedCollaborator;
    const collaborators = this.state.collaborators;

    if (selectedCollaborator && (collaborators.indexOf(selectedCollaborator) === -1)) {
      collaborators.push(selectedCollaborator);
      this.setState({ collaborators, selectedCollaborator: null });
    }
  },

  handleRemoveCollaborator (collaborator: any) {
    const collaborators = this.state.collaborators;
    const index = collaborators.indexOf(collaborator);
    if (index !== -1) {
      collaborators.splice(index, 1);
      this.setState({ collaborators });
    }
  },

  handleRun () {
    const collaborators = this.state.collaborators;
    if (collaborators.length === 0) {
      return;
    }
    this.setState({ runStarted: true });
    jQuery.ajax({
      type: "POST",
      url: Portal.API_V1.COLLABORATIONS,
      dataType: "json",
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify({
        offering_id: this.props.offeringId,
        students: collaborators.map(function (c: any) { return { id: c.id }; })
      }),
      success: (data) => {
        this.setState({ showingDialog: false }, function () {
          window.location.href = data.external_activity_url;
        });
      },
      error () {
        window.alert("Error creating collaboration");
      }
    });
  },

  renderCollaborators () {
    const collaborators = this.state.collaborators;

    if (collaborators.length === 0) {
      return <div className={css.collaborators}>No collaborators added</div>;
    }
    return (
      <div className={css.collaborators}>
        <ul>
          { collaborators.map((collaborator: any) => {
            const props = { collaborator, handleRemoveCollaborator: this.handleRemoveCollaborator };
            return Collaborator(props);
          }) }
        </ul>
      </div>
    );
  },

  renderAvailableCollaborators () {
    const items = [<option key="empty" value="" disabled>Select collaborator...</option>];
    this.state.availableCollaborators.forEach(function (c: any) {
      items.push(<option key={c.id} value={c.id}>{ c.name }</option>);
    });
    return items;
  },

  renderDialog () {
    const selectedCollaborator = this.state.selectedCollaborator;
    const runStarted = this.state.runStarted;
    return (
      <span>
        <div className={css.background} />
        <div className={css.dialog}>
          <div className={css.dialogContent}>
            <div className={css.controls}>
              <i className="fa fa-times control close-btn" onClick={this.handleHideDialog} />
            </div>
            <form>
              <select value={selectedCollaborator ? selectedCollaborator.id : ""} onChange={this.handleSelectCollaborator}>
                { this.renderAvailableCollaborators() }
              </select>
              <button disabled={runStarted || !selectedCollaborator} onClick={this.handleAddCollaborator}>Add</button>
            </form>
            { this.renderCollaborators() }
            <div className={css.bottom}>
              <button disabled={runStarted || (this.state.collaborators.length === 0)} onClick={this.handleRun}>{ this.props.label }</button>
              { runStarted ? <i className="fa fa-spinner fa-spin" /> : null }
            </div>
          </div>
        </div>
      </span>
    );
  },

  render () {
    const p = this.props;
    return (
      <span>
        <a target={p.target} href={p.href} className={p.class} onClick={this.handleShowDialog} ref={(el: any) => { this.buttonElement = el; }}>{ p.label }</a>
        { this.state.showingDialog ? this.renderDialog() : null }
      </span>
    );
  }

});

export default RunWithCollaborators;
