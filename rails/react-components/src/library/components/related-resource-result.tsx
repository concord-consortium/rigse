import React from "react";
import GradeLevels from "./grade-levels";
import Component from "../helpers/component";
import portalObjectHelpers from "../helpers/portal-object-helpers";

import css from "./related-resource-result.scss";

const RelatedResourceResult = Component({
  UNSAFE_componentWillMount () {
    // process the related resource
    const resource = this.props.resource;
    portalObjectHelpers.processResource(resource);
  },

  handleClick (e: any) {
    e.preventDefault();
    e.stopPropagation();
    this.props.replaceResource(this.props.resource);
    gtag("event", "click", {
      "category": "Related Resource Card",
      "resource": this.props.resource.name
    });
  },

  render () {
    const resource = this.props.resource;

    return (
      <div className={css.finderRelatedResult}>
        <div className={css.finderRelatedResultImagePreview}>
          <img alt={resource.name} src={resource.icon.url} />
          <GradeLevels resource={resource} />
        </div>
        <div className={css.finderRelatedResultText}>
          <div className={css.finderRelatedResultTextName}><a href={resource.links.browse.url} target="_blank" rel="noreferrer">{ resource.name }</a></div>
          <div className={css.finderRelatedResultTextDescription}>{ resource.filteredShortDescription }</div>
        </div>
      </div>
    );
  }
});

export default RelatedResourceResult;
