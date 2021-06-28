import React from 'react'
// import StemFinderResult from '../stem-finder-result'
import FeaturedCollectionsCard from './featured-collections-card'

import css from './featured-collections.scss'

export default class FeaturedCollections extends React.Component {
  shouldComponentUpdate () {
    return false
  }

  render () {
    const { featuredCollections } = this.props
    return (
      <div className={css.finderResultsFeatured}>
        <div className={css.finderResultsFeaturedHeader}>
          <h3>Featured Collections</h3>
          <p>Collections are curated groups of complementary resources that focus on a particular topic. <a className='special-link' href='/collections'>View all</a></p>
        </div>
        <div className={css.finderResultsFeaturedCards}>
          {featuredCollections.map(function (featuredCollection, index) {
            return FeaturedCollectionsCard({ key: featuredCollection.id, featuredCollection: featuredCollection })
          })}
        </div>
      </div>
    )
  }
}
