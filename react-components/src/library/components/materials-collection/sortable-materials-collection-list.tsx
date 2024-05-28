import React from "react";
import MaterialsCollectionListRow from "./materials-collection-list-row";
import { SortableContainer, SortableItem } from "../shared/sortable-helpers";
import css from "./style.scss";

class MaterialsCollectionList extends React.Component<any, any> {
  render () {
    const { items } = this.props;

    return (
      <div className={css.editMaterialsCollectionsList}>
        {
          items.map((item: any) => (
            <SortableItem key={item.id} id={item.id}>
              <MaterialsCollectionListRow
                item={item}
                handleDelete={this.props.handleDelete}
              />
            </SortableItem>
          ))
        }
      </div>
    );
  }
}

const SortableMaterialsCollectionList = ({
  items,
  handleDelete,
  onSortEnd
}: any) => {
  const renderDragPreview = (itemId: any) => {
    const item = items.find((_item: any) => _item.id === itemId);
    return (
      <MaterialsCollectionListRow
        item={item}
        handleDelete={handleDelete}
      />
    );
  };

  return (
    <SortableContainer
      items={items.map((item: any) => item.id)}
      renderDragPreview={renderDragPreview}
      onReorder={onSortEnd}
    >
      <MaterialsCollectionList
        items={items}
        handleDelete={handleDelete}
      />
    </SortableContainer>
  );
};

export default SortableMaterialsCollectionList;
