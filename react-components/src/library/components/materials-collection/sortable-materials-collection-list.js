import React from 'react'
import { SortableContainer } from 'react-sortable-hoc'
import css from './style.scss'

import SortableMaterialsCollectionListRow from './sortable-materials-collection-list-row'

class MaterialsCollectionList extends React.Component {
  render () {
    const { items } = this.props

    return (
      <div className={css.editMaterialsCollectionsList}>
        {items.map((item, index) => (
          <SortableMaterialsCollectionListRow
            key={item.id}
            index={index}
            item={item}
            handleUpdate={this.props.handleUpdate}
            handleDelete={this.props.handleDelete}
            handleVisibilityToggle={this.props.handleVisibilityToggle}
          />
        ))}
      </div>
    )
  }
}

const SortableMaterialsCollectionList = SortableContainer(MaterialsCollectionList)

export default SortableMaterialsCollectionList
