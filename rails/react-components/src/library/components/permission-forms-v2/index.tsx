import React from "react";

export default class PermissionFormsV2 extends React.Component<any, any> {
  constructor(props: any) {
    super(props);
    this.state = {
      permissionForms: null
    };
  }

  componentDidMount () {
    const { dataUrl } = this.props;
    if (!dataUrl) return;

    jQuery.ajax({
      url: dataUrl,
      success: data => {
        this.setState({ permissionForms: data });
      },
      error: (e) => {
        console.error(`GET ${dataUrl} failed.`, e);
      }
    });
  }

  render() {
    const { permissionForms } = this.state;
    return (
      <div>
        <h2>Permission Forms V2</h2>
        { permissionForms?.map((permissionForm: any) => (
          <p key={permissionForm.id}>{ permissionForm.id }: { permissionForm.name }</p>
        )) }
      </div>
    );
  }
}
