import React from 'react'
import css from './style.scss'

export default class Legend extends React.Component {
  render () {
    return (
      <div className={css.legend}>
        <div className={css.completed} /> Completed
        <div className={css.inProgress} /> In Progress
        <div className={css.notStarted} /> Not Yet Started
      </div>
    )
  }
}
