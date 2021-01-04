import React from 'react'

import SMaterial from './material'

export default class SMaterialsList extends React.Component {
  render () {
    return (
      <div className='material_list'>
        {this.props.materials.map((material) => <SMaterial material={material} key={`${material.class_name}${material.id}`} />)}
      </div>
    )
  }
}
