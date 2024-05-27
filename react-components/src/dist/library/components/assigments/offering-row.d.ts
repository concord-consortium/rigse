import React from 'react';
export default class OfferingRow extends React.Component<any, any> {
    onActiveUpdate: any;
    onLockedUpdate: any;
    constructor(props: any);
    get detailsLabel(): "- HIDE DETAIL" | "+ SHOW DETAIL";
    onCheckboxUpdate(name: any, event: any): void;
    onDetailsToggle(): void;
    render(): React.JSX.Element;
}
