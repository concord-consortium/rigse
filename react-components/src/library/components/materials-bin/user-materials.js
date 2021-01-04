import React from 'react'

import MBUserMaterialsContainer from './user-materials-container'

export default class MBUserMaterials extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      materialsVisible: false
    }
    this.toggleMaterials = this.toggleMaterials.bind(this)
  }

  toggleMaterials () {
    this.setState({ materialsVisible: !this.state.materialsVisible })
  }

  renderToggleIcon () {
    if (this.state.materialsVisible) {
      return '-'
    } else {
      return '+'
    }
  }

  render () {
    return (
      <div>
        <div className='mb-collection-name mb-clickable' onClick={this.toggleMaterials}>
          <span className='mb-toggle-symbol'>{this.renderToggleIcon()}</span> {this.props.name}
        </div>

        <MBUserMaterialsContainer
          userId={this.props.userId}
          visible={this.state.materialsVisible}
          assignToSpecificClass={this.props.assignToSpecificClass}
          archive={this.props.archiveSingle}
        />
      </div>
    )
  }
}
