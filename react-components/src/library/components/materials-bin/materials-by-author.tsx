import React from 'react'

import MBFetchDataHOC from './fetch-data-hoc'
import MBUserMaterials from './user-materials'
import createFactory from '../../helpers/create-factory'

class _MBMaterialsByAuthor extends React.Component {
  getVisibilityClass () {
    if (!this.props.visible) {
      return 'mb-hidden'
    } else {
      return ''
    }
  }

  render () {
    const className = `mb-cell ${this.getVisibilityClass()}`
    return (
      <div className={className}>
        {this.props.authors != null
          ? this.props.authors.map((author) =>
            <MBUserMaterials
              key={author.id}
              name={author.name}
              userId={author.id}
              assignToSpecificClass={this.props.assignToSpecificClass}
            />)
          : <div>Loading...</div>}
      </div>
    )
  }
}

const MBMaterialsByAuthor = createFactory(MBFetchDataHOC(_MBMaterialsByAuthor, () => ({

  dataStateKey: 'authors',

  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS_AUTHORS,

  requestParams () {
    if (this.props.assignToSpecificClass) {
      return { assigned_to_class: this.props.assignToSpecificClass }
    } else {
      return {}
    }
  }
})))

export default MBMaterialsByAuthor
