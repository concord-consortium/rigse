import React from 'react'
import Component from '../../helpers/component'

import css from './featured-collections-card.scss'

const FeaturedCollectionsCard = Component({
  getInitialState: function () {
    return {
      hover: false
    }
  },

  handleMouseEnter: function () {
    this.setState({ hover: true })
  },

  handleMouseLeave: function () {
    this.setState({ hover: false })
  },

  render () {
    const { featuredCollection } = this.props
    const hover = this.state.hover
    return (
      <div key={featuredCollection.external_url} className={`${css.finderResultsFeaturedCard} col-4`} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
        <a href={featuredCollection.external_url}>
          {!hover &&
            <div className={css.finderResultsFeaturedCardImagePreview}>
              <img alt={featuredCollection.name} src={featuredCollection.icon.url} />
            </div>
          }
          <h3 className={css.finderResultsFeaturedCardName}>
            {featuredCollection.name}
          </h3>
          {hover &&
            <p className={css.finderResultsFeaturedCardDescription}>
              {featuredCollection.filteredShortDescription}
            </p>
          }
        </a>
      </div>
    )
  }
})

export default FeaturedCollectionsCard
