/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { pack } from "../../helpers/pack"
import EditMaterialsCollectionList from "../../../../src/library/components/materials-collection/edit-list"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render sortable material collection items', () => {

  const clone = (obj) => JSON.parse(JSON.stringify(obj))

  const collection = {
    id: 1,
    name: "Test Materials Collection"
  }

  const singleItem = [
    {
      id: 1,
      name: "Material Collection Item",
      url: "/eresources/1",
      is_archived: false
    }
  ]

  const multipleItems = [
    {
      id: 1,
      name: "Material Collection Item #1",
      url: "/eresources/1",
      is_archived: false
    },
    {
      id: 2,
      name: "Material Collection Item #2",
      url: "/eresources/2",
      is_archived: true
    },
    {
      id: 3,
      name: "Material Collection Item #3",
      url: "/eresources/3",
      is_archived: false
    }
  ]

  const renderedZeroItems = pack(`
    <p>
      No materials have been added to this collection.  To add materials use the <a href="/search">search page</a> and then click on the "Add to Collection" button on the search result.
    </p>
  `)

  const renderedSingleItem = pack(`
    <div class="editMaterialsCollectionsList">
      <div class="editMaterialsCollectionsListRow">
        <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
        <span class="editMaterialsCollectionsListRowName">
          <a href="/eresources/1">Material Collection Item</a>
        </span>
        <span class="editMaterialsCollectionsListRowButtons">
          <button>Delete</button>
        </span>
      </div>
    </div>
  `)

  const renderedMultipleItems = pack(`
    <div class="editMaterialsCollectionsList">
      <div class="editMaterialsCollectionsListRow">
        <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
        <span class="editMaterialsCollectionsListRowName">
          <a href="/eresources/1">Material Collection Item #1</a>
        </span>
        <span class="editMaterialsCollectionsListRowButtons">
          <button>Delete</button>
        </span>
      </div>
      <div class="editMaterialsCollectionsListRow">
        <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
        <span class="editMaterialsCollectionsListRowName">
          <a href="/eresources/2">Material Collection Item #2</a>
          <div class="archived"><i class="fa fa-archive"></i> (archived)</div>
        </span>
        <span class="editMaterialsCollectionsListRowButtons">
          <button>Delete</button>
        </span>
      </div>
      <div class="editMaterialsCollectionsListRow">
        <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
        <span class="editMaterialsCollectionsListRowName">
          <a href="/eresources/3">Material Collection Item #3</a>
        </span>
        <span class="editMaterialsCollectionsListRowButtons">
          <button>Delete</button>
        </span>
      </div>
    </div>
  `)

  mockJqueryAjaxSuccess({
    success: true
  })

  it("should render 0 items", () => {
    const editList = Enzyme.mount(<EditMaterialsCollectionList collection={collection} items={[]} />);
    expect(editList.html()).toBe(renderedZeroItems)
  });

  it("should render 1 item", () => {
    const editList = Enzyme.mount(<EditMaterialsCollectionList collection={collection} items={singleItem} />);
    expect(editList.html()).toBe(renderedSingleItem);
  });

  it("should render multiple items", () => {
    const editList = Enzyme.mount(<EditMaterialsCollectionList collection={collection} items={multipleItems} />);
    expect(editList.html()).toBe(renderedMultipleItems);
  });

  it("should handle the delete button", () => {
    const editList = Enzyme.mount(<EditMaterialsCollectionList collection={collection} items={clone(singleItem)} />);
    const deleteButton = editList.find(".editMaterialsCollectionsListRowButtons").childAt(0)

    // before delete
    expect(editList.html()).toBe(renderedSingleItem);

    const savedConfirm = global.confirm

    // with cancel on the confirmation
    global.confirm = () => false
    deleteButton.simulate("click")
    editList.update()
    expect(editList.html()).toBe(renderedSingleItem);

    // with ok on the confirmation
    global.confirm = () => true
    deleteButton.simulate("click")
    editList.update()
    expect(editList.html()).toBe(renderedZeroItems);

    global.confirm = savedConfirm
  })
})
