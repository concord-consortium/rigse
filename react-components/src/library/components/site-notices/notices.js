import React from 'react'
import Notice from './notice'

import css from './style.scss'

export default class Notices extends React.Component {
  render () {
    const { notices, receivedData } = this.props

    if (!receivedData) {
      return (
        <div>
          Loading notices...
        </div>
      )
    }

    if (notices.length === 0) {
      return (
        <div class={css.adminSiteNoticesNone}>
          You have no notices.<br />
          To create a notice click the "Create New Notice" button.
        </div>
      )
    }

    return (
      <table id={css.notice_list} className={css.adminSiteNoticesList}>
        <tbody>
          <tr>
            <th>
              Notice
            </th>
            <th>
              Updated
            </th>
            <th>
              Options
            </th>
          </tr>
          { notices.map(notice => <Notice key={notice.id} notice={notice} />) }
        </tbody>
      </table>
    )
  }
}
