import React from 'react'
import ResourceFinderLightbox from '../resource-finder-lightbox'
import Lightbox from '../../helpers/lightbox'

import css from './style.scss'
import commonCss from '../../styles/common-css-modules.scss'

const closeLightbox = (e) => {
  Lightbox.close()
}

const handleAssignMaterialsButtonClick = (e) => {
  const resourceFinderLightbox = ResourceFinderLightbox({
    closeLightbox: closeLightbox
  })
  Lightbox.open(resourceFinderLightbox)
}

export default class ClassAssignments extends React.Component {
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
    return (
      <div className={css.classAssignments}>
        <header>
          <h1>Assignments for { clazz.name }</h1>
          <div className={css.assignMaterials}>
            <button onClick={handleAssignMaterialsButtonClick}>Assign Materials</button>
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
