import React from "react";
import FeaturedCollectionsCard from "./featured-collections-card";

import css from "./featured-collections.scss";

export default class FeaturedCollections extends React.Component<any, any> {
  shouldComponentUpdate () {
    return false;
  }

  render () {
    const { featuredCollections } = this.props;
    return (
      <div className={css.finderResultsFeatured}>
        <div className={css.finderResultsFeaturedHeader}>
          <h2>Featured Collections</h2>
          <div className={css.finderResultsFeaturedTitle}>
            <div>Collections include a <strong>related set</strong> of student and teacher resources.</div>
            <a className="special-link" href="/collections">View All Collections</a>
          </div>
        </div>
        <div className={css.finderResultsFeaturedCards}>
          { featuredCollections.map(function (featuredCollection: any, index: any) {
            return FeaturedCollectionsCard({ key: featuredCollection.id, featuredCollection });
          }) }
        </div>
      </div>
    );
  }
}
