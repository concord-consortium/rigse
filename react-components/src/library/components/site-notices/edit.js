import React from 'react'

import css from './style.scss'

export default class SiteNoticesEditForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      notice: this.props.notice
    }
  }

  render () {
    const { notice } = this.state
    if (!notice) {
      return (
        <div>
          Loading...
        </div>
      )
    }

    const formAction = '/api/v1/site_notices/' + notice.id
    const formId = 'edit_admin_site_notice_' + notice.id
    const authToken = jQuery('meta[name="csrf-token"]').attr('content')
    return (
      <div className={css.adminSiteNoticesEdit}>
        <h1>Edit Notice</h1>
        <form acceptCharset='UTF-8' action={formAction} method='post' id={formId}>
          <div id='editor' className={css.adminSiteNoticesEditEditor}>
            <textarea className='tinymce_textarea' rows='40' name='notice_html' defaultValue={notice.notice_html} />
          </div>
          <div className={css.adminSiteNoticesEditBackLink}>
            <a href='/admin/site_notices'>Cancel</a>
          </div>
          <div className={css.adminSiteNoticesEditSubmit}>
            <input name='utf8' type='hidden' value='✓' />
            <input name='_method' type='hidden' value='put' />
            <input name='authenticity_token' type='hidden' value={authToken} />
            <input className='pie' name='commit' type='submit' value='Update Notice' />
          </div>
        </form>
      </div>
    )
  }
}
