import React from 'react'

export default class UserTypeSelector extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      userType: null
    }
    this.handleClick = this.handleClick.bind(this)
  }

  handleClick (event) {
    const value = event.currentTarget.value
    console.log('INFO changing type', value)
    ga('send', 'event', 'User Registration', 'Form', 'Step 1 Completed - ' + value.charAt(0).toUpperCase() + value.slice(1))
    this.props.onUserTypeSelect(value)
  }

  render () {
    console.log('INFO UserTypeSelector rendering')

    return (
      <div className='user-type-select'>
        <button onClick={this.handleClick} name='type' value='teacher'>
          I am a <strong>Teacher</strong>
        </button>
        <button onClick={this.handleClick} name='type' value='student'>
          I am a <strong>Student</strong>
        </button>
      </div>
    )
  }
}
