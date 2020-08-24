/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { pack } from "../../helpers/pack"
import EditBookmarks from "../../../../src/library/components/bookmarks/edit"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

const renderedZeroBookmarks = '<div class="editBookmarksTable"></div><div><button>Create Link</button></div>'

const renderedSingleBookmark = pack(`
  <div class="editBookmarksTable">
    <div class="editBookmarkRow">
      <span class="iconCell">
        <span class="sortIcon icon-sort"></span>
      </span>
      <span class="editBookmarkName">
        <a href="http://example.com/1" target="_blank" rel="noopener">Link 1</a>
      </span>
      <span class="editBookmarkButtons">
        <button>Edit</button>
        <button>Hide</button>
        <button>Delete</button>
      </span>
    </div>
  </div>
  <div>
    <button>Create Link</button>
  </div>
`)

describe('When I try to render sortable bookmarks', () => {

  const clone = (obj) => JSON.parse(JSON.stringify(obj))

  const singleBookmark = [
    {
      id: 1,
      is_visible: true,
      name: "Link 1",
      position: 0,
      url: "http://example.com/1"
    }
  ]

  const multipleBookmarks = [
    {
      id: 1,
      is_visible: true,
      name: "Link 1",
      position: 0,
      url: "http://example.com/1"
    },
    {
      id: 2,
      is_visible: false,
      name: "Link 2",
      position: 1,
      url: "http://example.com/2"
    },
    {
      id: 3,
      is_visible: true,
      name: "Link 3",
      position: 2,
      url: "http://example.com/3"
    }
  ]

  mockJqueryAjaxSuccess({
    success: true
  })

  it("should render 0 bookmarks", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={[]} />);
    expect(editBookmarks.html()).toBe(renderedZeroBookmarks)
  });

  it("should render 1 bookmark", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={singleBookmark} />);
    expect(editBookmarks.html()).toBe(renderedSingleBookmark);
  });

  it("should render multiple bookmarks", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={multipleBookmarks} />);
    expect(editBookmarks.html()).toBe(pack(`
      <div class="editBookmarksTable">
        <div class="editBookmarkRow">
          <span class="iconCell">
            <span class="sortIcon icon-sort"></span>
          </span>
          <span class="editBookmarkName">
            <a href="http://example.com/1" target="_blank" rel="noopener">Link 1</a>
          </span>
          <span class="editBookmarkButtons">
            <button>Edit</button>
            <button>Hide</button>
            <button>Delete</button>
          </span>
        </div>
        <div class="editBookmarkRow">
          <span class="iconCell">
            <span class="sortIcon icon-sort"></span>
          </span>
          <span class="editBookmarkName">
            <strike>
              <a href="http://example.com/2" target="_blank" rel="noopener">Link 2</a>
            </strike>
          </span>
          <span class="editBookmarkButtons">
            <button>Edit</button>
            <button>Show</button>
            <button>Delete</button>
          </span>
        </div>
        <div class="editBookmarkRow">
          <span class="iconCell">
            <span class="sortIcon icon-sort"></span>
          </span>
          <span class="editBookmarkName">
            <a href="http://example.com/3" target="_blank" rel="noopener">Link 3</a>
          </span>
          <span class="editBookmarkButtons">
            <button>Edit</button>
            <button>Hide</button>
            <button>Delete</button>
          </span>
        </div>
      </div>
      <div>
        <button>Create Link</button>
      </div>
    `));
  });

  it("should handle toggle to edit and then cancel", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={singleBookmark} />);

    const editButton = editBookmarks.find(".editBookmarkButtons").childAt(0)
    editButton.simulate("click")
    editBookmarks.update()

    expect(editBookmarks.html()).toBe(pack(`
      <div class="editBookmarksTable">
        <div class="editBookmarkRow">
          <span class="editBookmarkName">
            <input type="text" placeholder="Name" value="Link 1">
            <input type="text" placeholder="URL" value="http://example.com/1">
          </span>
          <span class="editBookmarkButtons">
            <button>Save</button>
            <button>Cancel</button>
          </span>
        </div>
      </div>
      <div>
        <button>Create Link</button>
      </div>
    `))

    const cancelButton = editBookmarks.find(".editBookmarkButtons").childAt(1)
    cancelButton.simulate("click")
    editBookmarks.update()

    expect(editBookmarks.html()).toBe(pack(`
      <div class="editBookmarksTable">
        <div class="editBookmarkRow">
          <span class="iconCell">
            <span class="sortIcon icon-sort"></span>
          </span>
          <span class="editBookmarkName">
            <a href="http://example.com/1" target="_blank" rel="noopener">Link 1</a>
          </span>
          <span class="editBookmarkButtons">
            <button>Edit</button>
            <button>Hide</button>
            <button>Delete</button>
          </span>
        </div>
      </div>
      <div>
        <button>Create Link</button>
      </div>
    `));
  });

  it("should handle toggle to edit and then save", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);

    const editButton = editBookmarks.find(".editBookmarkButtons").childAt(0)
    editButton.simulate("click")
    editBookmarks.update()

    const nameInput = editBookmarks.find(".editBookmarkName").childAt(0)
    const urlInput = editBookmarks.find(".editBookmarkName").childAt(1)
    const saveButton = editBookmarks.find(".editBookmarkButtons").childAt(0)

    nameInput.instance().value = "Updated Link Name";
    urlInput.instance().value = "http://example.com/updated"

    saveButton.simulate("click")
    editBookmarks.update()

    expect(editBookmarks.html()).toBe(pack(`
      <div class="editBookmarksTable">
        <div class="editBookmarkRow">
          <span class="iconCell">
            <span class="sortIcon icon-sort"></span>
          </span>
          <span class="editBookmarkName">
            <a href="http://example.com/updated" target="_blank" rel="noopener">Updated Link Name</a>
          </span>
          <span class="editBookmarkButtons">
            <button>Edit</button>
            <button>Hide</button>
            <button>Delete</button>
          </span>
        </div>
      </div>
      <div>
        <button>Create Link</button>
      </div>
    `));
  });

  it("should handle toggle to hide -> unhide -> hide", () => {
    const renderedHiddenBookmark = pack(`
      <div class="editBookmarksTable">
        <div class="editBookmarkRow">
          <span class="iconCell">
            <span class="sortIcon icon-sort"></span>
          </span>
          <span class="editBookmarkName">
            <strike>
              <a href="http://example.com/1" target="_blank" rel="noopener">Link 1</a>
            </strike>
          </span>
          <span class="editBookmarkButtons">
            <button>Edit</button>
            <button>Show</button>
            <button>Delete</button>
          </span>
        </div>
      </div>
      <div>
        <button>Create Link</button>
      </div>
    `)

    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);

    const hideButton = editBookmarks.find(".editBookmarkButtons").childAt(1)

    hideButton.simulate("click")
    editBookmarks.update()
    expect(editBookmarks.html()).toBe(renderedHiddenBookmark);

    hideButton.simulate("click")
    editBookmarks.update()
    expect(editBookmarks.html()).toBe(renderedSingleBookmark)

    hideButton.simulate("click")
    editBookmarks.update()
    expect(editBookmarks.html()).toBe(renderedHiddenBookmark);
  })

  it("should handle the delete button", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);
    const deleteButton = editBookmarks.find(".editBookmarkButtons").childAt(2)

    // before delete
    expect(editBookmarks.html()).toBe(renderedSingleBookmark);

    const savedConfirm = global.confirm

    // with cancel on the confirmation
    global.confirm = () => false
    deleteButton.simulate("click")
    editBookmarks.update()
    expect(editBookmarks.html()).toBe(renderedSingleBookmark);

    // with ok on the confirmation
    global.confirm = () => true
    deleteButton.simulate("click")
    editBookmarks.update()
    expect(editBookmarks.html()).toBe(renderedZeroBookmarks);

    global.confirm = savedConfirm
  })
})

describe("When I try to create bookmarks", () => {
  mockJqueryAjaxSuccess({
    success: true,
    data: {
      id: 1,
      is_visible: true,
      name: "New Link",
      position: 0,
      url: "http://example.com/new"
    }
  })

  it("it should handle the create button", () => {
    const editBookmarks = Enzyme.mount(<EditBookmarks classId={1} bookmarks={[]} />);
    const createButton = editBookmarks.find("button").last()

    expect(editBookmarks.html()).toBe(renderedZeroBookmarks)

    createButton.simulate("click")
    editBookmarks.update()

    expect(editBookmarks.html()).toBe(pack(`
      <div class="editBookmarksTable">
        <div class="editBookmarkRow">
          <span class="editBookmarkName">
            <input type="text" placeholder="Name" value="New Link">
            <input type="text" placeholder="URL" value="http://example.com/new">
          </span>
          <span class="editBookmarkButtons">
            <button>Save</button>
            <button>Cancel</button>
          </span>
        </div>
      </div>
      <div>
        <button>Create Link</button>
      </div>
    `));
  })
})
