import React from 'react'
// import { arrayMove } from 'react-sortable-hoc'
import SortableMaterialsCollectionList from './sortable-materials-collection-list'
import css from './style.scss'

// TODO 2024: replace sortable implementation
const arrayMove = () => { /* noop */ }

// TODO: use helper once https://github.com/concord-consortium/rigse/pull/781 is merged
const shouldCancelSorting = e => {
  // Only HTML elements with selected classes can be used to reorder offerings.
  const classList = e.target.classList
  for (const cl of [ css.sortIcon, css.editMaterialsCollectionsListRowName ]) {
    if (classList.contains(cl)) {
      return false
    }
  }
  return true
}

export class EditMaterialsCollectionList extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      items: props.items
    }

    this.handleDelete = this.handleDelete.bind(this)
    this.handleSortEnd = this.handleSortEnd.bind(this)
  }

  handleDelete (item) {
    if (window.confirm(`Remove ${item.name} from "${this.props.collection.name}"?`)) {
      const { items } = this.state
      const index = items.indexOf(item)
      items.splice(index, 1)
      this.setState({ items })

      this.apiCall('remove_material', { data: { item_id: item.id } })
        .catch(err => {
          // add back on error
          items.splice(index, 0, item)
          this.setState({ items })
          this.showError(err, 'Unable to delete item!')
        })
    }
  }

  handleSortEnd ({ oldIndex, newIndex }) {
    let { items } = this.state
    items = arrayMove(items, oldIndex, newIndex)
    this.setState({ items })

    const itemIds = items.map(item => item.id)
    this.apiCall('sort_materials', { data: { item_ids: itemIds } })
      .catch(err => {
        this.setState({ items: arrayMove(items, newIndex, oldIndex) })
        this.showError(err, 'Unable to save item sort order!')
      })
  }

  showError (err, message) {
    if (err.message) {
      window.alert(`${message}\n${err.message}`)
    } else {
      window.alert(message)
    }
  }

  apiCall (action, options) {
    const basePath = '/api/v1/materials_collections'
    const { collection } = this.props
    const { data } = options

    const { url, type } = {
      remove_material: { url: `${basePath}/${collection.id}/remove_material`, type: 'POST' },
      sort_materials: { url: `${basePath}/${collection.id}/sort_materials`, type: 'POST' }
    }[action]

    return new Promise((resolve, reject) => {
      jQuery.ajax({
        url,
        data: JSON.stringify(data),
        type,
        dataType: 'json',
        contentType: 'application/json',
        success: json => {
          if (!json.success) {
            reject(json.message)
          } else {
            resolve(json.data)
          }
        },
        error: (jqXHR, textStatus, error) => {
          reject(error)
        }
      })
    })
  }

  render () {
    const { items } = this.state

    if (items.length === 0) {
      return (
        <p>
          No materials have been added to this collection.  To add materials use the <a href='/search'>search page</a> and then click on the "Add to Collection" button on the search result.
        </p>
      )
    }

    return (
      <SortableMaterialsCollectionList
        items={items}
        handleDelete={this.handleDelete}
        shouldCancelStart={shouldCancelSorting}
        onSortEnd={this.handleSortEnd}
        distance={3}
      />
    )
  }
}

export default EditMaterialsCollectionList
