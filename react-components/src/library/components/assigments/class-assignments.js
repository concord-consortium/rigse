import React from 'react'
import ResourceFinderLightbox from '../resource-finder-lightbox'
import CollectionLightbox from '../collection-lightbox'
import Lightbox from '../../helpers/lightbox'

import css from './style.scss'
import commonCss from '../../styles/common-css-modules.scss'

export default class ClassAssignments extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      showAssignOptions: false,
      collectionViews: []
    }
    this.closeLightbox = this.closeLightbox.bind(this)
    this.handleAssignMaterialsButtonClick = this.handleAssignMaterialsButtonClick.bind(this)
    this.handleAssignMaterialsOptionClick = this.handleAssignMaterialsOptionClick.bind(this)
    this.handleAssignButtonMouseEnter = this.handleAssignButtonMouseEnter.bind(this)
    this.handleAssignButtonMouseLeave = this.handleAssignButtonMouseLeave.bind(this)
    this.renderAssignOptions = this.renderAssignOptions.bind(this)
  }

  componentDidMount () {
    jQuery.ajax({
      url: Portal.API_V1.GET_TEACHER_PROJECT_VIEWS,
      dataType: 'json',
      success: function (data) {
        this.setState({
          collectionViews: data
        })
      }.bind(this)
    })
  }

  closeLightbox (e) {
    this.props.handleNewAssignment()
    Lightbox.close()
  }

  handleAssignMaterialsButtonClick (e) {
    this.setState({ showAssignOptions: !this.state.showAssignOptions })
  }

  handleAssignMaterialsOptionClick (e, collectionId) {
    this.setState({ showAssignOptions: false })
    const lightboxOptions = collectionId === 'all' || typeof collectionId === 'undefined'
      ? ResourceFinderLightbox({
        closeLightbox: this.closeLightbox,
        collectionViews: this.state.collectionViews,
        handleNav: this.handleAssignMaterialsOptionClick
      })
      : CollectionLightbox({
        closeLightbox: this.closeLightbox,
        collectionId: collectionId,
        collectionViews: this.state.collectionViews,
        handleNav: this.handleAssignMaterialsOptionClick
      })
    Lightbox.open(lightboxOptions)
  }

  handleAssignButtonMouseEnter (e) {
    this.setState({ showAssignOptions: true })
  }

  handleAssignButtonMouseLeave (e) {
    this.setState({ showAssignOptions: false })
  }

  renderAssignOption () {
    const { collectionViews } = this.state
    return (
      collectionViews.map(collection => (
        <li onClick={(e) => this.handleAssignMaterialsOptionClick(e, collection.id)}>{collection.name} Collection</li>
      ))
    )
  }

  renderAssignOptions () {
    const { collectionViews } = this.state
    const recentCollectionItems = collectionViews.length > 0 ? this.renderAssignOption() : null
    return (
      <ul>
        <li onClick={(e) => this.handleAssignMaterialsOptionClick(e, 'all')}>All Resources</li>
        {recentCollectionItems}
      </ul>
    )
  }

  get assignMaterialsPath () {
    const { clazz } = this.props
    if (Portal.theme === 'itsi-learn') {
      return `/itsi?assign_to_class=${clazz.id}`
    }
    if (Portal.theme === 'ngss-assessment') {
      return `/about`
    }
    return clazz.assignMaterialsPath
  }

  render () {
    const { clazz } = this.props
    const { showAssignOptions } = this.state
    const assignOptions = showAssignOptions ? this.renderAssignOptions() : null
    return (
      <div className={css.classAssignments}>
        <header>
          <h1>Assignments for { clazz.name }</h1>
          <div className={css.assignMaterials}>
            <button onClick={this.handleAssignMaterialsButtonClick}>Find More Resources</button>
            {assignOptions}
          </div>
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
            clazz.externalClassReports.map(r => <a key={r.url} href={r.url} target='_blank' className={commonCss.smallButton} title={r.name}>{ r.launchText }</a>)
          }
        </div>
      </div>
    )
  }
}
