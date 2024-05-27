import React from 'react';
export default class Navigation extends React.Component<any, any> {
    closeTimeout: any;
    constructor(props?: {
        greeting: string;
        name: string;
        links: never[];
    });
    componentDidMount(): void;
    renderHead(): React.JSX.Element;
    getLinkClasses(linkDef: any): any;
    renderLink(linkDef: any): React.JSX.Element;
    isInSection(openSection: any, thisSection: any): any;
    renderSection(section: any): React.JSX.Element;
    renderItem(item: any): React.JSX.Element;
    sortLinks(links: any): any;
    render(): React.JSX.Element;
}
