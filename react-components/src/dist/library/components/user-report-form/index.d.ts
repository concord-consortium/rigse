import React from 'react';
export default class UserReportForm extends React.Component<any, any> {
    static defaultProps: {
        externalReports: never[];
    };
    constructor(props: any);
    UNSAFE_componentWillMount(): void;
    getTotals(): void;
    query(_params: any, _fieldName?: any, searchString?: any): void;
    getQueryParams(): any;
    updateQueryParams(): void;
    updateFilters(): void;
    renderInput(name: any, titleOverride?: any): React.JSX.Element | undefined;
    renderDatePicker(name: any): React.JSX.Element;
    renderForm(): React.JSX.Element;
    render(): React.JSX.Element;
}
