import React from "react";

import SMaterial from "./material";

export default class SMaterialsList extends React.Component<any, any> {
  render () {
    return (
      <div className="material_list">
        { this.props.materials.map((material: any) => <SMaterial material={material} key={`${material.class_name}${material.id}`} />) }
      </div>
    );
  }
}
