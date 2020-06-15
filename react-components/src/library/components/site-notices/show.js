import React from 'react'
import formatDate from '../../helpers/format-date'

import css from './style.scss'

export default class ShowSiteNotices extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      notices: [],
      noNotice: props.noNotice,
      noticeDisplay: props.noticeDisplay,
      toggleDisplayPath: Portal.API_V1.SITE_NOTICES_TOGGLE_DISPLAY
    }
    this.getPortalData = this.getPortalData.bind(this)
    this.handleDelete = this.handleDelete.bind(this)
    this.handleToggle = this.handleToggle.bind(this)
    this.renderRow = this.renderRow.bind(this)
  }

  componentDidMount () {
    const { dataUrl, initialData } = this.props
    if (dataUrl && !initialData) {
      this.getPortalData()
    }
  }

  getPortalData () {
    const { dataUrl } = this.props
    jQuery.ajax({
      url: dataUrl,
      success: data => {
        this.setState({
          notices: data.notices,
          noticeDisplay: data.notice_display
        })
      },
      error: () => {
        console.error(`GET ${dataUrl} failed, can't render notices`)
      }
    })
  }

  handleDelete (notice) {
    const dismissUrl = '/api/v1/site_notices/' + notice.id + '/dismiss_notice'
    const authToken = jQuery('meta[name="csrf-token"]').attr('content')
    if (window.confirm('Are you sure you want to dismiss this notice?')) {
      jQuery.ajax({
        url: dismissUrl,
        type: 'post',
        data: 'authenticity_token=' + encodeURIComponent(authToken),
        success: data => {},
        error: () => {
          console.error(`POST failed, can't dismiss notice`)
        }
      })
    }
    return false
  }

  handleToggle () {
    const { noticeDisplay, toggleDisplayPath } = this.state
    jQuery.ajax({
      url: toggleDisplayPath,
      method: 'post',
      success: data => {},
      error: () => {
        console.error(`POST ${toggleDisplayPath} failed`)
      }
    })
    if (noticeDisplay === 'collapsed') {
      this.setState({ noticeDisplay: '' })
    } else {
      this.setState({ noticeDisplay: 'collapsed' })
    }
  }

  renderRow (notice) {
    let noticeRowId = 'admin__site_notice_' + notice.id
    return (
      <tr key={notice.id} id={noticeRowId}>
        <td>
          {formatDate(notice.created_at.slice(0, 10))}
        </td>
        <td dangerouslySetInnerHTML={{ __html: notice.notice_html }} />
        <td>
          <a href='#' onClick={() => this.handleDelete(notice)} title='Dismiss'>x</a>
        </td>
      </tr>
    )
  }

  render () {
    const { notices, noNotice, noticeDisplay } = this.state
    if (noNotice) {
      return (
        <div>
          There are currently no notices.
        </div>
      )
    }

    let siteNoticesContainerClasses = [css.siteNoticesListContainer, 'webkit_scrollbars']
    let toggleText = 'Hide Notices'
    if (noticeDisplay === 'collapsed') {
      siteNoticesContainerClasses.push(css.collapsed)
      toggleText = 'Show Notices'
    }
    let siteNoticesContainerClass = siteNoticesContainerClasses.join(' ')

    return (
      <div id={css.siteNotices} className={css.siteNotices}>
        <div className={css.siteNoticesTop}>
          <div className={css.siteNoticesToggle}>
            <a href='#' id='oHideShowLink' onClick={this.handleToggle} title={toggleText}>{toggleText}</a>
          </div>
          <div className={css.siteNoticesHeader}>
            Notices
          </div>
          <div className={siteNoticesContainerClass}>
            <table className={css.siteNoticesList} id={css.all_notice_to_render}>
              <tbody>
                { notices.map(this.renderRow) }
              </tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }
}

ShowSiteNotices.defaultProps = {
  // This path will return all site notices for logged in user.
  dataUrl: Portal.API_V1.GET_NOTICES_FOR_USER,
  // If initialData is not provided, component will use API (dataUrl) to get it.
  initialData: null
}
