import React from 'react';
export declare class SMaterialLinks extends React.Component<any, any> {
    render(): React.JSX.Element;
}
export declare class SGenericLink extends React.Component<any, any> {
    constructor(props: any);
    optionallyWrapConfirm(link: any): void;
    wrapOnClick(str: any): () => any;
    render(): React.JSX.Element;
}
export declare class SMaterialLink extends React.Component<any, any> {
    render(): React.JSX.Element;
}
export declare class SMaterialDropdownLink extends React.Component<any, any> {
    expandedText: any;
    constructor(props: any);
    handleClick(event: any): void;
    render(): React.JSX.Element;
}
