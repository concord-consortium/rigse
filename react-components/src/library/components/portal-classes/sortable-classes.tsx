import React from "react";
import ClassRow from "./class-row";
import { SortableContainer, SortableItem } from "../shared/sortable-helpers";
import css from "./style.scss";

class ClassesTable extends React.Component<any, any> {
  render () {
    const { classes } = this.props;
    if (classes.length === 0) {
      return null;
    }

    return (
      <div className={css.manageClassesTable}>
        {
          classes.map((clazz: any) =>
            <SortableItem key={clazz.id} id={clazz.id} className={css.sortableItem}>
              <ClassRow
                clazz={clazz}
                handleCopy={this.props.handleCopy}
                handleActiveToggle={this.props.handleActiveToggle}
              />
            </SortableItem>
          )
        }
      </div>
    );
  }
}

const SortableClasses = ({
  classes,
  onSortEnd,
  handleCopy,
  handleActiveToggle
}: any) => {
  const renderDragPreview = (itemId: any) => {
    const clazz = classes.find((_clazz: any) => _clazz.id === itemId);
    return (
      <ClassRow
        clazz={clazz}
        handleCopy={handleCopy}
        handleActiveToggle={handleActiveToggle}
      />
    );
  };

  return (
    <SortableContainer
      items={classes.map((clazz: any) => clazz.id)}
      renderDragPreview={renderDragPreview}
      onReorder={onSortEnd}
    >
      <ClassesTable
        classes={classes}
        handleCopy={handleCopy}
        handleActiveToggle={handleActiveToggle}
      />
    </SortableContainer>
  );
};

export default SortableClasses;
