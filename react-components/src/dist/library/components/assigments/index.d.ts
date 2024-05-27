import React from 'react';
export default class Assignments extends React.Component<any, any> {
    constructor(props: any);
    componentDidMount(): void;
    getClassData(): void;
    onOfferingsReorder({ oldIndex, newIndex }: any): void;
    onOfferingUpdate(offering: any, prop: any, value: any): void;
    requestOfferingDetails(offering: any): void;
    handleNewAssignments(): void;
    render(): React.JSX.Element | null;
}
