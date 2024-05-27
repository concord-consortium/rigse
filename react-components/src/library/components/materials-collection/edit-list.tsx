import React from "react";
import { arrayMove } from "@dnd-kit/sortable";
import SortableMaterialsCollectionList from "./sortable-materials-collection-list";

export class EditMaterialsCollectionList extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.state = {
      items: props.items
    };

    this.handleDelete = this.handleDelete.bind(this);
    this.handleSortEnd = this.handleSortEnd.bind(this);
  }

  handleDelete (item: any) {
    if (window.confirm(`Remove ${item.name} from "${this.props.collection.name}"?`)) {
      const { items } = this.state;
      const index = items.indexOf(item);
      items.splice(index, 1);
      this.setState({ items });

      this.apiCall("remove_material", { data: { item_id: item.id } })
        .catch(err => {
          // add back on error
          items.splice(index, 0, item);
          this.setState({ items });
          this.showError(err, "Unable to delete item!");
        });
    }
  }

  handleSortEnd ({
    oldIndex,
    newIndex
  }: any) {
    let { items } = this.state;
    items = arrayMove(items, oldIndex, newIndex);
    this.setState({ items });

    const itemIds = items.map((item: any) => item.id);
    this.apiCall("sort_materials", { data: { item_ids: itemIds } })
      .catch(err => {
        this.setState({ items: arrayMove(items, newIndex, oldIndex) });
        this.showError(err, "Unable to save item sort order!");
      });
  }

  showError (err: any, message: any) {
    if (err.message) {
      window.alert(`${message}\n${err.message}`);
    } else {
      window.alert(message);
    }
  }

  apiCall (action: any, options: any) {
    const basePath = "/api/v1/materials_collections";
    const { collection } = this.props;
    const { data } = options;

    // @ts-expect-error TS(7053): Element implicitly has an 'any' type because expre... Remove this comment to see the full error message
    const { url, type } = {
      remove_material: { url: `${basePath}/${collection.id}/remove_material`, type: "POST" },
      sort_materials: { url: `${basePath}/${collection.id}/sort_materials`, type: "POST" }
    }[action];

    return new Promise((resolve, reject) => {
      jQuery.ajax({
        url,
        data: JSON.stringify(data),
        type,
        dataType: "json",
        contentType: "application/json",
        success: json => {
          if (!json.success) {
            reject(json.message);
          } else {
            resolve(json.data);
          }
        },
        error: (jqXHR, textStatus, error) => {
          reject(error);
        }
      });
    });
  }

  render () {
    const { items } = this.state;

    if (items.length === 0) {
      return (
        <p>
          No materials have been added to this collection.  To add materials use the <a href="/search">search page</a> and then click on the "Add to Collection" button on the search result.
        </p>
      );
    }

    return (
      <SortableMaterialsCollectionList
        items={items}
        handleDelete={this.handleDelete}
        onSortEnd={this.handleSortEnd}
      />
    );
  }
}

export default EditMaterialsCollectionList;
