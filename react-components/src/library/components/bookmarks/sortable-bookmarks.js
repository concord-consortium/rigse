import React from 'react'
import { SortableContainer } from 'react-sortable-hoc'
import css from './style.scss'

import SortableBookmarkRow from './sortable-bookmark-row'

class UnsortableSortableBookmarks extends React.Component {
  render () {
    const { bookmarks } = this.props
    if (bookmarks.length === 0) {
      return null
    }

    return (
      <div className={css.editBookmarksTable}>
        {bookmarks.map((bookmark, index) => (
          <SortableBookmarkRow
            key={bookmark.id}
            index={index}
            bookmark={bookmark}
            handleUpdate={this.props.handleUpdate}
            handleDelete={this.props.handleDelete}
            handleVisibilityToggle={this.props.handleVisibilityToggle}
          />
        ))}
      </div>
    )
  }
}

const SortableBookmarks = SortableContainer(UnsortableSortableBookmarks)

export default SortableBookmarks
