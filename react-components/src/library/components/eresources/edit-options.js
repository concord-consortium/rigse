import React from 'react'
import ReactDOM from 'react-dom'

import ModalDialog from '../shared/modal-dialog'
import StandardsTable from '../standards/standards-table'
import AddStandard from './add-standard'
import css from './edit-options.scss'
import modalDialogCSS from '../shared/modal-dialog.scss'

export class EditOptions extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      appliedStandards: undefined,
      loadedAppliedStandards: false,
      showAddStandards: false,
      saving: false
    }
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    this.handleToggleAddStandards = this.handleToggleAddStandards.bind(this)
    this.handleAfterStandardChange = this.handleAfterStandardChange.bind(this)
    this.handleAfterAppliedStandardChange = this.handleAfterAppliedStandardChange.bind(this)

    this.publicationStatusRef = React.createRef()
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillMount () {
    this.getAppliedStandards()
  }

  materialInfo () {
    const { eresource } = this.props
    return {
      material_id: eresource.id,
      material_type: eresource.type
    }
  }

  getAppliedStandards () {
    this.setState({ appliedStandards: undefined, loadedAppliedStandards: false }, () => {
      const materialInfo = this.materialInfo()
      jQuery.ajax({
        type: 'GET',
        dataType: 'json',
        url: '/api/v1/materials/get_materials_standards',
        data: materialInfo,
        success: (response) => {
          if (response) {
            response.material = materialInfo
          }
          this.setState({
            appliedStandards: response,
            loadedAppliedStandards: true
          })
        }
      })
    })
  }

  renderPublicationStatus () {
    const { editPublicationStatus, publicationStates, eresource } = this.props
    const { publicationStatus } = eresource

    if (!editPublicationStatus) {
      return undefined
    }

    return (
      <fieldset>
        <legend>Publication Status</legend>
        <select name='publication_status' defaultValue={publicationStatus} ref={this.publicationStatusRef}>
          {publicationStates.map((s) => <option key={s} value={s}>{s}</option>)}
        </select>
      </fieldset>
    )
  }

  renderCheckboxList (options) {
    const { edit, legend, all, selected, name } = options

    if (!edit) {
      return undefined
    }

    return (
      <fieldset>
        <legend>{legend}</legend>
        <div className={css.checkboxList}>
          {all.map((item) => {
            return (
              <span key={item}>
                <input type='checkbox' value={item} name={name} defaultChecked={selected.indexOf(item) !== -1} />
                {item}
              </span>
            )
          })}
        </div>
      </fieldset>
    )
  }

  renderGradeLevels () {
    const { editGradeLevels, allGradeLevels, eresource } = this.props
    const { gradeLevels } = eresource

    return this.renderCheckboxList({
      edit: editGradeLevels,
      legend: 'Grade Levels',
      all: allGradeLevels,
      selected: gradeLevels,
      name: 'grade_levels[]'
    })
  }

  renderSubjectAreas () {
    const { editSubjectAreas, allSubjectAreas, eresource } = this.props
    const { subjectAreas } = eresource

    return this.renderCheckboxList({
      edit: editSubjectAreas,
      legend: 'Subject Areas',
      all: allSubjectAreas,
      selected: subjectAreas,
      name: 'subject_areas[]'
    })
  }

  renderSensors () {
    const { editSensors, allSensors, eresource } = this.props
    const { sensors } = eresource

    return this.renderCheckboxList({
      edit: editSensors,
      legend: 'Sensors',
      all: allSensors,
      selected: sensors,
      name: 'sensors[]'
    })
  }

  renderAppliedStandards () {
    const { appliedStandards, loadedAppliedStandards } = this.state

    if (!loadedAppliedStandards) {
      return <div className={css.info}>Loading applied standards</div>
    }

    if (!appliedStandards || !appliedStandards.statements || (appliedStandards.statements.length === 0)) {
      return <div className={css.info}>No standards applied</div>
    }

    return <StandardsTable afterChange={this.handleAfterAppliedStandardChange} skipPaginate skipModal {...appliedStandards} />
  }

  renderStandards () {
    const { editStandards, allStandards } = this.props
    const { showAddStandards, appliedStandardsChangedAt } = this.state
    const materialInfo = this.materialInfo()

    if (!editStandards) {
      return undefined
    }

    return (
      <fieldset>
        <legend>Standards</legend>
        <div>
          <div className={css.sectionLabel}>Applied Standards</div>
          {this.renderAppliedStandards()}
        </div>
        <div>
          <div className={css.addStandards}>
            <div className={css.addStandardsLabel}>Add Standards</div>
            <div><button onClick={this.handleToggleAddStandards}>{showAddStandards ? 'Done' : 'Add'}</button></div>
          </div>
          { showAddStandards ? <AddStandard materialInfo={materialInfo} allStandards={allStandards} afterChange={this.handleAfterStandardChange} appliedStandardsChangedAt={appliedStandardsChangedAt} /> : undefined }
        </div>
      </fieldset>
    )
  }

  handleToggleAddStandards (e) {
    e.preventDefault()
    this.setState({ showAddStandards: !this.state.showAddStandards })
  }

  handleAfterStandardChange () {
    this.getAppliedStandards()
  }

  handleAfterAppliedStandardChange () {
    this.setState({ appliedStandardsChangedAt: Date.now() })
  }

  getCheckboxes (name) {
    const checkboxes = []
    const elements = document.getElementsByName(name)
    for (let i = 0; i < elements.length; i++) {
      if (elements[i].checked) {
        checkboxes.push(elements[i].value)
      }
    }
    return checkboxes
  }

  handleSubmit (e) {
    const { eresource } = this.props

    e.preventDefault()

    const data = {
      publication_status: this.publicationStatusRef.current ? this.publicationStatusRef.current.value : '',
      grade_levels: this.getCheckboxes('grade_levels[]'),
      subject_areas: this.getCheckboxes('subject_areas[]'),
      sensors: this.getCheckboxes('sensors[]')
    }

    this.setState({ saving: true }, () => {
      jQuery.ajax({
        type: 'POST',
        dataType: 'json',
        url: `/api/v1/external_activities/${eresource.id}/update_basic`,
        data,
        success: () => {
          window.location.reload()
        },
        error: function (xhr, ajaxOptions, thrownError) {
          this.setState({ saving: false }, () => {
            window.alert(`Unable to save options: ${xhr.responseText}`)
          })
        }
      })
    })
  }

  handleCancel () {
    const { parentId } = this.props
    if (parentId) {
      const parentNode = document.getElementById(parentId)
      ReactDOM.unmountComponentAtNode(parentNode)
    } else {
      console.error('No parentId parameter found to unmount component')
    }
  }

  render () {
    const { saving } = this.state
    const { eresource } = this.props

    return (
      <ModalDialog title='Edit Options'>
        <div className={css.container}>
          <h3>External Activity: {eresource.name}</h3>
          <form onSubmit={this.handleSubmit}>
            {this.renderPublicationStatus()}
            {this.renderGradeLevels()}
            {this.renderSubjectAreas()}
            {this.renderSensors()}
            {this.renderStandards()}
          </form>
        </div>
        <div className={modalDialogCSS.buttons}>
          <button onClick={this.handleSubmit} disabled={saving}>{saving ? 'Saving...' : 'Save'}</button>
          <button onClick={this.handleCancel}>Cancel</button>
        </div>
      </ModalDialog>
    )
  }
}

export default EditOptions
