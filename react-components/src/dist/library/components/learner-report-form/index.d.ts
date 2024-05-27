import React from 'react';
export default class LearnerReportForm extends React.Component<any, any> {
    constructor(props: any);
    UNSAFE_componentWillMount(): void;
    query(_params: any, fieldName: any, searchString: any): void;
    getQueryParams(): {
        hide_names: any;
    };
    updateQueryParams(): void;
    updateFilters(): void;
    renderTopInfo(): React.JSX.Element | React.JSX.Element[];
    renderInput(name: any, titleOverride: any): React.JSX.Element | undefined;
    renderDatePicker(name: any): React.JSX.Element;
    renderCheck(name: any): React.JSX.Element;
    renderButton(name: any): React.JSX.Element;
    renderForm(): React.JSX.Element;
    render(): React.JSX.Element;
}
