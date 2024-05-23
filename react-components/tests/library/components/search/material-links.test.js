/* globals describe it expect */
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { SMaterialLinks, SGenericLink, SMaterialLink, SMaterialDropdownLink } from 'components/search/material-links';

describe('When I try to render search generic link', () => {
  it("should render with default props", () => {
    const link = {
      url: "http://example.com/url",
      text: "text"
    }
    render(<SGenericLink link={link} />);
    expect(screen.getByRole('link', { name: 'text' })).toHaveAttribute('href', 'http://example.com/url');
    expect(screen.getByRole('link', { name: 'text' })).toHaveClass('button');
  });

  it("should render with optional props", () => {
    const link = {
      url: "http://example.com/url",
      className: "className",
      target: "target",
      ccConfirm: "ccConfirm",
      text: "text"
    }
    render(<SGenericLink link={link} />);
    const linkElement = screen.getByRole('link', { name: 'text' });
    expect(linkElement).toHaveAttribute('href', 'http://example.com/url');
    expect(linkElement).toHaveClass('className');
    expect(linkElement).toHaveAttribute('target', 'target');
    expect(linkElement).toHaveAttribute('data-cc-confirm', 'ccConfirm');
  });
});

describe('When I try to render search material link', () => {
  it("should render with default props", () => {
    const link = {
      url: "http://example.com/url",
      text: "text"
    }
    render(<SMaterialLink link={link} />);
    const linkElement = screen.getByRole('link', { name: 'text' });
    expect(linkElement).toHaveAttribute('href', 'http://example.com/url');
    expect(linkElement).toHaveClass('button');
  });

  it("should render with optional props", () => {
    const link = {
      key: "key",
      url: "http://example.com/url",
      className: "className",
      target: "target",
      ccConfirm: "ccConfirm",
      text: "text"
    }
    render(<SMaterialLink link={link} />);
    const linkElement = screen.getByRole('link', { name: 'text' });
    expect(linkElement).toHaveAttribute('href', 'http://example.com/url');
    expect(linkElement).toHaveClass('className');
    expect(linkElement).toHaveAttribute('target', 'target');
    expect(linkElement).toHaveAttribute('data-cc-confirm', 'ccConfirm');
  });
});

describe('When I try to render search dropdown link', () => {
  it("should render with default props", () => {
    const link = {
      url: "http://example.com/url",
      text: "text",
      options: []
    }
    render(<SMaterialDropdownLink link={link} />);
    const linkElement = screen.getByRole('link', { name: 'text' });
    expect(linkElement).toHaveAttribute('href', 'http://example.com/url');
    expect(linkElement).toHaveClass('button');
  });

  it("should render with optional props", () => {
    const link = {
      key: "key",
      url: "http://example.com/url",
      className: "className",
      target: "target",
      ccConfirm: "ccConfirm",
      text: "text",
      options: [
        { url: "http://example.com/option1", text: "option 1" },
        { url: "http://example.com/option2", text: "option 2" }
      ]
    }
    render(<SMaterialDropdownLink link={link} />);
    const linkElement = screen.getByRole('link', { name: 'text' });
    expect(linkElement).toHaveAttribute('href', 'http://example.com/url');
    expect(linkElement).toHaveClass('className');
    expect(linkElement).toHaveAttribute('target', 'target');
    expect(linkElement).toHaveAttribute('data-cc-confirm', 'ccConfirm');
  });
});

describe('When I try to render search material links', () => {
  it("should render", () => {
    const links = [
      {
        key: "key1",
        url: "http://example.com/url",
        className: "className",
        target: "target",
        ccConfirm: "ccConfirm",
        text: "text1"
      },
      {
        type: "dropdown",
        key: "key2",
        url: "http://example.com/url2",
        className: "className",
        target: "target",
        ccConfirm: "ccConfirm",
        text: "text2",
        options: [
          { url: "http://example.com/option1", text: "option 1" },
          { url: "http://example.com/option2", text: "option 2" }
        ]
      }
    ]
    render(<SMaterialLinks links={links} />);

    const firstLink = screen.getByRole('link', { name: 'text1' });
    expect(firstLink).toHaveAttribute('href', 'http://example.com/url');
    expect(firstLink).toHaveClass('className');
    expect(firstLink).toHaveAttribute('target', 'target');
    expect(firstLink).toHaveAttribute('data-cc-confirm', 'ccConfirm');

    const dropdownLink = screen.getByRole('link', { name: 'text2' });
    expect(dropdownLink).toHaveAttribute('href', 'http://example.com/url2');
    expect(dropdownLink).toHaveClass('className');
    expect(dropdownLink).toHaveAttribute('target', 'target');
    expect(dropdownLink).toHaveAttribute('data-cc-confirm', 'ccConfirm');
  });
});
