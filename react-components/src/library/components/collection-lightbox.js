import React from 'react'
import Component from '../helpers/component'
import LightboxNav from './lightbox-nav'

import css from './collection-lightbox.scss'

const CollectionLightbox = Component({
  getInitialState: function () {
    return {
      collectionId: this.props.collectionId,
      collectionName: '',
      collectionViews: this.props.collectionViews,
      handleNav: this.props.handleNav,
      isLoaded: false,
      landingPageSlug: null
    }
  },

  componentDidMount: function () {
    const { collectionId } = this.state
    jQuery.ajax({
      url: '/api/v1/projects/' + collectionId,
      dataType: 'json',
      success: function (data) {
        this.setState({
          collectionName: data.name,
          isLoaded: true,
          landingPageSlug: data.landing_page_slug
        })
        jQuery('html, body').css('overflow', 'hidden')
        jQuery('.home-page-content').addClass('blurred')
        document.querySelector(`.${css.portalPagesCollectionLightboxBackground}`).classList.add(css.visible)
        document.querySelector(`.${css.portalPagesCollectionLightboxContainer}`).classList.add(css.visible)
      }.bind(this)
    })
  },

  componentWillUnmount: function () {
    jQuery('html, body').css('overflow', 'auto')
    jQuery('.home-page-content').removeClass('blurred')
  },

  handleClose: function (e) {
    if (e.target.className === css.portalPagesCollectionLightboxBackgroundClose ||
        e.target.className === css.portalPagesCollectionLightbox) {
      this.props.closeLightbox(e)
    }
  },

  handleIframeResize: function (e) {
    const iframe = e.target
    iframe.style.height = iframe.contentWindow.document.documentElement.scrollHeight + 'px'
  },

  handleSwitchSource: function (e) {
    const { handleNav } = this.state
    const collectionId = e.target.value
    handleNav(e, collectionId)
  },

  render: function () {
    const { collectionName, collectionViews, isLoaded, landingPageSlug } = this.state
    if (!isLoaded) {
      return (null)
    }
    return (
      <div>
        <div className={css.portalPagesCollectionLightboxBackground} />
        <div id='pprfl' className={css.portalPagesCollectionLightboxContainer}>
          <div id='collectionLightbox' className={css.portalPagesCollectionLightbox} onClick={(e) => this.handleClose(e)}>
            <div className={css.portalPagesCollectionLightboxBackgroundClose} onClick={(e) => this.handleClose(e)}>
              x
            </div>
            <div id='collectionLightboxModal' className={css.portalPagesCollectionLightboxModal}>
              <LightboxNav collectionName={collectionName} collectionViews={collectionViews} handleSwitchSource={(e) => this.handleSwitchSource(e)} />
              <div className={css.portalPagesCollectionLightboxCollection}>
                <div id='collectionIframeLoading' className={css.loading}>loading</div>
                {landingPageSlug && <iframe id='collectionIframe' src={`/${landingPageSlug}`} scrolling='no' onLoad={(e) => this.handleIframeResize(e)} />}
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
})

export default CollectionLightbox
