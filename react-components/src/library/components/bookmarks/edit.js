import React from 'react'
import css from './style.scss'

class BookmarkRow extends React.Component {
  constructor (props) {
    super(props)
    const { bookmark } = props

    // we keep the editing state in two places so that it can be enabled when a new bookmark is created
    bookmark.editing = !!bookmark.editing
    this.state = {
      editing: bookmark.editing
    }

    this.nameRef = React.createRef()
    this.urlRef = React.createRef()
  }

  render () {
    const { bookmark } = this.props
    const { editing } = this.state

    const handleDelete = () => this.props.handleDelete(bookmark)

    const handleVisibilityToggle = () => this.props.handleVisibilityToggle(bookmark)

    const handleToggleEdit = () => {
      bookmark.editing = !bookmark.editing
      this.setState({ editing: bookmark.editing })
    }

    const handleSave = () => {
      const name = this.nameRef.current.value.trim()
      const url = this.urlRef.current.value.trim()
      if ((name.length > 0) && (url.length > 0)) {
        this.props.handleUpdate(bookmark, { name, url })
        handleToggleEdit()
      } else {
        window.alert('Please enter both a name and an url')
      }
    }

    if (editing) {
      return (
        <tr>
          <td className={css.editBookmarkName} colspan='2'>
            <input type='text' ref={this.nameRef} defaultValue={bookmark.name} placeholder='Name' />
            <input type='text' ref={this.urlRef} defaultValue={bookmark.url} placeholder='URL' />
          </td>
          <td className={css.editBookmarkButtons}>
            <button onClick={handleSave}>Save</button>
            <button onClick={handleToggleEdit}>Cancel</button>
          </td>
        </tr>
      )
    } else {
      const link = <a href={bookmark.url} target='_blank' rel='noopener'>{bookmark.name}</a>
      return (
        <tr>
          <td>☰</td>
          <td className={css.editBookmarkName}>
            {bookmark.is_visible ? link : <strike>{link}</strike>}
          </td>
          <td className={css.editBookmarkButtons}>
            <button onClick={handleToggleEdit}>Edit</button>
            <button onClick={handleVisibilityToggle}>{bookmark.is_visible ? 'Hide' : 'Show'}</button>
            <button onClick={handleDelete}>Delete</button>
          </td>
        </tr>
      )
    }
  }
}

export default class EditBookmarks extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      bookmarks: this.sortBookmarks(props.bookmarks)
    }

    this.handleCreate = this.handleCreate.bind(this)
    this.handleUpdate = this.handleUpdate.bind(this)
    this.handleDelete = this.handleDelete.bind(this)
    this.handleVisibilityToggle = this.handleVisibilityToggle.bind(this)
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

  // TODO: handle sorting

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

  renderBookmarks () {
    const { bookmarks } = this.state
    if (bookmarks.length === 0) {
      return null
    }

    return (
      <table className={css.editBookmarksTable}>
        <tbody>
          {bookmarks.map((bookmark) => (
            <BookmarkRow
              key={bookmark.id}
              bookmark={bookmark}
              handleUpdate={this.handleUpdate}
              handleDelete={this.handleDelete}
              handleVisibilityToggle={this.handleVisibilityToggle}
            />
          ))}
        </tbody>
      </table>
    )
  }

  render () {
    return (
      <>
        {this.renderBookmarks()}
        <div>
          <button onClick={this.handleCreate}>Create Link</button>
        </div>
      </>
    )
  }
}

/*
sort_api_v1_bookmarks POST     /api/v1/bookmarks/sort(.:format)                                                    api/v1/bookmarks#sort {:id=>/\d+/, :format=>:json}
api_v1_bookmarks POST     /api/v1/bookmarks(.:format)                                                         api/v1/bookmarks#create {:id=>/\d+/, :format=>:json}
api_v1_bookmark PUT      /api/v1/bookmarks/:id(.:format)                                                     api/v1/bookmarks#update {:id=>/\d+/, :format=>:json}
DELETE   /api/v1/bookmarks/:id(.:format)                                                     api/v1/bookmarks#destroy {:id=>/\d+/, :format=>:json}

  basePath: "https://app.rigse.docker/portal/classes/5/bookmarks",
bookmarks: [
  {"id":1,"is_visible":true,"name":"My bookmark","position":1,"url":"http://concord.org"},
  {"clazz_id":5,"created_at":"2020-08-19T15:28:26Z","id":2,"is_visible":true,"name":"My bookmark","position":2,"updated_at":"2020-08-19T15:28:26Z","url":"http://concord.org","user_id":8},
  {"clazz_id":5,"created_at":"2020-08-19T15:29:31Z","id":3,"is_visible":true,"name":"My bookmark","position":3,"updated_at":"2020-08-19T15:29:31Z","url":"http://concord.org","user_id":8}]
*/
