import React from 'react'
import jQuery from 'jquery'

// changed from string based form generation to using jQuery to fix issue with single quoted
// values in json field (it was delimited with single quotes and would break if the json
// contained values with single quotes)
export const generateJQueryForm = (url: any, json: any, signature: any, jwtFromReportController: any, portalToken: any) => {
  const form = jQuery('<form>', { action: url, method: 'POST', target: '_blank' })
    .append(jQuery('<input>', { type: 'hidden', name: 'allowDebug', value: '1' }))
    .append(jQuery('<input>', { type: 'hidden', name: 'json', value: JSON.stringify(json) }))
    .append(jQuery('<input>', { type: 'hidden', name: 'signature', value: signature }))
  if (jwtFromReportController) {
    form.append(jQuery('<input>', { type: 'hidden', name: 'jwt', value: jwtFromReportController }))
  }
  if (portalToken) {
    form.append(jQuery('<input>', { type: 'hidden', name: 'portal_token', value: portalToken }))
  }
  return form
}

const postToUrl = (url: any, json: any, signature: any, jwtFromReportController: any, portalToken: any) => {
  // Issue POST request to Log app. We can't use GET, as URL could get too long. Generating a fake
  // form is a way to send non-Ajax POST request and open the target page.
  const tempForm = generateJQueryForm(url, json, signature, jwtFromReportController, portalToken)
  tempForm.appendTo('body').submit()
  // Form uses target="_blank", so we remove this form to clean it up
  tempForm.remove()
}

export default class ExternalReportButton extends React.Component<any, any> {
  constructor (props: any) {
    super(props)
    this.handleClick = this.handleClick.bind(this)
  }

  render () {
    const { label, isDisabled } = this.props
    return <input style={{ marginRight: 10 }} type='submit' onClick={this.handleClick} disabled={isDisabled} value={label} />
  }

  handleClick (event: any) {
    const { reportUrl, queryUrl, queryParams, postToUrl, portalToken } = this.props
    // Make sure we don't submit a form if this component is part of a form (it's possible but not required).
    event.preventDefault()
    // Get the signed query JSON first.
    jQuery.ajax({
      type: 'GET',
      dataType: 'json',
      // jQuery.param nicely converts JS hash into query params string.
      url: `${queryUrl}?${jQuery.param(queryParams)}`,
      success: response => {
        postToUrl(reportUrl, response.json, response.signature, response.token, portalToken)
      },
      error: (jqXHR, textStatus, error) => {
        console.error('logs_query request failed', error)
        window.alert('Logs query generation failed. Please reload the page and try again.')
        this.setState({ disabled: false })
      }
    })
    this.setState({ disabled: true })
  }
}

// @ts-expect-error TS(2339): Property 'defaultProps' does not exist on type 'ty... Remove this comment to see the full error message
ExternalReportButton.defaultProps = {
    queryUrl: typeof Portal !== 'undefined' ? Portal.API_V1.EXTERNAL_RESEARCHER_REPORT_QUERY : '',
  postToUrl: postToUrl
}
