import React from 'react';
export declare class EditMaterialsCollectionList extends React.Component<any, any> {
    constructor(props: any);
    handleDelete(item: any): void;
    handleSortEnd({ oldIndex, newIndex }: any): void;
    showError(err: any, message: any): void;
    apiCall(action: any, options: any): Promise<unknown>;
    render(): React.JSX.Element;
}
export default EditMaterialsCollectionList;
