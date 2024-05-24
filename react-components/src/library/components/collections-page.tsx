import React from 'react'
import Component from '../helpers/component'
import CollectionCards from './collection-cards'

const CollectionsPage = Component({
  render: function () {
    return (
      <div>
        <div className={'cols'}>
          <div className={'portal-pages-collections-page-header col-12'}>
            <h1>Collections</h1>
            <p className={'portal-pages-collections-page-header-info'}>
              Many of our resources are part of collections that are created by our various <a href={'https://concord.org/our-work/research-projects/'} target={'_blank'}>research projects</a>. Each collection has specific learning goals within the context of a larger subject area.
            </p>
          </div>
        </div>
        <div className={'portal-pages-collections-page-diagonal-spacer-2'}>
          <section className={'portal-pages-collections-page-list skew top-only.mediumgray'}>
            <div className={'portal-pages-collections-page-list-inner cols skew-cancel'}>
              {CollectionCards({ fadeIn: 1000 })}
            </div>
          </section>
        </div>
      </div>
    )
  }
})

export default CollectionsPage
