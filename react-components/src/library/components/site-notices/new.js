import React from 'react'

import css from './style.scss'

export default class SiteNoticesNewForm extends React.Component {
  render () {
    const authToken = jQuery('meta[name="csrf-token"]').attr('content')
    return (
      <div className={css.adminSiteNoticesEdit}>
        <h1>Create Notice</h1>
        <form acceptCharset='UTF-8' action={Portal.API_V1.SITE_NOTICES_CREATE} method='post'>
          <div id='editor' className={css.adminSiteNoticesEditEditor}>
            <textarea className={css.tinymce_textarea} rows='40' name='notice_html' value='' />
          </div>
          <div className={css.adminSiteNoticesEditBackLink}>
            <a href='/admin/site_notices'>Cancel</a>
          </div>
          <div className={css.adminSiteNoticesEditSubmit}>
            <input name='utf8' type='hidden' value='✓' />
            <input name='authenticity_token' type='hidden' value={authToken} />
            <input className='pie' name='commit' type='submit' value='Publish Notice' />
          </div>
        </form>
      </div>
    )
  }
}
