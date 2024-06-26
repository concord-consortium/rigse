import React from "react";
import { arrayMove } from "@dnd-kit/sortable";
import SortableClasses from "./sortable-classes";
import CopyDialog from "./copy-dialog";

import css from "./style.scss";

export default class ManageClasses extends React.Component<any, any> {
  handleCopyCancel: any;
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
          this.showError(err, "Unable to copy the class!");
          this.setState({ saving: false });
        });
    });
  }

  handleActiveToggle (clazz: any) {
    const toggle = () => {
      clazz.is_archived = !clazz.is_archived;
      // This is conceptually broken, but affraid to touch it while converting source to TypeScript.
      // eslint-disable-next-line react/no-access-state-in-setstate
      this.setState({ classes: this.state.classes });
    };

    toggle();
    this.apiCall("activeToggle", { clazz, data: { is_archived: clazz.is_archived } })
      .catch(err => {
        // retoggle back on error
        toggle();
        this.showError(err, "Unable to toggle archived state of the class!");
      });
  }

  handleSortEnd ({
    oldIndex,
    newIndex
  }: any) {
    let { classes } = this.state;
    classes = arrayMove(classes, oldIndex, newIndex);
    this.setState({ classes });

    const ids = classes.map((c: any) => c.id);
    this.apiCall("sort", { data: { ids } })
      .catch(err => {
        this.setState({ classes: arrayMove(classes, newIndex, oldIndex) });
        this.showError(err, "Unable to save class sort order!");
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
    const teacherClassesBasePath = "/api/v1/teacher_classes";
    const classesBasePath = "/api/v1/classes";
    let { clazz, data, onSuccess } = options;

    clazz = clazz || { id: 0 };

    const { url, type } = ({
      copy: { url: `${teacherClassesBasePath}/${clazz.id}/copy`, type: "POST" },
      sort: { url: `${teacherClassesBasePath}/sort`, type: "POST" },
      activeToggle: { url: `${classesBasePath}/${clazz.id}/set_is_archived`, type: "POST" }
    } as any)[action];

    return Promise.resolve(
      jQuery.ajax({
        url,
        data: JSON.stringify(data),
        type,
        dataType: "json",
        contentType: "application/json",
        success: json => {
          if (!json.success) {
            throw json;
          } else {
            if (onSuccess) {
              onSuccess(json.data);
            }
          }
        },
        error: (jqXHR, textStatus, error) => {
          try {
            error = JSON.parse(jqXHR.responseText);
          } catch (e) {
            // noop
          }
          throw error;
        }
      })
    );
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
