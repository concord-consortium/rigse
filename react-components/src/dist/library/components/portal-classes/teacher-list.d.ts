import React from 'react';
export default class TeacherList extends React.Component<any, any> {
    selectRef: any;
    constructor(props: any);
    handleAssignTeacher(): void;
    handleUnassignTeacher(teacher: any): void;
    moveTeacher(teacher: any, lists: any): {
        fromList: any;
        toList: any;
    };
    render(): React.JSX.Element;
}
