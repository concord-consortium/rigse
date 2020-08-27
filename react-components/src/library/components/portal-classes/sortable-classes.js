import React from 'react'
import { SortableContainer } from 'react-sortable-hoc'
import css from './style.scss'

import SortableClassRow from './sortable-class-row'

class UnsortableSortableClasses extends React.Component {
  render () {
    const { classes } = this.props
    if (classes.length === 0) {
      return null
    }

    return (
      <div className={css.manageClassesTable}>
        {classes.map((clazz, index) => (
          <SortableClassRow
            key={clazz.id}
            index={index}
            clazz={clazz}
            handleCopy={this.props.handleCopy}
            handleActiveToggle={this.props.handleActiveToggle}
          />
        ))}
      </div>
    )
  }
}

const SortableClasses = SortableContainer(UnsortableSortableClasses)

export default SortableClasses
