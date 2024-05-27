import React from 'react'
import Component from '../helpers/component'
import fadeIn from '../helpers/fade-in'
import sortByName from '../helpers/sort-by-name'
import shuffleArray from '../helpers/shuffle-array'
import waitForAutoShowingLightboxToClose from '../helpers/wait-for-auto-lightbox-to-close'
import portalObjectHelpers from '../helpers/portal-object-helpers'

const CollectionCards = Component({
  getInitialState: function () {
    return {
      opacity: 0,
      collections: []
    }
  },

  componentDidMount: function () {
    waitForAutoShowingLightboxToClose(function () {
      jQuery.ajax({
        url: '/api/v1/projects', // TODO: replace with Portal.API_V1 constant when available
        dataType: 'json'
      }).done(function (data: any) {
        var collections = data.reduce(function (collections: any, collection: any) {
          if (collection.landing_page_slug) {
            collection.filteredDescription = portalObjectHelpers.textOfHtml(collection.project_card_description)
            collections.push(collection)
          }
          return collections
        }, [])

        if (this.props.shuffle) {
          collections = shuffleArray(collections)
        } else {
          collections.sort(sortByName)
        }

        if (this.props.count) {
          collections = collections.slice(0, this.props.count)
        }

        this.setState({ collections: collections })

        fadeIn(this)
      }.bind(this))
    }.bind(this))
  },

  renderCollectionCards: function () {
    let collectionsCards: any = []
    let defaultProjectCardImageUrl = 'https://learn-resources.concord.org/images/collections/default-collection.jpg'
    this.state.collections.map(function (collection: any) {
      collectionsCards.push(<div key={collection.landing_page_slug} className={'portal-pages-collections-card col-4'}>
        <a href={'/' + collection.landing_page_slug}>
          <div className={'portal-pages-collections-card-image-preview'}>
            <img alt={collection.name} src={collection.project_card_image_url ? collection.project_card_image_url : defaultProjectCardImageUrl} />
          </div>
          <h3 className={'portal-pages-collections-card-name'}>
            {collection.name}
          </h3>
          <p className={'portal-pages-collections-card-description'}>
            {collection.filteredDescription}
          </p>
        </a>
      </div>)
    })
    return (
      <div>
        {collectionsCards}
      </div>
    )
  },

  render: function () {
    if (this.state.collections.length === 0) {
      return null
    }
    return (
      <div style={{ opacity: this.state.opacity }}>
        {this.renderCollectionCards()}
      </div>
    )
  }
})

export default CollectionCards
