import React from 'react'
import { SortableElement } from 'react-sortable-hoc'
import css from './style.scss'

class UnsortableClassRow extends React.Component {
  render () {
    const { clazz } = this.props

    const handleCopy = () => this.props.handleCopy(clazz)
    const handleActiveToggle = () => this.props.handleActiveToggle(clazz)

    return (
      <div className={css.manageClassRow}>
        <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span>
        <span className={css.manageClassName}>
          {clazz.active ? clazz.name : <strike>{clazz.name}</strike>}
        </span>
        <span className={css.manageClassButtons}>
          <button className={'textButton'} onClick={handleActiveToggle}>{clazz.active ? 'Archive' : 'Unarchive'}</button>
          <button className={'textButton'} onClick={handleCopy}>Copy</button>
        </span>
      </div>
    )
  }
}

const SortableClassRow = SortableElement(UnsortableClassRow)

export default SortableClassRow
