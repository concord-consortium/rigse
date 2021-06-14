import React from 'react'
import Component from '../helpers/component'
import StemFinder from './stem-finder'

import css from './resource-finder-lightbox.scss'

var ResourceFinderLightbox = Component({
  getInitialState: function () {
    return null
  },

  getDefaultProps: function () {
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
    console.log()
    if (e.target.className === css.portalPagesResourceFinderLightboxBackgroundClose ||
        e.target.className === css.portalPagesResourceFinderLightbox) {
      this.props.closeLightbox(e)
    }
  },

  render: function () {
    return (
      <div>
        <div className={css.portalPagesResourceFinderLightboxBackground} />
        <div className={css.portalPagesResourceFinderLightboxContainer}>
          <div className={css.portalPagesResourceFinderLightbox} onClick={(e) => this.handleClose(e)}>
            <div className={css.portalPagesResourceFinderLightboxBackgroundClose} onClick={(e) => this.handleClose(e)}>
              x
            </div>
            <div className={css.portalPagesResourceFinderLightboxModal}>
              <StemFinder />
            </div>
          </div>
        </div>
      </div>
    )
  }
})

export default ResourceFinderLightbox
