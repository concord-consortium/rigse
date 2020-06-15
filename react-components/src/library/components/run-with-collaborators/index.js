import css from './style.scss'
import Component from '../../helpers/component'

var Collaborator = Component({

  handleRemoveCollaborator: function () {
    this.props.handleRemoveCollaborator(this.props.collaborator)
  },

  render: function () {
    var c = this.props.collaborator
    return (
      <li><i className='fa fa-trash-o control' onClick={this.handleRemoveCollaborator} />{c.name}</li>
    )
  }
})

var RunWithCollaborators = Component({

  buttonElement: null,

  getInitialState: function () {
    return {
      showingDialog: false,
      selectedCollaborator: null,
      availableCollaborators: [],
      collaborators: [],
      runStarted: false
    }
  },

  UNSAFE_componentWillMount: function () {
    this.loadAvailableCollaborators()
  },

  loadAvailableCollaborators: function () {
    var self = this
    jQuery.ajax({
      type: 'GET',
      url: Portal.API_V1.AVAILABLE_COLLABORATORS,
      data: { offering_id: this.props.offeringId },
      success: function (data) {
        self.setState({ availableCollaborators: data })
      },
      error: function () {
        window.alert('Error loading available collaborators')
      }
    })
  },

  handleShowDialog: function (e) {
    e.preventDefault()
    this.setState({ showingDialog: true })
  },

  handleHideDialog: function (e) {
    e.preventDefault()
    this.setState({ showingDialog: false })
  },

  handleSelectCollaborator: function (e) {
    var id = parseInt(e.target.value, 10)
    this.setState({ selectedCollaborator: this.state.availableCollaborators.find(function (c) {
      return c.id === id
    }) })
  },

  handleAddCollaborator: function (e) {
    e.preventDefault()
    var selectedCollaborator = this.state.selectedCollaborator
    var collaborators = this.state.collaborators

    if (selectedCollaborator && (collaborators.indexOf(selectedCollaborator) === -1)) {
      collaborators.push(selectedCollaborator)
      this.setState({ collaborators: collaborators, selectedCollaborator: null })
    }
  },

  handleRemoveCollaborator: function (collaborator) {
    var collaborators = this.state.collaborators
    var index = collaborators.indexOf(collaborator)
    if (index !== -1) {
      collaborators.splice(index, 1)
      this.setState({ collaborators: collaborators })
    }
  },

  handleRun: function () {
    var self = this
    var jnlpUrl = this.props['data-jnlp-url']
    var collaborators = this.state.collaborators
    if (collaborators.length === 0) {
      return
    }
    this.setState({ runStarted: true })
    jQuery.ajax({
      type: 'POST',
      url: Portal.API_V1.COLLABORATIONS,
      dataType: 'json',
      contentType: 'application/json; charset=utf-8',
      data: JSON.stringify({
        offering_id: this.props.offeringId,
        students: collaborators.map(function (c) { return { id: c.id } })
      }),
      success: function (data) {
        self.setState({ showingDialog: false }, function () {
          if (jnlpUrl) {
            // NOTE: this block was copied from the old portal angular code
            // I'm not sure why we are updating the run status and then immediately redirecting
            // https://github.com/concord-consortium/rigse/blob/7d74408d9f0218670e345da0fbaa5584a79c6461/app/assets/javascripts/angular/collaboration.js.coffee#L107-L116
            var runStatus = new OfferingRunStatus(this.buttonElement)
            runStatus.toggleRunStatusView()
            runStatus.trigger_status_updates()
          }
          window.location.href = jnlpUrl || data.external_activity_url
        })
      },
      error: function () {
        window.alert('Error creating collaboration')
      }
    })
  },

  renderCollaborators: function () {
    var self = this
    var collaborators = this.state.collaborators

    if (collaborators.length === 0) {
      return <div className={css.collaborators}>No collaborators added</div>
    }
    return (
      <div className={css.collaborators}>
        <ul>
          {collaborators.map(function (collaborator) {
            return Collaborator({ collaborator: collaborator, handleRemoveCollaborator: self.handleRemoveCollaborator })
          })}
        </ul>
      </div>
    )
  },

  renderAvailableCollaborators: function () {
    var items = [<option key='empty' value='' disabled>Select collaborator...</option>]
    this.state.availableCollaborators.forEach(function (c) {
      items.push(<option key={c.id} value={c.id}>{c.name}</option>)
    })
    return items
  },

  renderDialog: function () {
    var selectedCollaborator = this.state.selectedCollaborator
    var runStarted = this.state.runStarted
    return (
      <span>
        <div className={css.background} />
        <div className={css.dialog}>
          <div className={css.dialogContent}>
            <div className={css.controls}>
              <i className='fa fa-times control close-btn' onClick={this.handleHideDialog} />
            </div>
            <form>
              <select value={selectedCollaborator ? selectedCollaborator.id : ''} onChange={this.handleSelectCollaborator}>
                {this.renderAvailableCollaborators()}
              </select>
              <button disabled={runStarted || !selectedCollaborator} onClick={this.handleAddCollaborator}>Add</button>
            </form>
            {this.renderCollaborators()}
            <div className={css.bottom}>
              <button disabled={runStarted || (this.state.collaborators.length === 0)} onClick={this.handleRun}>{this.props.label}</button>
              {runStarted ? <i className='fa fa-spinner fa-spin' /> : null}
            </div>
          </div>
        </div>
      </span>
    )
  },

  render: function () {
    var self = this
    var p = this.props
    return (
      <span>
        <a target={p.target} href={p.href} className={p.class} onClick={this.handleShowDialog} ref={function (el) { self.buttonElement = el }}>{p.label}</a>
        {this.state.showingDialog ? this.renderDialog() : null}
      </span>
    )
  }

})

export default RunWithCollaborators
