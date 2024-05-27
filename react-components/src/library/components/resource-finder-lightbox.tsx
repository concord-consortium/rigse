import React from "react";
import Component from "../helpers/component";
import StemFinder from "./stem-finder";
import LightboxNav from "./lightbox-nav";

import css from "./resource-finder-lightbox.scss";

const ResourceFinderLightbox = Component({
  getInitialState () {
    return {
      collectionViews: this.props.collectionViews,
      handleNav: this.props.handleNav
    };
  },

  componentDidMount () {
    jQuery("html, body").css("overflow", "hidden");
    jQuery(".home-page-content").addClass("blurred");
    // @ts-expect-error TS(2531): Object is possibly 'null'.
    document.querySelector(`.${css.portalPagesResourceFinderLightboxBackground}`).classList.add(css.visible);
    // @ts-expect-error TS(2531): Object is possibly 'null'.
    document.querySelector(`.${css.portalPagesResourceFinderLightboxContainer}`).classList.add(css.visible);
  },

  componentWillUnmount () {
    jQuery("html, body").css("overflow", "auto");
    jQuery(".home-page-content").removeClass("blurred");
  },

  handleClose (e: any) {
    if (e.target.className === css.portalPagesResourceFinderLightboxBackgroundClose ||
        e.target.className === css.portalPagesResourceFinderLightbox) {
      this.props.closeLightbox(e);
    }
  },

  handleSwitchSource (e: any) {
    const { handleNav } = this.state;
    const collectionId = e.target.value;
    handleNav(e, collectionId);
  },

  render () {
    const { collectionViews } = this.state;
    return (
      <div>
        <div className={css.portalPagesResourceFinderLightboxBackground} />
        <div id="pprfl" className={css.portalPagesResourceFinderLightboxContainer}>
          <div id="finderLightbox" className={css.portalPagesResourceFinderLightbox} onClick={(e) => this.handleClose(e)}>
            <div className={css.portalPagesResourceFinderLightboxBackgroundClose} onClick={(e) => this.handleClose(e)}>
              x
            </div>
            <div id="finderLightboxModal" className={css.portalPagesResourceFinderLightboxModal}>
              <LightboxNav collectionViews={collectionViews} handleSwitchSource={(e: any) => this.handleSwitchSource(e)} />
              <StemFinder hideFeatured />
            </div>
          </div>
        </div>
      </div>
    );
  }
});

export default ResourceFinderLightbox;
