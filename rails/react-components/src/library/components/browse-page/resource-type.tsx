import React from "react";
import Component from "../../helpers/component";

const ResourceType = Component({

  render () {
    const resource = this.props.resource;
    const materialTypeLabels: any = {
      "Interactive": "model",
      "Activity": "activity",
      "Investigation": "sequence",
      "Collection": "collection"
    };
    const resourceType = materialTypeLabels[resource.material_type];

    if (resourceType === "activity" || !resourceType) {
      return null;
    }

    return (
      <div className={this.props.className || "portal-pages-finder-result-resource-types"}>
        <div className={"portal-pages-finder-result-resource-type"}>
          { resourceType }
        </div>
      </div>
    );
  }
});

export default ResourceType;
