import React from 'react';
export default class ManageClasses extends React.Component<any, any> {
    handleCopyCancel: any;
    constructor(props: any);
    handleCopy(clazz: any): void;
    handleSaveCopy(values: any): void;
    handleActiveToggle(clazz: any): void;
    handleSortEnd({ oldIndex, newIndex }: any): void;
    showError(err: any, message: any): void;
    apiCall(action: any, options: any): Promise<any>;
    render(): React.JSX.Element;
}
