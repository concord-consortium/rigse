import React from 'react'
import ResourceFinderLightbox from '../resource-finder-lightbox'
import Lightbox from '../../helpers/lightbox'

import css from './style.scss'
import commonCss from '../../styles/common-css-modules.scss'

export default class ClassAssignments extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      showAssignOptions: false
    }
    this.closeLightbox = this.closeLightbox.bind(this)
    this.handleAssignMaterialsButtonClick = this.handleAssignMaterialsButtonClick.bind(this)
    this.handleAssignButtonMouseEnter = this.handleAssignButtonMouseEnter.bind(this)
    this.handleAssignButtonMouseLeave = this.handleAssignButtonMouseLeave.bind(this)
    this.renderAssignOptions = this.renderAssignOptions.bind(this)
  }

  closeLightbox (e) {
    Lightbox.close()
  }

  handleAssignMaterialsButtonClick (e) {
    this.setState({ showAssignOptions: false })
    const resourceFinderLightbox = ResourceFinderLightbox({
      closeLightbox: this.closeLightbox
    })
    Lightbox.open(resourceFinderLightbox)
  }

  handleAssignButtonMouseEnter (e) {
    this.setState({ showAssignOptions: true })
  }

  handleAssignButtonMouseLeave (e) {
    this.setState({ showAssignOptions: false })
  }

  renderAssignOptions () {
    return (
      <ul onMouseEnter={this.handleAssignButtonMouseEnter} onMouseLeave={this.handleAssignButtonMouseLeave}>
        <li onClick={this.handleAssignMaterialsButtonClick}>Recent: ITSI Materials</li>
        <li onClick={this.handleAssignMaterialsButtonClick}>Recent: NGSA Materials</li>
        <li onClick={this.handleAssignMaterialsButtonClick}>All Materials</li>
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
    console.log(this.state.showAssignOptions)
    const assignOptions = this.state.showAssignOptions ? this.renderAssignOptions() : null
    return (
      <div className={css.classAssignments}>
        <header>
          <h1>Assignments for { clazz.name }</h1>
          <div className={css.assignMaterials}>
            <button onMouseEnter={this.handleAssignButtonMouseEnter} onMouseLeave={this.handleAssignButtonMouseLeave} onClick={this.handleAssignMaterialsButtonClick}>Assign Materials</button>
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
