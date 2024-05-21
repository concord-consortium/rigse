import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react';
import EditBookmarks from '../../../../src/library/components/bookmarks/edit';
import { mockJqueryAjaxSuccess } from '../../helpers/mock-jquery';

describe('When I try to render sortable bookmarks', () => {
  const clone = (obj) => JSON.parse(JSON.stringify(obj));

  const singleBookmark = [
    {
      id: 1,
      is_visible: true,
      name: 'Link 1',
      position: 0,
      url: 'http://example.com/1',
    },
  ];

  const multipleBookmarks = [
    {
      id: 1,
      is_visible: true,
      name: 'Link 1',
      position: 0,
      url: 'http://example.com/1',
    },
    {
      id: 2,
      is_visible: false,
      name: 'Link 2',
      position: 1,
      url: 'http://example.com/2',
    },
    {
      id: 3,
      is_visible: true,
      name: 'Link 3',
      position: 2,
      url: 'http://example.com/3',
    },
  ];

  mockJqueryAjaxSuccess({
    success: true,
  });

  it('should render 0 bookmarks', () => {
    render(<EditBookmarks classId={1} bookmarks={[]} />);
    expect(screen.getByText('Create Link')).toBeInTheDocument();
  });

  it('should render 1 bookmark', () => {
    render(<EditBookmarks classId={1} bookmarks={singleBookmark} />);
    expect(screen.getByText('Link 1')).toBeInTheDocument();
    expect(screen.getByText('Create Link')).toBeInTheDocument();
  });

  it('should render multiple bookmarks', () => {
    render(<EditBookmarks classId={1} bookmarks={multipleBookmarks} />);
    expect(screen.getByText('Link 1')).toBeInTheDocument();
    expect(screen.getByText('Link 2')).toBeInTheDocument();
    expect(screen.getByText('Link 3')).toBeInTheDocument();
  });

  it('should handle toggle to edit and then cancel', () => {
    render(<EditBookmarks classId={1} bookmarks={singleBookmark} />);

    const editButton = screen.getByText('Edit');
    fireEvent.click(editButton);

    expect(screen.getByPlaceholderText('Name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('URL')).toBeInTheDocument();

    const cancelButton = screen.getByText('Cancel');
    fireEvent.click(cancelButton);

    expect(screen.queryByPlaceholderText('Name')).not.toBeInTheDocument();
    expect(screen.queryByPlaceholderText('URL')).not.toBeInTheDocument();
  });

  it('should handle toggle to edit and then save', () => {
    render(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);

    const editButton = screen.getByText('Edit');
    fireEvent.click(editButton);

    const nameInput = screen.getByPlaceholderText('Name');
    const urlInput = screen.getByPlaceholderText('URL');
    const saveButton = screen.getByText('Save');

    fireEvent.change(nameInput, { target: { value: 'Updated Link Name' } });
    fireEvent.change(urlInput, { target: { value: 'http://example.com/updated' } });
    fireEvent.click(saveButton);

    expect(screen.getByText('Updated Link Name')).toBeInTheDocument();
    const updatedLink = screen.getByText('Updated Link Name').closest('a');
    expect(updatedLink).toHaveAttribute('href', 'http://example.com/updated');
  });

  it('should handle toggle to hide -> unhide -> hide', () => {
    render(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);

    const hideButton = screen.getByText('Hide');
    fireEvent.click(hideButton);

    expect(screen.getByText('Show')).toBeInTheDocument();

    fireEvent.click(screen.getByText('Show'));
    expect(screen.getByText('Hide')).toBeInTheDocument();

    fireEvent.click(screen.getByText('Hide'));
    expect(screen.getByText('Show')).toBeInTheDocument();
  });

  it('should handle the delete button', () => {
    render(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);
    const deleteButton = screen.getByText('Delete');

    // before delete
    expect(screen.getByText('Link 1')).toBeInTheDocument();

    global.confirm = jest.fn(() => false);
    fireEvent.click(deleteButton);
    expect(screen.getByText('Link 1')).toBeInTheDocument();

    global.confirm = jest.fn(() => true);
    fireEvent.click(deleteButton);
    expect(screen.queryByText('Link 1')).not.toBeInTheDocument();
  });
});

describe('When I try to create bookmarks', () => {
  mockJqueryAjaxSuccess({
    success: true,
    data: {
      id: 1,
      is_visible: true,
      name: 'New Link',
      position: 0,
      url: 'http://example.com/new',
    },
  });

  it('should handle the create button', () => {
    render(<EditBookmarks classId={1} bookmarks={[]} />);
    const createButton = screen.getByText('Create Link');

    expect(screen.getByText('Create Link')).toBeInTheDocument();

    fireEvent.click(createButton);

    expect(screen.getByPlaceholderText('Name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('URL')).toBeInTheDocument();
  });
});
