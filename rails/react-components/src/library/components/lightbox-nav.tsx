import React from "react";
import Component from "../helpers/component";

import css from "./lightbox-nav.scss";

const LightboxNav = Component({

  getCollectionName() {
    return this.props.collectionName || "all resources";
  },

  collectionViewsOptions () {
    const collectionName = this.getCollectionName();
    const { collectionViews } = this.props;
    return collectionViews.map((collection: any) => collectionName !== collection.name
      ? <option key={`collection-nav-${collection.id}-${collection.name}`} value={collection.id}>{ collection.name } Collection</option>
      : null);
  },

  render () {
    const collectionName = this.getCollectionName();
    const { handleSwitchSource } = this.props;
    const collectionRef = collectionName === "all resources"
      ? <strong>{ collectionName }</strong>
      : <span>the <strong>{ collectionName } Collection</strong></span>;
    return (
      <div id="finderLightboxModalNav" className={css.resourceFinderLightboxModalNav}>
        You are viewing { collectionRef }. Switch to:
        <select name="resourceFinderSource" onChange={handleSwitchSource}>
          <option value="">Select a collection...</option>
          { collectionName !== "all resources" && <option key={`collection-nav-all-resources`} value="all">All Resources</option> }
          { this.collectionViewsOptions() }
        </select>
      </div>
    );
  }
});

export default LightboxNav;
