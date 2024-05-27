/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/privacy_poli... Remove this comment to see the full error message
import PrivacyPolicy from 'components/signup/privacy_policy';

describe('When I try to render signup privacy policy', () => {
  it("should render", () => {
    render(<PrivacyPolicy />);

    // Check for the presence of the privacy policy text and link
    expect(screen.getByText('By clicking Register!, you agree to our')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'privacy policy.' })).toHaveAttribute('href', 'https://concord.org/privacy-policy');
  });
});
