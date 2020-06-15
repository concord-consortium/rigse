import React from 'react'

export default class SideInfo extends React.Component {
  render () {
    return (
      <div>
        <div className='side-info-header'>
          Why sign up?
          <p>
            It's free and you get access to several key features:
          </p>
          <ul>
            <li>Create classes for your students and assign them activities</li>
            <li>Save student work</li>
            <li>Track student progress through activities</li>
          </ul>
        </div>
      </div>
    )
  }
}
