import React from 'react'
import pluralize from './pluralize'
import humanize from './humanize'

export default class FormErrors extends React.Component<any, any> {
  render () {
    const errors = this.props.errors || {}
    const errorKeys = Object.keys(errors)
    const numErrors = errorKeys.length
    if (numErrors === 0) {
      return null
    }

    return (
      <div className='errorExplanation' id='errorExplanation'>
        <h2>{numErrors} {pluralize(numErrors, 'error')} prohibited this form from being saved</h2>
        <p>
          There {pluralize(numErrors, 'was a problem', 'were problems')} with the following {pluralize(numErrors, 'field')}:
        </p>
        <ul>
          {errorKeys.map((errorKey) => {
            return (
              <li>
                {`${humanize(errorKey)} ${errors[errorKey].join(' and ')}`}
              </li>
            )
          })}
        </ul>
      </div>
    )
  }
}
