/* globals jest describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
import UserReportForm from 'components/user-report-form';

// form uses Portal global
global.Portal = {
  currentUser: {
    isAdmin: false,
  },
  API_V1: {
    EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: 'http://query-test.concord.org'
  }
}

describe('UserReportForm', () => {
  const externalReports = [
    { url: 'url1', name: 'first', label: 'label1' },
    { url: 'url2', name: 'second', label: 'label2' }
  ];

  it('renders custom external report buttons', () => {
    render(<UserReportForm externalReports={externalReports} />);

    const externalReportButtons = screen.getAllByRole('button');
    expect(externalReportButtons).toHaveLength(2);
    expect(screen.getByText('label1')).toBeInTheDocument();
    expect(screen.getByText('label2')).toBeInTheDocument();
  });

  it('renders filter forms', () => {
    render(<UserReportForm externalReports={externalReports} />);

    expect(screen.getByText('Teachers')).toBeInTheDocument();
    expect(screen.getByText('Cohorts')).toBeInTheDocument();
    expect(screen.getByText('Resources')).toBeInTheDocument();
    expect(screen.getAllByText('Search...')).toHaveLength(3);

    expect(screen.getByText('Earliest date')).toBeInTheDocument();
    expect(screen.getByText('Latest date')).toBeInTheDocument();
  });
});
