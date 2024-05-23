/* globals describe it expect */
import React from 'react';
import { render } from '@testing-library/react';
import SPagination from 'components/search/pagination';

const node = {
  value: 1,
  paging: (total, options) => {
    node.options = options;
  },
};
const pagingPluginFormat = (method) => node.options.onFormat.call(node, method);

describe('When I try to render search pagination', () => {
  beforeAll(() => {
    global.jQuery = jest.fn(() => node);
  });

  it('should render an empty div', () => {
    const info = {};
    const { container } = render(<SPagination info={info} />);
    expect(container.firstChild).toHaveClass('pagination');
    expect(container.firstChild).toBeEmptyDOMElement();
  });

  it('should use the jQuery paging plugin', () => {
    node.active = false;
    expect(pagingPluginFormat('block')).toBe("<span class='disabled'>1</span>");
    expect(pagingPluginFormat('next')).toBe('<span class="disabled">Next →</span>');
    expect(pagingPluginFormat('prev')).toBe('<span class="disabled">← Previous</span>');
    expect(pagingPluginFormat('first')).toBe('<span class="disabled">|&lt;</span>');
    expect(pagingPluginFormat('last')).toBe('<span class="disabled">&gt;|</span>');
    expect(pagingPluginFormat('leap')).toBe('');
    expect(pagingPluginFormat('fill')).toBe('');
    expect(pagingPluginFormat('')).toBe('');

    node.active = true;
    expect(pagingPluginFormat('block')).toBe("<em><a href='#' class='page'>1</a></em>");
    expect(pagingPluginFormat('next')).toBe("<a href='#' class='next'>Next →</a>");
    expect(pagingPluginFormat('prev')).toBe("<a href='#' class='prev'>← Previous</a>");
    expect(pagingPluginFormat('first')).toBe("<a href='#' class='first'>|&lt;</a>");
    expect(pagingPluginFormat('last')).toBe("<a href='#' class='last'>&gt;|</a>");
    expect(pagingPluginFormat('leap')).toBe('   ');
    expect(pagingPluginFormat('fill')).toBe('...');
    expect(pagingPluginFormat('')).toBe('');
  });
});
