import React from 'react'
import MaterialsCollectionListRow from './materials-collection-list-row'
import { SortableContainer, SortableItem } from '../shared/sortable-helpers'
import css from './style.scss'

class MaterialsCollectionList extends React.Component {
  render () {
    const { items } = this.props

    return (
      <div className={css.editMaterialsCollectionsList}>
        {
          items.map(item => (
            <SortableItem key={item.id} id={item.id}>
              <MaterialsCollectionListRow
                item={item}
                handleDelete={this.props.handleDelete}
              />
            </SortableItem>
          ))
        }
      </div>
    )
  }
}

const SortableMaterialsCollectionList = ({ items, handleDelete, onSortEnd }) => {
  const renderDragPreview = itemId => {
    const item = items.find(item => item.id === itemId)
    return (
      <MaterialsCollectionListRow
        item={item}
        handleDelete={handleDelete}
      />
    )
  }

  return (
    <SortableContainer
      items={items.map(item => item.id)}
      renderDragPreview={renderDragPreview}
      onReorder={onSortEnd}
    >
      <MaterialsCollectionList
        items={items}
        handleDelete={handleDelete}
      />
    </SortableContainer>
  )
}

export default SortableMaterialsCollectionList
