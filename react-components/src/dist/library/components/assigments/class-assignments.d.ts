import React from 'react';
export default class ClassAssignments extends React.Component<any, any> {
    assignMaterialsRef: any;
    constructor(props: any);
    componentDidMount(): void;
    componentWillUnmount(): void;
    closeLightbox(e: any): void;
    handleAssignMaterialsButtonClick(e: any): void;
    handleExternalClick(e: any): void;
    handleAssignMaterialsOptionClick(e: any, collectionId: any): void;
    handleAssignButtonMouseEnter(e: any): void;
    handleAssignButtonMouseLeave(e: any): void;
    renderAssignOption(): any;
    renderAssignOptions(): React.JSX.Element;
    renderFindMoreResources(): React.JSX.Element | undefined;
    get assignMaterialsPath(): any;
    render(): React.JSX.Element;
}
