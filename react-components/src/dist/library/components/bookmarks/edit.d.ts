import React from 'react';
export declare class EditBookmarks extends React.Component<any, any> {
    constructor(props: any);
    sortBookmarks(bookmarks: any): any;
    handleCreate(): void;
    handleUpdate(bookmark: any, fields: any): void;
    handleDelete(bookmark: any): void;
    handleVisibilityToggle(bookmark: any): void;
    handleSortEnd({ oldIndex, newIndex }: any): void;
    showError(err: any, message: any): void;
    apiCall(action: any, options: any): Promise<unknown>;
    render(): React.JSX.Element;
}
export default EditBookmarks;
