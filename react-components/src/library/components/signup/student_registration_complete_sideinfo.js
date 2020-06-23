import React from 'react'

export default class StudentRegistrationCompleteSideInfo extends React.Component {
  componentDidMount () {
    const authToken = jQuery('meta[name="csrf-token"]').attr('content')
    jQuery('form[method="post"]').each(() => {
      const $form = jQuery(this)
      const hiddenField = `<input type='hidden' name='authenticity_token' value='${authToken}' />`
      if ($form.find('input[name="authenticity_token"]').length === 0) {
        $form.prepend(hiddenField)
      }
    })
  }

  render () {
    return (
      <div>
        <div className='side-info-header'>
          Sign In
        </div>
        <form method='post' action='/users/sign_in' className='ng-pristine ng-valid'>
          <dl>
            <dt>Username</dt>
            <dd>
              <input name='user[login]' />
            </dd>
            <dt>Password</dt>
            <dd>
              <input type='password' name='user[password]' />
            </dd>
          </dl>
          <input className='button' type='submit' value='Log In' />
        </form>
      </div>
    )
  }
}
