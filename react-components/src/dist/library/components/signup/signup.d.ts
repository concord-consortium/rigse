import React from 'react';
export default class SignUp extends React.Component<any, any> {
    static defaultProps: {
        siteName: any;
        signupText: string;
        anonymous: any;
    };
    constructor(props: any);
    onUserTypeSelect(data: any): void;
    onBasicDataSubmit(data: any): void;
    onStudentRegistration(data: any): void;
    onTeacherRegistration(data: any): void;
    getStepNumber(): 1 | 3 | 2;
    render(): React.JSX.Element | null;
}
