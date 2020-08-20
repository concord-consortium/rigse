import React from 'react'
import { arrayMove } from 'react-sortable-hoc'

import SortableBookmarks from './sortable-bookmarks'
import css from './style.scss'

const shouldCancelSorting = e => {
  // Only HTML elements with selected classes can be used to reorder offerings.
  const classList = e.target.classList
  for (const cl of [ css.sortIcon, css.editBookmarkName ]) {
    if (classList.contains(cl)) {
      return false
    }
  }
  return true
}

export class EditBookmarks extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      bookmarks: this.sortBookmarks(props.bookmarks)
    }

    this.handleCreate = this.handleCreate.bind(this)
    this.handleUpdate = this.handleUpdate.bind(this)
    this.handleDelete = this.handleDelete.bind(this)
    this.handleVisibilityToggle = this.handleVisibilityToggle.bind(this)
    this.handleSortEnd = this.handleSortEnd.bind(this)
  }

  sortBookmarks (bookmarks) {
    bookmarks.sort((a, b) => a.position - b.position)
    return bookmarks
  }

  handleCreate () {
    this.fetch('create')
      .then(bookmark => {
        const { bookmarks } = this.state
        bookmark.editing = true
        bookmarks.push(bookmark)
        this.sortBookmarks(bookmarks)
        this.setState({ bookmarks })
      })
      .catch(err => this.showError(err, 'Unable to create link!'))
  }

  handleUpdate (bookmark, fields) {
    const { name, url } = fields
    const { name: oldName, url: oldUrl } = bookmark

    const update = (newName, newUrl) => {
      bookmark.name = newName
      bookmark.url = newUrl
      this.setState({ bookmarks: this.state.bookmarks })
    }

    update(name, url)
    this.fetch('update', bookmark, { name, url })
      .catch(err => {
        // reset the bookmark on error
        update(oldName, oldUrl)
        this.showError(err, 'Unable to update link!')
      })
  }

  handleDelete (bookmark) {
    if (window.confirm(`Are you sure you want to delete this bookmark?\n\n${bookmark.name} -> ${bookmark.url}`)) {
      const { bookmarks } = this.state
      const index = bookmarks.indexOf(bookmark)
      bookmarks.splice(index, 1)
      this.setState({ bookmarks })

      this.fetch('delete', bookmark)
        .catch(err => {
          // add the bookmark back on error
          bookmarks.splice(index, 0, bookmark)
          this.setState({ bookmarks })
          this.showError(err, 'Unable to delete link!')
        })
    }
  }

  handleVisibilityToggle (bookmark) {
    const toggle = () => {
      bookmark.is_visible = !bookmark.is_visible
      this.setState({ bookmarks: this.state.bookmarks })
    }

    toggle()
    this.fetch('visibilityToggle', bookmark, { is_visible: bookmark.is_visible })
      .catch(err => {
        // retoggle back on error
        toggle()
        this.showError(err, 'Unable to toggle visibility of link!')
      })
  }

  showError (err, message) {
    if (err.message) {
      window.alert(`${message}\n${err.message}`)
    } else {
      window.alert(message)
    }
  }

  fetch (action, bookmark, body) {
    const basePath = '/api/v1/bookmarks'

    bookmark = bookmark || { id: 0 }

    const { url, method } = {
      create: { url: basePath, method: 'POST' },
      update: { url: `${basePath}/${bookmark.id}`, method: 'PUT' },
      visibilityToggle: { url: `${basePath}/${bookmark.id}`, method: 'PUT' },
      delete: { url: `${basePath}/${bookmark.id}`, method: 'DELETE' },
      sort: { url: `${basePath}/sort`, method: 'POST' }
    }[action]

    body = typeof body !== 'undefined' ? JSON.stringify(body) : body

    return window.fetch(url, { method,
      body,
      cache: 'no-cache',
      headers: {
        'Authorization': `Bearer/JWT ${this.props.jwt}`,
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
      .then(resp => resp.json())
      .then(json => {
        if (!json.success) {
          throw new Error(json.message)
        }
        return json.data
      })
  }

  handleSortEnd ({ oldIndex, newIndex }) {
    let { bookmarks } = this.state
    bookmarks = arrayMove(bookmarks, oldIndex, newIndex)
    this.setState({ bookmarks })

    const ids = bookmarks.map(bookmark => bookmark.id)
    this.fetch('sort', null, { ids: JSON.stringify(ids) })
      .catch(err => {
        this.setState({ bookmarks: arrayMove(bookmarks, newIndex, oldIndex) })
        this.showError(err, 'Unable to save link sort order!')
      })
  }

  render () {
    return (
      <>
        <SortableBookmarks
          bookmarks={this.state.bookmarks}
          handleUpdate={this.handleUpdate}
          handleDelete={this.handleDelete}
          handleVisibilityToggle={this.handleVisibilityToggle}
          shouldCancelStart={shouldCancelSorting}
          onSortEnd={this.handleSortEnd}
          distance={3}
        />
        <div>
          <button onClick={this.handleCreate}>Create Link</button>
        </div>
      </>
    )
  }
}

export default EditBookmarks
