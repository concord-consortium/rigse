import React from 'react'
import BookmarkRow from './bookmark-row'
import { SortableContainer, SortableItem } from '../shared/sortable-helpers'
import css from './style.scss'

class Bookmarks extends React.Component {
  render () {
    const { bookmarks } = this.props

    return (
      <div className={css.editBookmarksTable}>
        {
          bookmarks.map((bookmark, index) => (
            <SortableItem key={bookmark.id} id={bookmark.id} className={css.sortableItem}>
              <BookmarkRow
                key={bookmark.id}
                index={index}
                bookmark={bookmark}
                handleUpdate={this.props.handleUpdate}
                handleDelete={this.props.handleDelete}
                handleVisibilityToggle={this.props.handleVisibilityToggle}
              />
            </SortableItem>
          ))
        }
      </div>
    )
  }
}

const SortableBookmarks = ({ bookmarks, handleUpdate, handleDelete, handleVisibilityToggle, onSortEnd }) => {
  const renderDragPreview = itemId => {
    const bookmark = bookmarks.find(bookmark => bookmark.id === itemId)
    return (
      <BookmarkRow
        bookmark={bookmark}
        handleUpdate={handleUpdate}
        handleDelete={handleDelete}
        handleVisibilityToggle={handleVisibilityToggle}
      />
    )
  }

  return (
    <SortableContainer
      items={bookmarks.map(bookmark => bookmark.id)}
      renderDragPreview={renderDragPreview}
      onReorder={onSortEnd}
    >
      <Bookmarks
        bookmarks={bookmarks}
        handleUpdate={handleUpdate}
        handleDelete={handleDelete}
        handleVisibilityToggle={handleVisibilityToggle}
      />
    </SortableContainer>
  )
}

export default SortableBookmarks
