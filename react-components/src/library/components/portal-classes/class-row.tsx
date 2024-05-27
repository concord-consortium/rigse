import React from 'react'
import css from './style.scss'

class ClassRow extends React.Component<any, any> {
  render () {
    const { clazz } = this.props

    const handleCopy = () => this.props.handleCopy(clazz)
    const handleActiveToggle = () => this.props.handleActiveToggle(clazz)

    return (
      <div className={css.manageClassRow}>
        <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span>
        <span className={css.manageClassName}>
          {clazz.is_archived ? <del>{clazz.name}</del> : clazz.name}
        </span>
        <span className={css.manageClassButtons}>
          <button className={'textButton'} onClick={handleActiveToggle}>{clazz.is_archived ? 'Unarchive' : 'Archive'}</button>
          <button className={'textButton'} onClick={handleCopy}>Copy</button>
        </span>
      </div>
    )
  }
}

export default ClassRow
