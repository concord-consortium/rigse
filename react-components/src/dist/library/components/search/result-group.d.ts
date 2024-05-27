import React from 'react';
export default class SearchResultGroup extends React.Component<any, any> {
    materialType: any;
    pageParam: any;
    constructor(props: any);
    onPaginationSelect(page: any): void;
    updateState(groupData: any): void;
    renderLoading(): React.JSX.Element;
    renderResults(): React.JSX.Element;
    render(): React.JSX.Element;
}
