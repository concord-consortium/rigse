/* globals jest describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import ExternalReportButton from 'components/common/external-report-button'
import {generateJQueryForm} from 'components/common/external-report-button'
import nock from 'nock'

Enzyme.configure({adapter: new Adapter()})

describe('ExternalReportButton', () => {
  const queryParams = { teachers: 1, otherParam: 'abc' }
  const isDisabled = false
  const postToUrlMock = jest.fn()
  const queryUrl = 'http://query-test.concord.org'
  const queryJson = {fakeQueryJson: true}
  const querySignature = 'fakeQueryHMACSignature'

  const reportUrl = 'http://log-puller-test.concord.org'

  const wrapper = Enzyme.shallow(
    <ExternalReportButton label='test label' reportUrl={reportUrl} queryUrl={queryUrl} isDisabled={isDisabled} queryParams={queryParams} postToUrl={postToUrlMock} />
  )

  it('displays the label', () => {
    expect(wrapper.html()).toEqual(expect.stringContaining('test label'))
  })

  it('does not disable the button when there are query params', () => {
    expect(wrapper.find('input').html()).toEqual('<input type="submit" style="margin-right:10px" value="test label"/>');
  })

  describe('when there are no query params', () => {
    const queryParams = {}
    const isDisabled = true
    const wrapper = Enzyme.shallow(
      <ExternalReportButton label='test disabled' reportUrl={reportUrl} queryUrl={queryUrl} isDisabled={isDisabled} queryParams={queryParams} postToUrl={postToUrlMock} />
    )

    it('disables the button', () => {
      expect(wrapper.find('input').html()).toEqual('<input type="submit" style="margin-right:10px" disabled="" value="test disabled"/>');
    })
  })

  describe('when clicked', () => {
    it('issues request to queryURL, gets a signed query and finally posts to the report URL', (done) => {
      const logsQueryRequest = nock(queryUrl)
        .defaultReplyHeaders({ 'access-control-allow-origin': '*' })
        .get('/')
        .query(queryParams)
        .reply(200, {json: queryJson, signature: querySignature})

      const postToUrlMock = jest.fn()
      const wrapper = Enzyme.shallow(
        <ExternalReportButton label='test label' reportUrl={reportUrl} queryUrl={queryUrl} isDisabled={isDisabled} queryParams={queryParams} postToUrl={postToUrlMock} />
      )

      const eventMock = { preventDefault: jest.fn() }
      wrapper.simulate('click', eventMock)

      expect(eventMock.preventDefault).toBeCalled()

      setTimeout(() => {
        // This will ensure that logsQueryRequest has been done.
        logsQueryRequest.done()
        // Note that it's impossible to use Nock to check second POST request, because JSDOM doesn't implement
        // form.submit() function. That's browser navigation and JSODM doesn't seem to handle it.
        expect(postToUrlMock).toBeCalledWith(reportUrl, queryJson, querySignature, undefined)
        done()
      }, 100)
    })

    it('includes the portal token in the post to the report URL if it exists', (done) => {
      const postToUrlMock = jest.fn()
      const portalToken = "testtoken"
      const wrapper = Enzyme.shallow(
        <ExternalReportButton label='test label' reportUrl={reportUrl} queryUrl={queryUrl} isDisabled={isDisabled} queryParams={queryParams} postToUrl={postToUrlMock} portalToken={portalToken} />
      )

      const logsQueryRequest = nock(queryUrl)
        .defaultReplyHeaders({ 'access-control-allow-origin': '*' })
        .get('/')
        .query(queryParams)
        .reply(200, {json: queryJson, signature: querySignature, portalToken})

      const eventMock = { preventDefault: jest.fn() }
      wrapper.simulate('click', eventMock)

      expect(eventMock.preventDefault).toBeCalled()

      setTimeout(() => {
        // This will ensure that logsQueryRequest has been done.
        logsQueryRequest.done()
        // Note that it's impossible to use Nock to check second POST request, because JSDOM doesn't implement
        // form.submit() function. That's browser navigation and JSODM doesn't seem to handle it.
        expect(postToUrlMock).toBeCalledWith(reportUrl, queryJson, querySignature, portalToken)
        done()
      }, 100)
    })
  })

  describe('when the query contains a value that includes a single quote', () => {
    it('escapes the generated form correctly', () => {
      const json = {query: "What's up doc?"}
      const portalToken = "testtoken"
      const form = generateJQueryForm(reportUrl, json, querySignature, portalToken);
      expect(form.html()).toBe("<input type=\"hidden\" name=\"allowDebug\" value=\"1\"><input type=\"hidden\" name=\"json\" value=\"{&quot;query&quot;:&quot;What's up doc?&quot;}\"><input type=\"hidden\" name=\"signature\" value=\"fakeQueryHMACSignature\"><input type=\"hidden\" name=\"portal_token\" value=\"testtoken\">");
    })
  })
})
