import React from 'react'
import Component from '../helpers/component'

import css from './lightbox-nav.scss'

const LightboxNav = Component({
  getInitialState: function () {
    return {
      collectionName: this.props.collectionName || 'all resources',
      collectionViews: this.props.collectionViews,
      handleSwitchSource: this.props.handleSwitchSource
    }
  },

  collectionViewsOptions: function () {
    const { collectionName, collectionViews } = this.state
    return collectionViews.map((collection: any) => collectionName !== collection.name
      ? <option key={`collection-nav-${collection.id}-${collection.name}`} value={collection.id}>{collection.name} Collection</option>
      : null);
  },

  render: function () {
    const { collectionName, handleSwitchSource } = this.state
    const collectionRef = collectionName === 'all resources'
      ? <strong>{collectionName}</strong>
      : <span>the <strong>{collectionName} Collection</strong></span>
    return (
      <div id='finderLightboxModalNav' className={css.resourceFinderLightboxModalNav}>
        You are viewing {collectionRef}. Switch to:
        <select name='resourceFinderSource' onChange={handleSwitchSource}>
          <option value=''>Select a collection...</option>
          {collectionName !== 'all resources' && <option key={`collection-nav-all-resources`} value='all'>All Resources</option>}
          {this.collectionViewsOptions()}
        </select>
      </div>
    )
  }
})

export default LightboxNav
