import React from 'react';
export default class TeacherForm extends React.Component<any, any> {
    constructor(props: any);
    onBasicFormValid(): void;
    onBasicFormInvalid(): void;
    submit(data: any, resetForm: any, invalidateForm: any): JQuery.jqXHR<any>;
    onChange(currentValues: any): void;
    getCountries(callback: any): void;
    addNewSchool(): void;
    goBackToSchoolList(): void;
    checkIfUS(option: any): void;
    zipcodeValidation(values: any, value: any): any;
    zipOrPostal(): "ZIP code" | "postal code";
    renderAnonymous(showEnewsSubscription: any): React.JSX.Element;
    renderZipcode(): React.JSX.Element;
    render(): React.JSX.Element;
}
