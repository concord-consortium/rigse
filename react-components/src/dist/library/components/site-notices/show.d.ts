import React from 'react';
export default class ShowSiteNotices extends React.Component<any, any> {
    constructor(props: any);
    componentDidMount(): void;
    getPortalData(): void;
    handleDelete(notice: any): boolean;
    handleToggle(): void;
    renderNoNotices(): React.JSX.Element;
    renderTable(notices: any): React.JSX.Element;
    renderRow(notice: any): React.JSX.Element;
    render(): React.JSX.Element;
}
