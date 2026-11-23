// The items, sorted into the order of oldIds. Use it to undo a failed sort on the current list, so
// that other changes made while the sort waited are kept. An item that is not in oldIds, for
// example one created while the sort waited, goes at the end.
const restoreOrder = (items: any[], oldIds: any[]) => {
  const oldPosition = (item: any) => {
    const index = oldIds.indexOf(item.id);
    return index === -1 ? oldIds.length : index;
  };
  return [...items].sort((a, b) => oldPosition(a) - oldPosition(b));
};

export default restoreOrder;
