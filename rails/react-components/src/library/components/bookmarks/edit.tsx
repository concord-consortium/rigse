import React from "react";
import { arrayMove } from "@dnd-kit/sortable";
import SortableBookmarks from "./sortable-bookmarks";
import { alertAfterRender, serverMessage, withMessage } from "../../helpers/request-error-message";
import restoreOrder from "../../helpers/restore-order";

export class EditBookmarks extends React.Component<any, any> {
  sortPending = false;

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
      .catch(err => window.alert(withMessage("Unable to create link!", serverMessage(err))));
  }

  handleUpdate (bookmark: any, fields: any) {
    const { name, url } = fields;
    const { name: oldName, url: oldUrl } = bookmark;

    const update = (newName: any, newUrl: any, afterRender?: () => void) => {
      bookmark.name = newName;
      bookmark.url = newUrl;
      // eslint-disable-next-line react/no-access-state-in-setstate
      this.setState({ bookmarks: this.state.bookmarks }, afterRender);
    };

    update(name, url);
    this.apiCall("update", { bookmark, data: { name, url } })
      .catch(err => {
        // reset the bookmark on error
        update(oldName, oldUrl, () => alertAfterRender(withMessage("Unable to update link!", serverMessage(err))));
      });
  }

  handleDelete (bookmark: any) {
    if (window.confirm(`Are you sure you want to delete this link?\n\n${bookmark.name} -> ${bookmark.url}`)) {
      // Remove the link only after the server agrees, so a refused request leaves the list as it was.
      this.apiCall("delete", { bookmark })
        .then(() => {
          this.setState((prevState: any) => ({
            bookmarks: prevState.bookmarks.filter((b: any) => b.id !== bookmark.id)
          }));
        })
        .catch(err => window.alert(withMessage("Unable to delete link!", serverMessage(err))));
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
      .catch(err => window.alert(withMessage("Unable to toggle visibility of link!", serverMessage(err))));
  }

  handleSortEnd ({
    oldIndex,
    newIndex
  }: any) {
    // One sort at a time, so a late failure can't undo a later sort. A drag in the meantime does
    // nothing.
    if (this.sortPending) {
      return;
    }
    const { bookmarks: oldBookmarks } = this.state;
    const oldIds = oldBookmarks.map((bookmark: any) => bookmark.id);
    const bookmarks = arrayMove(oldBookmarks, oldIndex, newIndex);
    this.setState({ bookmarks });

    const ids = bookmarks.map((bookmark: any) => bookmark.id);
    this.sortPending = true;
    this.apiCall("sort", { data: { ids } })
      .catch(err => {
        this.setState(
          (prevState: any) => ({ bookmarks: restoreOrder(prevState.bookmarks, oldIds) }),
          () => alertAfterRender(withMessage("Unable to save link sort order!", serverMessage(err)))
        );
      })
      .finally(() => { this.sortPending = false; });
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
