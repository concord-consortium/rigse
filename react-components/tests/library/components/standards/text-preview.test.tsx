/* globals describe it expect */
import React from 'react'
import { render, screen } from '@testing-library/react'
// @ts-expect-error TS(2307): Cannot find module 'components/standards/text-prev... Remove this comment to see the full error message
import TextPreview, { PREVIEW_LENGTH } from 'components/standards/text-preview'

const text = "this is a long string of text"

describe('When I try to render text preview', () => {
  it('exports PREVIEW_LENGTH', () => {
    expect(PREVIEW_LENGTH).toBe(17);
    expect(text.length).toBeGreaterThan(PREVIEW_LENGTH);
  });

  describe('with preview=false', () => {
    it("should not add an ellipsis", () => {
      render(<TextPreview config={{ text, preview: false }} />);
      expect(screen.getByText(text)).toBeInTheDocument();
      expect(screen.queryByText(`${text.substring(0, PREVIEW_LENGTH)} ...`)).not.toBeInTheDocument();
    });
  });

  describe('with preview=true', () => {
    it("should add an ellipsis", () => {
      render(<TextPreview config={{ text, preview: true }} />);
      expect(screen.getByText(`${text.substring(0, PREVIEW_LENGTH)} ...`)).toBeInTheDocument();
      expect(screen.queryByText(text)).not.toBeInTheDocument();
    });
  });
});
