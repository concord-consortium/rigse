import React from 'react'
import ClassAssignments from './class-assignments'
import { reportableActivityMapping, studentMapping } from '../common/offering-progress/helpers'
import sortByName from '../../helpers/sort-by-name'
import OfferingsTable from './offerings-table'
import { arrayMove } from 'react-sortable-hoc'

import { appendOfferingApiQueryParams } from '../../url-params'

const teachersMapping = data => {
  return data.map(teacher => `${teacher.first_name} ${teacher.last_name}`).join(', ')
}

const offeringsListMapping = data => {
  return data.map(offering => ({
    id: offering.id,
    name: offering.name,
    apiUrl: offering.url,
    locked: offering.locked,
    active: offering.active
  }))
}

const externalReportMapping = data => {
  if (!data) {
    return null
  }
  return {
    name: data.name,
    launchText: data.launch_text,
    url: data.url
  }
}

const classMapping = data => {
  return data && {
    id: data.id,
    name: data.name,
    classWord: data.class_word,
    teachers: teachersMapping(data.teachers),
    editPath: data.edit_path,
    assignMaterialsPath: data.assign_materials_path,
    externalClassReports: data.external_class_reports.map(r => externalReportMapping(r))
  }
}

const offeringDetailsMapping = data => {
  return {
    id: data.id,
    activityName: data.activity,
    previewUrl: data.preview_url,
    activityUrl: data.activity_url,
    hasTeacherEdition: data.has_teacher_edition,
    reportUrl: data.report_url,
    externalReports: data.external_reports && data.external_reports.map(r => externalReportMapping(r)),
    reportableActivities: data.reportable_activities && data.reportable_activities.map(a => reportableActivityMapping(a)),
    students: data.students.map(s => studentMapping(s)).sort(sortByName)
  }
}

export default class Assignments extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      loading: !props.initialClassData,
      clazz: classMapping(props.initialClassData),
      // List of offering metadata.
      offerings: props.initialClassData ? offeringsListMapping(props.initialClassData.offerings) : [],
      // Detailed offering data which can be used to generate progress report.
      offeringDetails: {}
    }
    this.onOfferingsReorder = this.onOfferingsReorder.bind(this)
    this.onOfferingUpdate = this.onOfferingUpdate.bind(this)
    this.requestOfferingDetails = this.requestOfferingDetails.bind(this)
  }

  componentDidMount () {
    const { classDataUrl, initialClassData } = this.props
    if (classDataUrl && !initialClassData) {
      this.getClassData()
    }
  }

  getClassData () {
    const { classDataUrl } = this.props
    jQuery.ajax({
      url: classDataUrl,
      success: data => {
        this.setState({
          loading: false,
          clazz: classMapping(data),
          offerings: offeringsListMapping(data.offerings)
        })
      },
      error: () => {
        console.error(`GET ${classDataUrl} failed, can't render Assignment page`)
      }
    })
  }

  onOfferingsReorder ({ oldIndex, newIndex }) {
    if (oldIndex === newIndex) {
      return
    }
    const { offerings } = this.state
    const offeringApiUrl = offerings[oldIndex].apiUrl
    this.setState({ offerings: arrayMove(offerings, oldIndex, newIndex) })
    jQuery.ajax({
      type: 'PUT',
      url: offeringApiUrl,
      data: {
        position: newIndex
      },
      error: () => {
        window.alert('Reordering failed, please try to reload page and try again.')
        this.setState({ offerings: offerings })
      }
    })
  }

  onOfferingUpdate (offering, prop, value) {
    const { offerings } = this.state
    const newOffering = Object.assign({}, offering, { [prop]: value })
    const newOfferings = offerings.slice()
    newOfferings.splice(offerings.indexOf(offering), 1, newOffering)
    this.setState({ offerings: newOfferings })
    jQuery.ajax({
      type: 'PUT',
      url: offering.apiUrl,
      data: {
        [prop]: value
      },
      error: () => {
        window.alert('Offering update failed, please try to reload page and try again.')
      }
    })
  }

  requestOfferingDetails (offering) {
    jQuery.ajax({
      type: 'GET',
      url: appendOfferingApiQueryParams(offering.apiUrl),
      success: data => {
        const newData = offeringDetailsMapping(data)
        const { offeringDetails } = this.state
        this.setState({
          offeringDetails: Object.assign({}, offeringDetails, { [offering.id]: newData })
        })
      },
      error: () => {
        window.alert('Offering details loading failed, please try to reload page and try again.')
      }
    })
  }

  render () {
    const { loading, clazz, offerings, offeringDetails } = this.state
    if (loading) {
      return null
    }
    return (
      <div>
        <ClassAssignments clazz={clazz} />
        <OfferingsTable offerings={offerings} offeringDetails={offeringDetails}
          onOfferingsReorder={this.onOfferingsReorder} onOfferingUpdate={this.onOfferingUpdate} requestOfferingDetails={this.requestOfferingDetails} />
      </div>
    )
  }
}

Assignments.defaultProps = {
  // classDataUrl is pretty much required. It can be set to any default value, as it depends on the current class.
  classDataUrl: null,
  // If initialData is not provided, component will use API (dataUrl) to get it.
  initialClassData: null
}
