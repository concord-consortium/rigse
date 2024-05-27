import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/common/external-rep... Remove this comment to see the full error message
import ExternalReportButton, { generateJQueryForm } from 'components/common/external-report-button';
import nock from 'nock';

describe('ExternalReportButton', () => {
  const queryParams = { teachers: 1, otherParam: 'abc' };
  const isDisabled = false;
  const postToUrlMock = jest.fn();
  const queryUrl = 'http://query-test.concord.org';
  const queryJson = { fakeQueryJson: true };
  const querySignature = 'fakeQueryHMACSignature';

  const reportUrl = 'http://log-puller-test.concord.org';

  beforeEach(() => {
    postToUrlMock.mockClear();
  });

  it('displays the label', () => {
    render(
      <ExternalReportButton
        label='test label'
        reportUrl={reportUrl}
        queryUrl={queryUrl}
        isDisabled={isDisabled}
        queryParams={queryParams}
        postToUrl={postToUrlMock}
      />
    );

    expect(screen.getByRole('button', { name: 'test label' })).toBeInTheDocument();
  });

  it('does not disable the button when there are query params', () => {
    render(
      <ExternalReportButton
        label='test label'
        reportUrl={reportUrl}
        queryUrl={queryUrl}
        isDisabled={isDisabled}
        queryParams={queryParams}
        postToUrl={postToUrlMock}
      />
    );

    const button = screen.getByRole('button', { name: 'test label' });
    expect(button).not.toBeDisabled();
  });

  describe('when there are no query params', () => {
    it('disables the button', () => {
      render(
        <ExternalReportButton
          label='test disabled'
          reportUrl={reportUrl}
          queryUrl={queryUrl}
          isDisabled={true}
          queryParams={{}}
          postToUrl={postToUrlMock}
        />
      );

      const button = screen.getByRole('button', { name: 'test disabled' });
      expect(button).toBeDisabled();
    });
  });

  describe('when clicked', () => {
    it('issues request to queryURL, gets a signed query and finally posts to the report URL', async () => {
      const logsQueryRequest = nock(queryUrl)
        .defaultReplyHeaders({ 'access-control-allow-origin': '*' })
        .get('/')
        .query(queryParams)
        .reply(200, { json: queryJson, signature: querySignature });

      render(
        <ExternalReportButton
          label='test label'
          reportUrl={reportUrl}
          queryUrl={queryUrl}
          isDisabled={isDisabled}
          queryParams={queryParams}
          postToUrl={postToUrlMock}
        />
      );

      const button = screen.getByRole('button', { name: 'test label' });
      fireEvent.click(button);

      await waitFor(() => expect(logsQueryRequest.isDone()).toBeTruthy());
      expect(postToUrlMock).toBeCalledWith(reportUrl, queryJson, querySignature, undefined, undefined);
    });

    it('includes the portal token in the post to the report URL if it exists', async () => {
      const portalToken = 'testtoken';
      const logsQueryRequest = nock(queryUrl)
        .defaultReplyHeaders({ 'access-control-allow-origin': '*' })
        .get('/')
        .query(queryParams)
        .reply(200, { json: queryJson, signature: querySignature, portalToken });

      render(
        <ExternalReportButton
          label='test label'
          reportUrl={reportUrl}
          queryUrl={queryUrl}
          isDisabled={isDisabled}
          queryParams={queryParams}
          postToUrl={postToUrlMock}
          portalToken={portalToken}
        />
      );

      const button = screen.getByRole('button', { name: 'test label' });
      fireEvent.click(button);

      await waitFor(() => expect(logsQueryRequest.isDone()).toBeTruthy());
      expect(postToUrlMock).toBeCalledWith(reportUrl, queryJson, querySignature, undefined, portalToken);
    });
  });

  describe('when the query contains a value that includes a single quote', () => {
    it('escapes the generated form correctly', () => {
      const json = { query: "What's up doc?" };
      const portalToken = 'testtoken';
      const form = generateJQueryForm(reportUrl, json, querySignature, portalToken);
      expect(form.html()).toBe(
        `<input type="hidden" name="allowDebug" value="1"><input type="hidden" name="json" value="{&quot;query&quot;:&quot;What's up doc?&quot;}"><input type="hidden" name="signature" value="fakeQueryHMACSignature"><input type="hidden" name="jwt" value="testtoken">`
      );
    });
  });
});
