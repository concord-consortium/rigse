import React from 'react'
import SelectAsync from 'react-select/async'
import { withFormsy } from 'formsy-react'

class SelectInput extends React.Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
  }

  changeValue (option) {
    this.props.setValue(option && option.value)
    this.props.onChange(option)
  }

  render () {
    const { placeholder, loadOptions, disabled } = this.props
    let className = 'select-input'
    if (this.props.value) {
      className += ' valid'
    }

    return (
      <div className={className}>
        <SelectAsync
          placeholder={placeholder}
          loadOptions={loadOptions}
          disabled={disabled}
          value={this.props.value || ''}
          onChange={this.changeValue}
          clearable={false}
        >
          <div className='input-error'>
            {this.props.errorMessage}
          </div>
        </SelectAsync>
      </div>
    )
  }
}

export default withFormsy(SelectInput)
