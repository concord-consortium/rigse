import React from 'react'
import formatDate from '../../helpers/format-date'

import css from './style.scss'

export default class Notice extends React.Component {
  constructor (props) {
    super(props)
    this.handleDelete = this.handleDelete.bind(this)
  }

  handleDelete () {
    const { notice } = this.props
    const deleteUrl = '/api/v1/site_notices/' + notice.id + '/remove_notice'
    const authToken = jQuery('meta[name="csrf-token"]').attr('content')
    if (window.confirm('Are you sure you want to delete this notice?')) {
      jQuery.ajax({
        url: deleteUrl,
        type: 'delete',
        data: 'authenticity_token=' + encodeURIComponent(authToken),
        success: data => {},
        error: () => {
          console.error(`DELETE failed, can't delete notice`)
        }
      })
    }
    return false
  }

  render () {
    const { notice } = this.props
    const editLinkUrl = '/admin/site_notices/' + notice.id + '/edit'
    const deleteLinkId = 'delete_' + notice.id
    return (
      <tr id={notice.id} className={css.adminSiteNoticesListItem}>
        <td className={css.adminSiteNoticesListItemText} dangerouslySetInnerHTML={{ __html: notice.notice_html }} />
        <td className={css.adminSiteNoticesListDate}>
          {formatDate(notice.updated_at.slice(0, 10))}
        </td>
        <td className={css.adminSiteNoticesListItemOptions}>
          <span className={css.adminSiteNoticesListItemEdit}>
            <a href={editLinkUrl}>edit</a>
          </span>
          <span className={css.adminSiteNoticesListItemDelete}>
            <a className='rollover' href='#' id={deleteLinkId} onClick={this.handleDelete} title='Delete Notice'>
              <img alt='Delete Notice' src='/assets/delete.png' title='Delete Notice' />
            </a>
          </span>
        </td>
      </tr>
    )
  }
}
