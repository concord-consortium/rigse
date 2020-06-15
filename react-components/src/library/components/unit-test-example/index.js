import React from 'react'
import DisplayText from './display-text'

/*
* See `README.md` in this folder for documentation.
*/

export default class UnitTestExample extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      settings: Object.assign({}, props)
    }
  }

  render () {
    return (
      <div>
        <h2>Unit Testing Example</h2>
        <div>
          <span>
            <h3>Description:</h3>
            <p>
              This little page is a React component which serves exactly one
              purpose. That purpose is to display another React component,
              called DisplayText, which is located in this same directory,
              where this component lives.
            </p>
            <p>
              The purpose of that component is to provide a little hunk of
              React code to serve as our code-under-test. We are using this
              tiny React component to verify our unit testing framework is
              actually working.
            </p>
          </span>
        </div>
        <div>
          <h3>DisplayText:</h3>
          <DisplayText label={this.props.label} value={this.props.value} />
        </div>
      </div>
    )
  }
}
