import React from 'react';
export default class AutoSuggest extends React.Component<any, any> {
    containerRef: any;
    currentQuery: any;
    debouncedSearch: any;
    inputRef: any;
    queryCache: any;
    throttledSearch: any;
    constructor(props: any);
    UNSAFE_componentWillMount(): void;
    componentWillUnmount(): void;
    handleOuterClick(e: any): void;
    UNSAFE_componentWillReceiveProps(nextProps: any): void;
    search(query: any): void;
    userInitiatedSearch(query: any, onHandler: any): void;
    handleSuggestionClick(query: any): void;
    handleInputChange(e: any): void;
    handleKeyDown(e: any): void;
    renderSuggestions(): React.JSX.Element | undefined;
    render(): React.JSX.Element;
}
