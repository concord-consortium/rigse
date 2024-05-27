import React from 'react';
export default class StudentRoster extends React.Component<any, any> {
    constructor(props: any);
    UNSAFE_componentWillMount(): void;
    handleRemoveStudent(student: any): void;
    handleChangePassword(student: any): void;
    handleAddStudent(otherStudent: any): void;
    handleRegisterStudent(fields: any): void;
    handleToggleRegisterStudentModal(): void;
    handleToggleRegisterAnotherModal(): void;
    handleRegisterAnotherStudent(): void;
    renderRegisterAnotherModal(): React.JSX.Element;
    renderStudents(canEdit: any): React.JSX.Element;
    render(): React.JSX.Element;
}
