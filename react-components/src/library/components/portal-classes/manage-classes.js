import React from 'react'
import { arrayMove } from 'react-sortable-hoc'
import SortableClasses from './sortable-classes'
import shouldCancelSorting from '../../helpers/should-cancel-sorting'
import CopyDialog from './copy-dialog'

import css from './style.scss'

export default class ManageClasses extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      classes: this.props.classes,
      copyClazz: null,
      saving: false
    }
    this.handleCopy = this.handleCopy.bind(this)
    this.handleActiveToggle = this.handleActiveToggle.bind(this)
    this.handleSortEnd = this.handleSortEnd.bind(this)
    this.handleSaveCopy = this.handleSaveCopy.bind(this)
    this.handleCopyCancel = () => this.handleCopy(null)
  }

  handleCopy (clazz) {
    this.setState({ copyClazz: clazz })
  }

  handleSaveCopy (values) {
    const onSuccess = () => window.location.reload()
    this.setState({ saving: true }, () => {
      this.apiCall('copy', { clazz: this.state.copyClazz, data: values, onSuccess })
        .catch(err => {
          this.showError(err, 'Unable to copy the class!')
          this.setState({ saving: false })
        })
    })
  }

  handleActiveToggle (clazz) {
    const toggle = () => {
      clazz.active = !clazz.active
      this.setState({ classes: this.state.classes })
    }

    toggle()
    this.apiCall('activeToggle', { clazz, data: { active: clazz.active } })
      .catch(err => {
        // retoggle back on error
        toggle()
        this.showError(err, 'Unable to toggle active state of the class!')
      })
  }

  handleSortEnd ({ oldIndex, newIndex }) {
    let { classes } = this.state
    classes = arrayMove(classes, oldIndex, newIndex)
    this.setState({ classes })

    const ids = classes.map(c => c.id)
    this.apiCall('sort', { data: { ids } })
      .catch(err => {
        this.setState({ classes: arrayMove(classes, newIndex, oldIndex) })
        this.showError(err, 'Unable to save class sort order!')
      })
  }

  showError (err, message) {
    if (err.message) {
      window.alert(`${message}\n${err.message}`)
    } else {
      window.alert(message)
    }
  }

  apiCall (action, options) {
    const basePath = '/api/v1/teacher_classes'
    let { clazz, data, onSuccess } = options

    clazz = clazz || { id: 0 }

    const { url, type } = {
      copy: { url: `${basePath}/${clazz.id}/copy`, type: 'POST' },
      sort: { url: `${basePath}/sort`, type: 'POST' },
      activeToggle: { url: `${basePath}/${clazz.id}/set_active`, type: 'POST' }
    }[action]

    return Promise.resolve(
      jQuery.ajax({
        url,
        data: JSON.stringify(data),
        type,
        dataType: 'json',
        contentType: 'application/json',
        success: json => {
          if (!json.success) {
            throw json
          } else {
            if (onSuccess) {
              onSuccess(json.data)
            }
          }
        },
        error: (jqXHR, textStatus, error) => {
          try {
            error = JSON.parse(jqXHR.responseText)
          } catch (e) {}
          throw error
        }
      })
    )
  }

  render () {
    const { classes, copyClazz, saving } = this.state
    const numActiveClasses = classes.filter(c => c.active).length
    const shouldCancelStart = shouldCancelSorting([ css.sortIcon, css.manageClassName ])

    return (
      <>
        <div className={css.manageClassesSummary}>
          My Classes ({classes.length} Total, {numActiveClasses} Active)
        </div>

        <SortableClasses
          classes={classes}
          handleCopy={this.handleCopy}
          handleActiveToggle={this.handleActiveToggle}
          shouldCancelStart={shouldCancelStart}
          onSortEnd={this.handleSortEnd}
          distance={3}
        />

        {copyClazz ? <CopyDialog clazz={copyClazz} saving={saving} handleSave={this.handleSaveCopy} handleCancel={this.handleCopyCancel} /> : undefined}
      </>
    )
  }
}
