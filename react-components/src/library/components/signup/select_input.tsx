import React from 'react'
import Select from 'react-select'
import { withFormsy } from 'formsy-react'

class SelectInput extends React.Component<any, any> {
  options: any;
  constructor (props: any) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
    this.state = {
      loading: true
    }
    this.options = []
  }

  componentDidMount () {
    this.props.loadOptions((options: any) => {
      this.setState({
        loading: false,
        options: options
      })
    })
  }

  changeValue (option: any) {
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
          // @ts-expect-error TS(2322): Type '{ placeholder: any; loading: any; options: a... Remove this comment to see the full error message
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
