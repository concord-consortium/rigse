import React from 'react';
export declare const PAGE_SIZE = 10;
export default class StandardsTable extends React.Component<any, any> {
    search: any;
    constructor(props: any);
    paginateUp(): void;
    paginateDown(): void;
    renderPagination(): React.JSX.Element | undefined;
    render(): React.JSX.Element;
}
