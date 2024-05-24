import React from 'react'

import SMaterialIcon from './material-icon'
import SMaterialInfo from './material-info'
import SMaterialBody from './material-body'
import SMaterialDetails from './material-details'

export default class SMaterial extends React.Component {
  render () {
    const { material } = this.props

    const configuration = {
      enableFavorites: true,
      favoriteClassMap: {
        true: 'legacy-favorite-active',
        false: 'legacy-favorite'
      },
      favoriteOutlineClass: 'legacy-favorite-outline'
    }

    return (
      <div
        className='material_list_item'
        data-material_id={material.id}
        data-material_name={material.name}
        id={`search_${material.class_name_underscored}_${material.id}`}
      >
        <div className='main-part'>
          <SMaterialIcon material={material} configuration={configuration} />
          <SMaterialInfo material={material} />
          <SMaterialBody material={material} />
        </div>
        <SMaterialDetails material={material} />
      </div>
    )
  }
}
