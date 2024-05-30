import React from "react";
import SMaterialsList from "../search/materials-list";

export default class FeaturedMaterials extends React.Component<any, any> {
  mounted: any;
  constructor (props: any) {
    super(props);
    this.state = {
      materials: []
    };
    this.mounted = false;
  }

  componentDidMount () {
    this.mounted = true;
    jQuery.ajax({
      url: Portal.API_V1.MATERIALS_FEATURED,
      data: this.props.queryString,
      dataType: "json",
      success: data => {
        if (this.mounted) {
          this.setState({ materials: data });
        }
      }
    });
  }

  componentWillUnmount () {
    this.mounted = false;
  }

  render () {
    return <SMaterialsList materials={this.state.materials} />;
  }
}
