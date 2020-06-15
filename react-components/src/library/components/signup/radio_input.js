import React from 'react'
import { withFormsy } from 'formsy-react'

class RadioInput extends React.Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
  }

  renderOptions (options) {
    return options.map((option, index) => (
      <label key={index}>
        <input type='radio' onChange={this.changeValue} value={option.value} name={this.props.name} checked={this.props.value === option.value} /> {option.label}
      </label>
    ))
  }

  changeValue (e) {
    console.log('INFO RadioInput changeValue', e)
    if (this.props.handleChange) {
      this.props.handleChange(e)
    }
    this.props.setValue(e.currentTarget.value)
  }

  render () {
    return (
      <div className='radio-input stacked'>
        <div className='title inline'>
          {this.props.title}
        </div>
        {this.renderOptions(this.props.options)}
      </div>
    )
  }
}

export default withFormsy(RadioInput)
