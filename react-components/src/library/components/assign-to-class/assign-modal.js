import React from 'react'
import ConfirmDialog from '../../helpers/confirm-dialog'

import css from './style.scss'

export default class AssignModal extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      assignedClassIds: [],
      classesLoaded: false,
      classes: {
        assigned_classes: [],
        unassigned_classes: []
      },
      copyButtonClicked: false,
      errorMessage: null,
      resourceAssigned: false
    }

    this.assignMaterial = this.assignMaterial.bind(this)
    this.copyToClipboard = this.copyToClipboard.bind(this)
    this.updateClassList = this.updateClassList.bind(this)
  }

  componentDidMount () {
    if (window.Portal && !window.Portal.currentUser.isAnonymous) {
      const data = {
        material_id: this.props.material_id,
        material_type: this.props.material_type
      }
      jQuery.post(Portal.API_V1.MATERIAL_UNASSIGNED_CLASSES, data).done(response => {
        this.setState({
          classesLoaded: true,
          classes: response
        })
      }).fail(function (err) {
        if (err && err.responseText) {
          const response = jQuery.parseJSON(err.responseText)
          let message = response.message
          if (response.error) {
            message = response.error
          }
          this.setState({ errorMessage: 'There was an error: ' + message + '. Please try again.' })
        }
      })
    }
  }

  copyToClipboard () {
    const textItemId = '#' + css.shareUrl
    const temp = jQuery('<input>')
    jQuery('body').append(temp)
    temp.val(jQuery(textItemId).val()).select()
    document.execCommand('copy')
    temp.remove()

    this.setState({ copyButtonClicked: true }, () => {
      setTimeout(() => {
        this.setState({ copyButtonClicked: false })
      }, 4000)
    })
  }

  assignMaterial () {
    const authToken = jQuery('meta[name="csrf-token"]').attr('content')
    const assignedClassIds = this.state.assignedClassIds

    if (assignedClassIds && assignedClassIds.length < 1) {
      this.setState({ errorMessage: 'Select at least one class to assign this resource.' })
    } else {
      for (let classId of assignedClassIds) {
        let params = {
          assign: 1,
          class_id: classId,
          material_id: this.props.material_id,
          material_type: this.props.material_type,
          authenticity_token: authToken
        }
        this.setState({ resourceAssigned: true })
        jQuery.post(Portal.API_V1.ASSIGN_MATERIAL_TO_CLASS, params)
          .done(response => {
            this.setState({ resourceAssigned: true })
          })
          .fail(function (err) {
            if (err && err.responseText) {
              const response = jQuery.parseJSON(err.responseText)
              let message = response.message
              if (response.error) {
                message = response.error
              }
              console.log(message)
              //
              // TODO use some kind of styled modal dialog here.....
              //
              // jQuery('.input-error').text('Error: ' + message)
              // jQuery('.input-error').css('color', '#ea6d2f').fadeOut(200).fadeIn(200).fadeOut(200).fadeIn(200)
            }
          })
      }
    }
  }

  noClasses () {
    return (
      <p className='messagetext'>
        You don't have any active classes. Once you have created your class(es), you will be able to assign materials to them.
      </p>
    )
  }

  assignedClassesList () {
    const assignedClasses = this.state.classes.assigned_classes
    return (
      <div>
        <div className={css.alreadyAssignedClassHeader}>Already assigned to the following class(es)</div>
        <div>
          <div className={css.classListContainer + ' webkit_scrollbars'}>
            <ul>
              {
                assignedClasses.map(ac => <li key={ac.id}>{ac.name}</li>)
              }
            </ul>
          </div>
        </div>
      </div>
    )
  }

  unassignedClassesForm () {
    const unassignedClasses = this.state.classes.unassigned_classes
    return (
      <form id={css.addMaterialForm}>
        <div className={css.classListContainer + ' webkit_scrollbars'}>
          <ul>
            {
              unassignedClasses.map(uac => <li key={uac.id}><input className='unassigned_activity_class' id={'clazz_' + uac.id} name='clazz_id[]' type='checkbox' value={uac.id} onChange={this.updateClassList} /><label className='clazz_name' htmlFor={'clazz_' + uac.id}>{ uac.name }</label></li>)
            }
          </ul>
        </div>
      </form>
    )
  }

  updateClassList (event) {
    let assignedClassIds = this.state.assignedClassIds
    let classId = event.target.value
    if (event.target.checked) {
      assignedClassIds.push(classId)
    } else {
      let index = assignedClassIds.indexOf(classId)
      assignedClassIds.splice(index, 1)
    }
    this.setState({ assignedClassIds: assignedClassIds })
  }

  handleRegisterClick (e) {
    e.preventDefault()
    PortalComponents.renderSignupModal({
      oauthProviders: Portal.oauthProviders,
      closeable: true
    })
  }

  handleLoginClick (e) {
    e.preventDefault()
    const currentUrl = new URL(window.location)
    currentUrl.searchParams.set('openAssign', 'true')
    const assignPath = currentUrl.pathname + currentUrl.search
    PortalComponents.renderLoginModal({
      oauthProviders: Portal.oauthProviders,
      closeable: true,
      afterSigninPath: assignPath
    })
  }

  contentForAnonymous () {
    return (
      <div>
        <p>To assign this resource to classes and track student work on learn.concord.org, log in or register as a teacher.</p>
        <a className={css.button + ' button'} href='/signup' onClick={this.handleRegisterClick}>Register</a>
        <a className={css.button + ' button'} href='/login' onClick={this.handleLoginClick}>Log In</a>
        <a className={css.cancel} href='#' onClick={this.props.closeFunc}>Cancel</a>
      </div>
    )
  }

  contentForTeacher () {
    const errorMessageClass = this.state.errorMessage ? css.errorMessage + ' ' + css.visible : css.errorMessage
    return (
      <div>
        <p>Select the class(es) you want to assign this resource to below.</p>
        <div id='clazz_summary_data'>
          <div id={css.scrollableClassSummaryData}>
            <div className={errorMessageClass}>
              {this.state.errorMessage}
            </div>
            <div className={css.assignClassHeader}>
              Your Classes
            </div>
            {this.state.classesLoaded && this.state.classes === {} ? this.noClasses() : null}
            {this.state.classesLoaded && this.state.classes.unassigned_classes.length > 0 ? this.unassignedClassesForm() : null}
            {this.state.classesLoaded && this.state.classes.assigned_classes.length > 0 ? this.assignedClassesList() : null}
          </div>
          <a className={css.button + ' button'} href='#' onClick={this.assignMaterial}>Save</a>
          <a className={css.cancel} href='#' onClick={this.props.closeFunc}>Cancel</a>
        </div>
      </div>
    )
  }

  render () {
    if (this.state.resourceAssigned) {
      const alertMessage = <p>The {this.props.resourceType} <strong>{this.props.resourceTitle}</strong> was assigned to the selected class(es) successfully.</p>
      return (
        <ConfirmDialog open onConfirm={this.props.closeFunc}>
          {alertMessage}
        </ConfirmDialog>
      )
    } else {
      return (
        <div className={css.assignModalContent}>
          <div className={css.assignShareCol} id={css.assignCol}>
            <h2>Assign<span>…</span></h2>
            { window.Portal && window.Portal.currentUser.isAnonymous ? this.contentForAnonymous() : this.contentForTeacher() }
          </div>
          <div className={css.assignShareCol} id={css.shareCol}>
            <h2><span>or</span> Share</h2>
            <p>Copy the URL below to assign this resource in your own LMS or to share with colleagues.</p>
            <form>
              { this.state.copyButtonClicked ? <div className={css.textCopiedAlert}><span>Copied to clipboard!</span></div> : null }
              <label>Shareable URL</label><br />
              <input id={css.shareUrl} type='url' defaultValue={this.props.previewUrl} />
              <a className={css.button + ' button'} href='#' onClick={this.copyToClipboard}>Copy</a>
            </form>
            <p className={css.small}><strong>NOTE:</strong> Only use this option if you do not want to track student work on learn.concord.org</p>
          </div>
        </div>
      )
    }
  }
}
