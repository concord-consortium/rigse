import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react';
import AutoSuggest from 'components/search/auto-suggest';
import { mockJqueryAjaxSuccess } from '../../helpers/mock-jquery';

describe('When I try to render autosuggest', () => {
  mockJqueryAjaxSuccess({
    search_term: 'test',
    suggestions: ['test 1', 'test 2', 'test 3']
  });

  it('should render with default props', () => {
    render(<AutoSuggest />);
    expect(screen.getByRole('textbox')).toHaveValue('');
    expect(screen.getByDisplayValue('Go')).toBeInTheDocument();
  });

  it('should render with a query prop and show the suggestions', async () => {
    render(<AutoSuggest query="test" />);
    expect(screen.getByRole('textbox')).toHaveValue('test');

    expect(screen.getByText('test 1')).toBeInTheDocument();
    expect(screen.getByText('test 2')).toBeInTheDocument();
    expect(screen.getByText('test 3')).toBeInTheDocument();
  });

  it('should search on input change and show the suggestions', async () => {
    render(<AutoSuggest />);
    const input = screen.getByRole('textbox');

    fireEvent.change(input, { target: { value: 'test' } });

    expect(screen.getByText('test 1')).toBeInTheDocument();
    expect(screen.getByText('test 2')).toBeInTheDocument();
    expect(screen.getByText('test 3')).toBeInTheDocument();
  });

  describe('after a non-zero result search', () => {
    it('should handle navigation keys', async () => {
      const onChange = jest.fn();
      const onSubmit = jest.fn();
      render(<AutoSuggest query="test" onChange={onChange} onSubmit={onSubmit} />);
      const input = screen.getByRole('textbox');

      fireEvent.change(input, { target: { value: 'test query' } });

      // suggestions should show
      expect(screen.getByText('test 1')).toBeInTheDocument();

      // down arrow selects first
      fireEvent.keyDown(input, { keyCode: 40 });

      // down arrow selects next
      fireEvent.keyDown(input, { keyCode: 40 });

      // up arrow selects first
      fireEvent.keyDown(input, { keyCode: 38 });

      // up arrow at top hides suggestions
      fireEvent.keyDown(input, { keyCode: 38 });
      // up arrow at top hides suggestions
      expect(screen.queryByText('test 1')).not.toBeInTheDocument();

      // down arrow shows suggestions
      fireEvent.keyDown(input, { keyCode: 40 });
        expect(screen.getByText('test 1')).toBeInTheDocument();

      // escape hides suggestions
      fireEvent.keyDown(input, { keyCode: 27 });
      expect(screen.queryByText('test 1')).not.toBeInTheDocument();

      // enter after showing and selecting second suggestion hides the suggestions and invokes both callbacks
      onChange.mockClear()
      fireEvent.keyDown(input, { keyCode: 40 });
      fireEvent.keyDown(input, { keyCode: 40 });
      fireEvent.keyDown(input, { keyCode: 13 });

      expect(onChange).toHaveBeenCalledWith('test 2');
      expect(onSubmit).toHaveBeenCalledWith('test 2');
    });

    it('should handle mouse clicks on suggestions', async () => {
      const onSubmit = jest.fn();
      render(<AutoSuggest query="test" onSubmit={onSubmit} />);
      const input = screen.getByRole('textbox');

      fireEvent.change(input, { target: { value: 'test' } });

      expect(screen.getByText('test 1')).toBeInTheDocument();

      fireEvent.click(screen.getByText('test 1'));
      expect(onSubmit).toHaveBeenCalledWith('test 1');

      fireEvent.change(input, { target: { value: 'test' } });
      expect(screen.getByText('test 2')).toBeInTheDocument();

      fireEvent.click(screen.getByText('test 2'));
      expect(onSubmit).toHaveBeenCalledWith('test 2');
    });
  });

  describe('after a zero-result search', () => {
    mockJqueryAjaxSuccess({
      search_term: 'test',
      suggestions: []
    });

    it('should handle navigation keys', async () => {
      const onChange = jest.fn();
      const onSubmit = jest.fn();
      render(<AutoSuggest query="test" onChange={onChange} onSubmit={onSubmit} />);
      const input = screen.getByRole('textbox');

      fireEvent.change(input, { target: { value: 'test query' } });

      expect(screen.queryByText('test 1')).not.toBeInTheDocument();

      fireEvent.keyDown(input, { keyCode: 40 });
      expect(screen.queryByText('test 1')).not.toBeInTheDocument();

      fireEvent.keyDown(input, { keyCode: 38 });
      expect(screen.queryByText('test 1')).not.toBeInTheDocument();

      fireEvent.keyDown(input, { keyCode: 27 });
      expect(screen.queryByText('test 1')).not.toBeInTheDocument();

      onChange.mockClear()
      onSubmit.mockClear()
      fireEvent.keyDown(input, { keyCode: 13 });
      expect(onSubmit).toHaveBeenCalledWith('test query');
      expect(onChange).not.toHaveBeenCalled();
    });
  });
});
