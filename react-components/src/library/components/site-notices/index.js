import React from 'react'
import Notices from './notices'

import css from './style.scss'

export default class SiteNotices extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      notices: [],
      receivedData: false
    }
    this.getPortalData = this.getPortalData.bind(this)
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
          notices: data,
          receivedData: true
        })
      },
      error: () => {
        console.error(`GET ${dataUrl} failed, can't render notices`)
      }
    })
  }

  render () {
    const { notices, receivedData } = this.state
    return (
      <div className={css.adminSiteNotices}>
        <h1>Notices</h1>
        <Notices notices={notices} receivedData={receivedData} />
        <div className={css.adminSiteNoticesCreate + ' floatR'}>
          <a href='/admin/site_notices/new' className='button'>Create New Notice</a>
        </div>
      </div>
    )
  }
}

SiteNotices.defaultProps = {
  // This path will return all site notices.
  dataUrl: Portal.API_V1.SITE_NOTICES_INDEX,
  // If initialData is not provided, component will use API (dataUrl) to get it.
  initialData: null
}
