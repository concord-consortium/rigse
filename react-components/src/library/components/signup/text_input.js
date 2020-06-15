import React from 'react'
import { withFormsy } from 'formsy-react'

const TIMEOUT = 350

class TextInput extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      inputVal: '',
      _asyncValidationPassed: true
    }

    this.onChange = this.onChange.bind(this)
  }

  // With the change from React 15 mixins for Formsy to React 16 HOCs the async validation needed
  // to change as the HOC wraps this inner TextInput class and thus the form components that use
  // this component could not "reach in" and check isValidAsync(). This code adds the functions
  // that used to be accessible via the mixin to the `withFormsy` wrapper.  The wrapper is
  // set in the form render functions using asyncValidator() and wrapper is null on the initial
  // render which is why we check for it to go from null to non-null before adding the functions.
  //
  // While this is a little convoluted this was the change needed internally to minimize the
  // changes needed in the callers
  // eslint-disable-next-line
  UNSAFE_componentWillReceiveProps (nextProps) {
    if (nextProps.wrapper && !this.props.wrapper) {
      const wrapper = nextProps.wrapper
      const self = this

      wrapper.setValidations([
        () => self.state._asyncValidationPassed ? true : self.props.asyncValidationError
      ])

      wrapper.isValidAsync = () => {
        return this.props.isValid && this.state._asyncValidationPassed
      }

      wrapper.validateAsync = (value) => {
        if (!this.props.asyncValidation) {
          return
        }
        this.setState({
          _asyncValidationPassed: true
        })
        if (this._asyncValidationTimeoutID) {
          window.clearTimeout(this._asyncValidationTimeoutID)
        }
        if (value.length > 0) {
          this._asyncValidationTimeoutID = window.setTimeout(() => {
            this.props.asyncValidation(value).done(() => {
              self.setState({
                _asyncValidationPassed: true
              })
              wrapper.context.validate(wrapper)
            }).fail(function () {
              self.setState({
                _asyncValidationPassed: false
              })
              wrapper.setState({
                isValid: false,
                validationError: [self.props.asyncValidationError]
              })
            })
          }, this.props.asyncValidationTimeout)
        }
      }
    }
  }

  onChange (event) {
    let newVal = event.currentTarget.value
    this.setState({ _asyncValidationPassed: true }, () => {
      const delay = this.props.isValidValue(newVal) ? 0 : TIMEOUT

      this.setState({
        inputVal: newVal
      })

      if (this.timeoutID) {
        window.clearTimeout(this.timeoutID)
      }
      this.timeoutID = window.setTimeout(() => {
        if (this.props.processValue) {
          newVal = this.props.processValue(newVal)
        }
        this.props.setValue(newVal)
      }, delay)
      if (this.props.isValidValue(newVal) && this.props.wrapper) {
        this.props.wrapper.validateAsync(newVal)
      }
    })
  }

  render () {
    const { type, placeholder, disabled } = this.props

    let className = 'text-input ' + this.props.name
    if (this.props.showRequired && !this.props.isPristine) {
      className += ' required'
    }
    if (this.props.showError) {
      className += ' error'
    }
    if (this.props.wrapper && this.props.wrapper.isValidAsync()) {
      className += ' valid'
    }
    if (disabled) {
      className += ' disabled'
    }

    return (
      <div className={className}>
        <input
          type={type}
          onChange={this.onChange}
          value={this.state.inputVal}
          placeholder={placeholder}
          disabled={disabled}
        />
        <div className='input-error'>
          {this.state.inputVal.length === 0 ? undefined : this.props.errorMessage}
        </div>
      </div>
    )
  }
}

TextInput.defaultProps = {
  type: 'text',
  asyncValidationTimeout: 500,
  asyncValidationError: 'Async validation failed'
}

export const asyncValidator = (options) => {
  const { validator, error, ref } = options
  return {
    asyncValidation: validator,
    asyncValidationError: error,
    wrapper: ref
  }
}

export default withFormsy(TextInput)
