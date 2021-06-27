import React from 'react'
import Component from '../helpers/component'

import css from './collection-lightbox.scss'

var CollectionLightbox = Component({
  getInitialState: function () {
    return {
      collectionDescription: '',
      collectionId: this.props.collectionId,
      collectionName: '',
      isLoaded: false,
      landingPageSlug: null
    }
  },

  componentDidMount: function () {
    jQuery('html, body').css('overflow', 'hidden')
    jQuery('.home-page-content').addClass('blurred')
    document.querySelector(`.${css.portalPagesCollectionLightboxBackground}`).classList.add(css.visible)
    document.querySelector(`.${css.portalPagesCollectionLightboxContainer}`).classList.add(css.visible)

    jQuery.ajax({
      url: '/api/v1/projects/' + this.state.collectionId,
      dataType: 'json',
      success: function (data) {
        this.setState({
          collectionName: data.name,
          collectionDescription: data.project_card_description,
          isLoaded: true,
          landingPageSlug: data.landing_page_slug
        })
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

  render: function () {
    const collectionDescription = this.state.collectionDescription
    const collectionName = this.state.collectionName
    const collectionSlug = this.state.landingPageSlug
    return (
      <div>
        <div className={css.portalPagesCollectionLightboxBackground} />
        <div id='pprfl' className={css.portalPagesCollectionLightboxContainer}>
          <div id='collectionLightbox' className={css.portalPagesCollectionLightbox} onClick={(e) => this.handleClose(e)}>
            <div className={css.portalPagesCollectionLightboxBackgroundClose} onClick={(e) => this.handleClose(e)}>
              x
            </div>
            <div id='collectionLightboxModal' className={css.portalPagesCollectionLightboxModal}>
              <div className={css.portalPagesCollectionLightboxHeading}>
                <h1>{collectionName}</h1>
                <div dangerouslySetInnerHTML={{ __html: collectionDescription }} />
              </div>
              <div className={css.portalPagesCollectionLightboxCollection}>
                <div id='collectionIframeLoading' className={css.loading}>loading</div>
                {collectionSlug && <iframe id='collectionIframe' src={`/${collectionSlug}`} scrolling='no' onLoad={(e) => this.handleIframeResize(e)} />}
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
})

export default CollectionLightbox
