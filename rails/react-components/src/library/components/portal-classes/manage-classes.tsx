import React from "react";
import { arrayMove } from "@dnd-kit/sortable";
import SortableClasses from "./sortable-classes";
import CopyDialog from "./copy-dialog";
import { alertAfterRender, serverMessage, withMessage } from "../../helpers/request-error-message";
import restoreOrder from "../../helpers/restore-order";

import css from "./style.scss";

export default class ManageClasses extends React.Component<any, any> {
  handleCopyCancel: any;
  sortPending = false;

  constructor (props: any) {
    super(props);
    this.state = {
      classes: this.props.classes,
      copyClazz: null,
      saving: false
    };
    this.handleCopy = this.handleCopy.bind(this);
    this.handleActiveToggle = this.handleActiveToggle.bind(this);
    this.handleSortEnd = this.handleSortEnd.bind(this);
    this.handleSaveCopy = this.handleSaveCopy.bind(this);
    this.handleCopyCancel = () => this.handleCopy(null);
  }

  handleCopy (clazz: any) {
    this.setState({ copyClazz: clazz });
  }

  handleSaveCopy (values: any) {
    const onSuccess = () => window.location.reload();
    this.setState({ saving: true }, () => {
      this.apiCall("copy", { clazz: this.state.copyClazz, data: values, onSuccess })
        .catch(err => {
          window.alert(withMessage("Unable to copy the class!", serverMessage(err)));
          this.setState({ saving: false });
        });
    });
  }

  handleActiveToggle (clazz: any) {
    // Change the class only after the server agrees, so a refused request leaves the list as it was.
    const isArchived = !clazz.is_archived;
    this.apiCall("activeToggle", { clazz, data: { is_archived: isArchived } })
      .then(() => {
        clazz.is_archived = isArchived;
        // This is conceptually broken, but affraid to touch it while converting source to TypeScript.
        // eslint-disable-next-line react/no-access-state-in-setstate
        this.setState({ classes: this.state.classes });
      })
      .catch(err => {
        window.alert(withMessage("Unable to toggle archived state of the class!", serverMessage(err)));
      });
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
    const { classes: oldClasses } = this.state;
    const oldIds = oldClasses.map((c: any) => c.id);
    const classes = arrayMove(oldClasses, oldIndex, newIndex);
    this.setState({ classes });

    const ids = classes.map((c: any) => c.id);
    this.sortPending = true;
    this.apiCall("sort", { data: { ids } })
      .catch(err => {
        this.setState((prevState: any) => ({ classes: restoreOrder(prevState.classes, oldIds) }));
        alertAfterRender(withMessage("Unable to save class sort order!", serverMessage(err)));
      })
      .finally(() => { this.sortPending = false; });
  }

  apiCall (action: any, options: any) {
    const teacherClassesBasePath = "/api/v1/teacher_classes";
    const classesBasePath = "/api/v1/classes";
    let { clazz, data, onSuccess } = options;

    clazz = clazz || { id: 0 };

    const { url, type } = ({
      copy: { url: `${teacherClassesBasePath}/${clazz.id}/copy`, type: "POST" },
      sort: { url: `${teacherClassesBasePath}/sort`, type: "POST" },
      activeToggle: { url: `${classesBasePath}/${clazz.id}/set_is_archived`, type: "POST" }
    } as any)[action];

    // Reject the promise instead of throwing in the jQuery callbacks. A throw there stops jQuery,
    // so the promise never settles and the callers' error handlers never run.
    return new Promise((resolve, reject) => {
      jQuery.ajax({
        url,
        data: JSON.stringify(data),
        type,
        dataType: "json",
        contentType: "application/json",
        success: json => {
          if (!json.success) {
            reject(json);
          } else {
            if (onSuccess) {
              onSuccess(json.data);
            }
            resolve(json.data);
          }
        },
        error: (jqXHR, textStatus, error) => {
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
    const { classes, copyClazz, saving } = this.state;
    const numActiveClasses = classes.filter((c: any) => c.is_archived === false).length;

    return (
      <>
        <div className={css.manageClassesSummary}>
          My Classes ({ classes.length } Total, { numActiveClasses } Active)
        </div>

        <SortableClasses
          classes={classes}
          handleCopy={this.handleCopy}
          handleActiveToggle={this.handleActiveToggle}
          onSortEnd={this.handleSortEnd}
        />

        { copyClazz ? <CopyDialog clazz={copyClazz} saving={saving} handleSave={this.handleSaveCopy} handleCancel={this.handleCopyCancel} /> : undefined }
      </>
    );
  }
}
