import React from 'react';
export default class MaterialsBin extends React.Component<any, any> {
    _isSlugTaken: any;
    constructor(props: any);
    UNSAFE_componentWillMount(): void;
    componentWillUnmount(): void;
    selectFirstSlugs(): any[];
    checkHash(): void;
    handleCellClick(column: any, slug: any): void;
    isSlugSelected(column: any, slug: any): boolean;
    generateSlug(name: any): any;
    _getColumns(): any;
    render(): React.JSX.Element;
}
