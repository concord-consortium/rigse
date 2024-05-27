import React from 'react';
export default class ResearcherClassesForm extends React.Component<any, any> {
    constructor(props: any);
    noFilterSelected(): boolean;
    query(_params: any, _fieldName: any): void;
    getQueryParams(): {
        remove_cc_teachers: any;
        project_id: any;
    };
    updateFilters(): void;
    renderInput(name: any, titleOverride: any): React.JSX.Element | undefined;
    renderForm(): React.JSX.Element;
    renderSummary(): React.JSX.Element | null;
    render(): React.JSX.Element;
}
