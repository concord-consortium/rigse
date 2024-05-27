import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import MBFetchDataHOC from 'components/materials-bin/fetch-data-hoc';
import { mockJqueryAjaxSuccess } from '../../helpers/mock-jquery';
import createFactory from '../../../../src/library/helpers/create-factory';

const fetchedData = ['foo', 'bar', 'baz'];

class Wrapped extends React.Component<any, any> {
  constructor(props) {
    super(props);
    this.state = {
      wrappedState: true,
    };
  }

  render() {
    return <div>{JSON.stringify({ state: this.state, props: this.props })}</div>;
  }
}

const Wrapper = createFactory(
  MBFetchDataHOC(Wrapped, () => ({
    dataStateKey: 'foo',
    dataUrl: 'http://example.com/',
    requestParams: () => ({ baz: true }),
    processData: (data) => data.map((item) => item.toUpperCase()),
  }))
);

global.Portal = {
  currentUser: {
    isAdmin: false,
  },
  API_V1: {
    EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: 'http://query-test.concord.org',
  },
};

describe('When I try to render materials-bin fetch data HOC', () => {
  mockJqueryAjaxSuccess(fetchedData);

  it('should render with default props', async () => {
    render(<Wrapper wrapperProp={true} />);

    await waitFor(() => {
      expect(screen.getByText(
        '{"state":{"wrappedState":true},"props":{"wrapperProp":true,"children":{},"foo":null}}'
      )).toBeInTheDocument();
    });
  });

  it('should render with visible prop', async () => {
    render(<Wrapper wrapperProp={true} visible={true} />);

    await waitFor(() => {
      expect(screen.getByText(
        '{"state":{"wrappedState":true},"props":{"wrapperProp":true,"visible":true,"children":{},"foo":["FOO","BAR","BAZ"]}}'
      )).toBeInTheDocument();
    });
  });
});
