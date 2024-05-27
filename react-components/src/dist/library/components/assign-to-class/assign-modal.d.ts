import React from 'react';
export default class AssignModal extends React.Component<any, any> {
    constructor(props: any);
    componentDidMount(): void;
    copyToClipboard(e: any): void;
    assignMaterial(): void;
    noClasses(): React.JSX.Element | undefined;
    assignedClassesList(): React.JSX.Element | undefined;
    unassignedClassesForm(): React.JSX.Element | undefined;
    updateClassList(e: any): void;
    handleRegisterClick(e: any): void;
    handleLoginClick(e: any): void;
    saveButton(): React.JSX.Element;
    contentForAnonymous(): React.JSX.Element;
    contentForTeacher(): React.JSX.Element;
    closeConfirmModal(): void;
    resourceAssigned(): React.JSX.Element;
    render(): React.JSX.Element;
}
