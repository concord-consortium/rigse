import React from 'react'
import Component from '../helpers/component'
import StemFinder from './stem-finder'
import LightboxNav from './lightbox-nav'

import css from './resource-finder-lightbox.scss'

var ResourceFinderLightbox = Component({
  getInitialState: function () {
    return {
      collectionViews: this.props.collectionViews,
      handleNav: this.props.handleNav
    }
  },

  componentDidMount: function () {
    jQuery('html, body').css('overflow', 'hidden')
    jQuery('.home-page-content').addClass('blurred')
    document.querySelector(`.${css.portalPagesResourceFinderLightboxBackground}`).classList.add(css.visible)
    document.querySelector(`.${css.portalPagesResourceFinderLightboxContainer}`).classList.add(css.visible)
  },

  componentWillUnmount: function () {
    jQuery('html, body').css('overflow', 'auto')
    jQuery('.home-page-content').removeClass('blurred')
  },

  handleClose: function (e) {
    if (e.target.className === css.portalPagesResourceFinderLightboxBackgroundClose ||
        e.target.className === css.portalPagesResourceFinderLightbox) {
      this.props.closeLightbox(e)
    }
  },

  handleSwitchSource: function (e) {
    const { handleNav } = this.state
    const collectionId = e.target.value
    console.log('switch to ' + collectionId)
    handleNav(e, collectionId)
  },

  render: function () {
    const { collectionViews } = this.state
    return (
      <div>
        <div className={css.portalPagesResourceFinderLightboxBackground} />
        <div id='pprfl' className={css.portalPagesResourceFinderLightboxContainer}>
          <div id='finderLightbox' className={css.portalPagesResourceFinderLightbox} onClick={(e) => this.handleClose(e)}>
            <div className={css.portalPagesResourceFinderLightboxBackgroundClose} onClick={(e) => this.handleClose(e)}>
              x
            </div>
            <div id='finderLightboxModal' className={css.portalPagesResourceFinderLightboxModal}>
              <LightboxNav collectionViews={collectionViews} handleSwitchSource={(e) => this.handleSwitchSource(e)} />
              <StemFinder hideFeatured />
            </div>
          </div>
        </div>
      </div>
    )
  }
})

export default ResourceFinderLightbox
