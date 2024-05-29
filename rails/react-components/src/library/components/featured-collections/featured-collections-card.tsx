import React from "react";
import Component from "../../helpers/component";

import css from "./featured-collections-card.scss";

const FeaturedCollectionsCard = Component({
  render () {
    const { featuredCollection } = this.props;
    return (
      <div key={featuredCollection.external_url} className={css.finderResultsFeaturedCard}>
        <a href={featuredCollection.external_url}>
          <div className={css.finderResultsFeaturedCardImagePreview}>
            <img alt={featuredCollection.name} src={featuredCollection.icon.url} />
          </div>
          <h3 className={css.finderResultsFeaturedCardName}>
            { featuredCollection.name }
          </h3>
          <p className={css.finderResultsFeaturedCardDescription}>
            { featuredCollection.filteredShortDescription }
          </p>
        </a>
      </div>
    );
  }
});

export default FeaturedCollectionsCard;
