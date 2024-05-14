import React from 'react'
// import { SortableElement } from 'react-sortable-hoc'
import css from './style.scss'

const SortableElement = (Element) => Element

class UnsortableClassRow extends React.Component {
  render () {
    const { clazz } = this.props

    const handleCopy = () => this.props.handleCopy(clazz)
    const handleActiveToggle = () => this.props.handleActiveToggle(clazz)

    return (
      <div className={css.manageClassRow}>
        <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span>
        <span className={css.manageClassName}>
          {clazz.is_archived ? <strike>{clazz.name}</strike> : clazz.name}
        </span>
        <span className={css.manageClassButtons}>
          <button className={'textButton'} onClick={handleActiveToggle}>{clazz.is_archived ? 'Unarchive' : 'Archive'}</button>
          <button className={'textButton'} onClick={handleCopy}>Copy</button>
        </span>
      </div>
    )
  }
}

const SortableClassRow = SortableElement(UnsortableClassRow)

export default SortableClassRow
