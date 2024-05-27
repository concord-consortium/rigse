import React from 'react';
export declare const ENTER_CLASS_WORD = "enterClassWord";
export declare const CONFIRMING_CLASS_WORD = "confirmClassWord";
export declare const JOIN_CLASS = "joinClass";
export declare const JOINING_CLASS = "joiningClass";
export declare class JoinClass extends React.Component<any, any> {
    classWordRef: any;
    constructor(props: any);
    handleCancelJoin(): void;
    handleSubmit(e: any): void;
    showError(err: any, message: any): void;
    apiCall(action: any, options: any): void;
    renderEnterClassWord(): React.JSX.Element;
    renderJoinClass(): React.JSX.Element;
    render(): React.JSX.Element;
}
export default JoinClass;
