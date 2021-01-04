import React from 'react'
import Select from 'react-select'
import { withFormsy } from 'formsy-react'

class SelectInput extends React.Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
    this.state = {
      loading: true
    }
    this.options = []
  }

  componentDidMount () {
    this.props.loadOptions((options) => {
      this.setState({
        loading: false,
        options: options
      })
    })
  }

  changeValue (option) {
    this.props.setValue(option)
    this.props.onChange(option)
  }

  render () {
    const { loading, options } = this.state
    const { placeholder, disabled } = this.props
    let className = 'select-input'
    if (this.props.value) {
      className += ' valid'
    }

    return (
      <div className={className}>
        <Select
          placeholder={placeholder}
          loading={loading}
          options={options}
          isSearchable
          disabled={disabled}
          value={this.props.value || ''}
          onChange={this.changeValue}
          clearable={false}
        />
        {this.props.errorMessage ? <div className='input-error'>{this.props.errorMessage}</div> : undefined}
      </div>
    )
  }
}

export default withFormsy(SelectInput)
