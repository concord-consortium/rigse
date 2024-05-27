import React from "react";
import Component from "../helpers/component";
import LightboxNav from "./lightbox-nav";

import css from "./collection-lightbox.scss";

const CollectionLightbox = Component({
  getInitialState () {
    return {
      collectionId: this.props.collectionId,
      collectionName: "",
      collectionViews: this.props.collectionViews,
      handleNav: this.props.handleNav,
      isLoaded: false,
      landingPageSlug: null,
      returnPath: null,
      returnLinkText: null
    };
  },

  componentDidMount () {
    const { collectionId } = this.state;
    jQuery.ajax({
      url: "/api/v1/projects/" + collectionId,
      dataType: "json",
      success: function (data: any) {
        this.setState({
          collectionName: data.name,
          isLoaded: true,
          landingPageSlug: data.landing_page_slug
        });
        jQuery("html, body").css("overflow", "hidden");
        jQuery(".home-page-content").addClass("blurred");
        document.querySelector(`.${css.portalPagesCollectionLightboxBackground}`)?.classList.add(css.visible);
        document.querySelector(`.${css.portalPagesCollectionLightboxContainer}`)?.classList.add(css.visible);
      }.bind(this)
    });
  },

  componentWillUnmount () {
    jQuery("html, body").css("overflow", "auto");
    jQuery(".home-page-content").removeClass("blurred");
  },

  handleClose (e: any) {
    if (e.target.className === css.portalPagesCollectionLightboxBackgroundClose ||
        e.target.className === css.portalPagesCollectionLightbox) {
      this.props.closeLightbox(e);
    }
  },

  handleIframeOnload (e: any) {
    this.handleIframeResize(e);
    this.handleIframeSourceChange(e);
  },

  handleIframeResize (e: any) {
    const iframe = e.target;
    iframe.style.height = iframe.contentWindow.document.body.scrollHeight + "px";
  },

  handleIframeSourceChange (e: any) {
    const { landingPageSlug } = this.state;
    const iframe = e.target;
    const iframePath = iframe.contentWindow.location.pathname.replace("/", "");
    if (iframePath !== landingPageSlug) {
      this.setState({
        returnPath: landingPageSlug
      });
    } else {
      this.setState({
        returnPath: null
      });
    }
  },

  handleSwitchSource (e: any) {
    const { handleNav } = this.state;
    const collectionId = e.target.value;
    handleNav(e, collectionId);
  },

  handleReturnButtonClick () {
    const { returnPath } = this.state;
    this.setState({
      returnPath: null
    });
    // @ts-expect-error TS(2531): Object is possibly 'null'.
    document.getElementById("collectionIframe").style.visibility = "hidden";
    // @ts-expect-error TS(2531): Object is possibly 'null'.
    document.getElementById("collectionIframeLoading").style.display = "block";
    // @ts-expect-error TS(2531): Object is possibly 'null'.
    document.getElementById("collectionIframe").src = "/" + returnPath;
  },

  renderReturnButton () {
    const { collectionName } = this.state;
    return (
      <button onClick={this.handleReturnButtonClick} className={css.portalPagesCollectionLightboxReturnButton}>&laquo; Return to { collectionName } Collection Overview</button>
    );
  },

  render () {
    const { collectionName, collectionViews, isLoaded, landingPageSlug, returnPath } = this.state;
    if (!isLoaded) {
      return (null);
    }
    return (
      <div>
        <div className={css.portalPagesCollectionLightboxBackground} />
        <div id="pprfl" className={css.portalPagesCollectionLightboxContainer}>
          <div id="collectionLightbox" className={css.portalPagesCollectionLightbox} onClick={(e) => this.handleClose(e)}>
            <div className={css.portalPagesCollectionLightboxBackgroundClose} onClick={(e) => this.handleClose(e)}>
              x
            </div>
            <div id="collectionLightboxModal" className={css.portalPagesCollectionLightboxModal}>
              <LightboxNav collectionName={collectionName} collectionViews={collectionViews} handleSwitchSource={(e: any) => this.handleSwitchSource(e)} />
              { returnPath !== null && this.renderReturnButton() }
              <div className={css.portalPagesCollectionLightboxCollection}>
                <div id="collectionIframeLoading" className={css.loading}>loading</div>
                { landingPageSlug && <iframe id="collectionIframe" src={`/${landingPageSlug}`} scrolling="no" onLoad={(e) => this.handleIframeOnload(e)} /> }
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});

export default CollectionLightbox;
