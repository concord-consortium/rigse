import React from 'react'
import css from './style.scss'

class BookmarkRow extends React.Component<any, any> {
  nameRef: any;
  urlRef: any;
  constructor (props: any) {
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
        <div className={css.editBookmarkRow}>
          <span className={css.editBookmarkName}>
            <input type='text' ref={this.nameRef} defaultValue={bookmark.name} placeholder='Name' />
            <input type='text' ref={this.urlRef} defaultValue={bookmark.url} placeholder='URL' />
          </span>
          <span className={css.editBookmarkButtons}>
            <button onClick={handleSave}>Save</button>
            <button className={'textButton'} onClick={handleToggleEdit}>Cancel</button>
          </span>
        </div>
      )
    } else {
      const link = <a href={bookmark.url} target='_blank' rel='noopener'>{bookmark.name}</a>
      return (
        <div className={css.editBookmarkRow}>
          <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span>
          <span className={css.editBookmarkName}>
            {bookmark.is_visible ? link : <del>{link}</del>}
          </span>
          <span className={css.editBookmarkButtons}>
            <button className={'textButton adminOption'} onClick={handleToggleEdit}>Edit</button>
            <button className={'textButton adminOption'} onClick={handleVisibilityToggle}>{bookmark.is_visible ? 'Hide' : 'Show'}</button>
            <button className={'textButton adminOption'} onClick={handleDelete}>Delete</button>
          </span>
        </div>
      )
    }
  }
}

export default BookmarkRow
