import React from "react";
import { arrayMove } from "@dnd-kit/sortable";
import SortableBookmarks from "./sortable-bookmarks";

export class EditBookmarks extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.state = {
      bookmarks: this.sortBookmarks(props.bookmarks)
    };

    this.handleCreate = this.handleCreate.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleVisibilityToggle = this.handleVisibilityToggle.bind(this);
    this.handleSortEnd = this.handleSortEnd.bind(this);
  }

  sortBookmarks (bookmarks: any) {
    bookmarks.sort((a: any, b: any) => a.position - b.position);
    return bookmarks;
  }

  handleCreate () {
    this.apiCall("create", { onSuccess: (bookmark: any) => {
      const { bookmarks } = this.state;
      bookmark.editing = true;
      bookmarks.push(bookmark);
      this.sortBookmarks(bookmarks);
      this.setState({ bookmarks });
    } })
      .catch(err => this.showError(err, "Unable to create link!"));
  }

  handleUpdate (bookmark: any, fields: any) {
    const { name, url } = fields;
    const { name: oldName, url: oldUrl } = bookmark;

    const update = (newName: any, newUrl: any) => {
      bookmark.name = newName;
      bookmark.url = newUrl;
      // eslint-disable-next-line react/no-access-state-in-setstate
      this.setState({ bookmarks: this.state.bookmarks });
    };

    update(name, url);
    this.apiCall("update", { bookmark, data: { name, url } })
      .catch(err => {
        // reset the bookmark on error
        update(oldName, oldUrl);
        this.showErrorAfterRender(err, "Unable to update link!");
      });
  }

  handleDelete (bookmark: any) {
    if (window.confirm(`Are you sure you want to delete this link?\n\n${bookmark.name} -> ${bookmark.url}`)) {
      // Remove the link only after the server agrees, so a refused request leaves the list as it was.
      this.apiCall("delete", { bookmark })
        .then(() => {
          const { bookmarks } = this.state;
          bookmarks.splice(bookmarks.indexOf(bookmark), 1);
          this.setState({ bookmarks });
        })
        .catch(err => this.showError(err, "Unable to delete link!"));
    }
  }

  handleVisibilityToggle (bookmark: any) {
    // Change the link only after the server agrees, so a refused request leaves the list as it was.
    const isVisible = !bookmark.is_visible;
    this.apiCall("visibilityToggle", { bookmark, data: { is_visible: isVisible } })
      .then(() => {
        bookmark.is_visible = isVisible;
        // This is conceptually broken, but maybe it somehow works (?)
        // eslint-disable-next-line react/no-access-state-in-setstate
        this.setState({ bookmarks: this.state.bookmarks });
      })
      .catch(err => this.showError(err, "Unable to toggle visibility of link!"));
  }

  handleSortEnd ({
    oldIndex,
    newIndex
  }: any) {
    let { bookmarks } = this.state;
    bookmarks = arrayMove(bookmarks, oldIndex, newIndex);
    this.setState({ bookmarks });

    const ids = bookmarks.map((bookmark: any) => bookmark.id);
    this.apiCall("sort", { data: { ids } })
      .catch(err => {
        this.setState({ bookmarks: arrayMove(bookmarks, newIndex, oldIndex) });
        this.showErrorAfterRender(err, "Unable to save link sort order!");
      });
  }

  showError (err: any, message: any) {
    if (err.message) {
      window.alert(`${message}\n${err.message}`);
    } else {
      window.alert(message);
    }
  }

  // The alert stops the page from drawing, so show it after the undone change is on screen.
  showErrorAfterRender (err: any, message: any) {
    requestAnimationFrame(() => setTimeout(() => this.showError(err, message)));
  }

  apiCall (action: any, options: any) {
    const basePath = "/api/v1/bookmarks";
    const { onSuccess } = options;
    let { bookmark, data } = options;

    bookmark = bookmark || { id: 0 };

    const { url, type } = ({
      create: { url: basePath, type: "POST" },
      update: { url: `${basePath}/${bookmark.id}`, type: "PUT" },
      visibilityToggle: { url: `${basePath}/${bookmark.id}`, type: "PUT" },
      delete: { url: `${basePath}/${bookmark.id}`, type: "DELETE" },
      sort: { url: `${basePath}/sort`, type: "POST" }
    } as any)[action];

    // add clazz_id to all requests
    data = { clazz_id: this.props.classId, ...(data || {}) };

    return new Promise((resolve, reject) => {
      jQuery.ajax({
        url,
        data: JSON.stringify(data),
        type,
        dataType: "json",
        contentType: "application/json",
        success: json => {
          // Reject instead of throwing. A throw here stops jQuery, so the promise never settles.
          if (!json.success) {
            reject(json);
            return;
          }
          if (onSuccess) {
            onSuccess(json.data);
          }
          resolve(json.data);
        },
        error: (jqXHR, textStatus, error) => {
          // Use the server's JSON, which has its message, when there is one.
          try {
            error = JSON.parse(jqXHR.responseText);
          } catch (e) {
            // noop
          }
          reject(error);
        }
      });
    });
  }

  render () {
    return (
      <>
        <SortableBookmarks
          bookmarks={this.state.bookmarks}
          handleUpdate={this.handleUpdate}
          handleDelete={this.handleDelete}
          handleVisibilityToggle={this.handleVisibilityToggle}
          onSortEnd={this.handleSortEnd}
        />
        <div>
          <button onClick={this.handleCreate}>Create Link</button>
        </div>
      </>
    );
  }
}

export default EditBookmarks;
