import React from 'react'
import Component from '../helpers/component'

import ResourceLightbox from './resource-lightbox'
import ResourceType from './resource-type'
import GradeLevels from './grade-levels'
import Lightbox from '../helpers/lightbox'
import portalObjectHelpers from '../helpers/portal-object-helpers'

// vars for special treatment of hover and click states on touch-enabled devices
let pageScrolling = false
let touchInitialized = false

const StemFinderResult = Component({
  getInitialState: function () {
    return {
      hovering: false,
      favorited: this.props.resource.is_favorite,
      lightbox: false
    }
  },

  componentDidMount: function () {
    document.body.addEventListener('touchstart', this.handleTouchStart)
    document.body.addEventListener('touchmove', this.handleTouchMove)
    document.body.addEventListener('touchend', this.handleTouchEnd)
  },

  componentWillUnmount: function () {
    document.body.removeEventListener('touchstart', this.handleTouchStart)
    document.body.removeEventListener('touchmove', this.handleTouchMove)
    document.body.removeEventListener('touchend', this.handleTouchEnd)
  },

  handleTouchStart: function (e) {
    e.stopPropagation()
    touchInitialized = true
    pageScrolling = false
  },

  handleTouchMove: function (e) {
    e.stopPropagation()
    touchInitialized = true
    pageScrolling = true
  },

  handleTouchEnd: function (e) {
    e.stopPropagation()
    if (pageScrolling) {

    }
  },

  handleMouseOver: function (e) {
    if (this.state.lightbox) {
      return
    }
    if (touchInitialized === false && pageScrolling === false) {
      this.setState({ hovering: true })
    }
  },

  handleMouseOut: function () {
    if (this.state.lightbox) {
      return
    }
    this.setState({ hovering: false })
  },

  toggleLightbox: function (e) {
    e.preventDefault()
    e.stopPropagation()
    let lightbox = !this.state.lightbox

    this.setState({
      lightbox: lightbox,
      hovering: false
    })

    // mount/unmount lightbox outside of homepage content
    if (lightbox && pageScrolling === false) {
      let resourceLightbox = ResourceLightbox({
        resource: this.props.resource,
        parentPage: window.location.pathname,
        toggleLightbox: this.toggleLightbox
      })
      Lightbox.open(resourceLightbox)
      ga('send', 'event', 'Home Page Resource Card', 'Click', this.props.resource.name)
    } else {
      Lightbox.close()
      // reset touchInitialized for touch screen devices with mouse or trackpad
      touchInitialized = false
    }
  },

  toggleFavorite: function (e) {
    e.preventDefault()
    e.stopPropagation()

    if (!Portal.currentUser.isLoggedIn || !Portal.currentUser.isTeacher) {
      let mouseX = e.pageX + 31
      let mouseY = e.pageY - 23
      jQuery('body').append('<div class="portal-pages-favorite-tooltip">Log in or sign up to save resources for quick access!</div>')
      jQuery('.portal-pages-favorite-tooltip').css({ 'left': mouseX + 'px', 'top': mouseY + 'px' }).fadeIn('fast')

      window.setTimeout(function () {
        jQuery('.portal-pages-favorite-tooltip').fadeOut('slow', function () { jQuery(this).remove() })
      }, 3000)
      return
    }

    let resource = this.props.resource
    let done = function () {
      resource.is_favorite = !resource.is_favorite
      this.setState({ favorited: resource.is_favorite })
    }.bind(this)
    if (resource.is_favorite) {
      jQuery.post('/api/v1/materials/remove_favorite', { favorite_id: resource.favorite_id }, done)
      ga('send', 'event', 'Favorite Button', 'Click', `${resource.name} removed from favorites`)
    } else {
      jQuery.post('/api/v1/materials/add_favorite', { id: resource.id, material_type: resource.class_name_underscored }, done)
      ga('send', 'event', 'Favorite Button', 'Click', `${resource.name} added to favorites`)
    }
  },

  renderFavoriteStar: function () {
    let active = this.state.favorited ? ' portal-pages-finder-result-favorite-active' : ''
    const divClass = 'portal-pages-finder-result-favorite' + active
    return (
      <div className={divClass} onClick={this.toggleFavorite}>
        <i className={'icon-favorite'} />
      </div>
    )
  },

  render: function () {
    const resource = this.props.resource

    // truncate title and/or description if they are too long for resource card height
    const maxCharTitle = 125
    const maxCharDesc = 320
    let resourceName = portalObjectHelpers.shortenText(resource.name, maxCharTitle, true)
    let shortDesc = resource.filteredShortDescription
    if (shortDesc.length + resource.name.length >= maxCharDesc) { // use full resource name on 'back' of card, not truncated version
      shortDesc = portalObjectHelpers.shortenText(shortDesc, maxCharDesc - resource.name.length, true)
    }

    if (this.state.hovering || this.state.lightbox) {
      return (
        <div className={'portal-pages-finder-result col-4'} onClick={this.toggleLightbox} onMouseOver={this.handleMouseOver} onMouseOut={this.handleMouseOut}>
          <a href={resource.stem_resource_url}>
            <div className={'portal-pages-finder-result-description'}>
              <div className={'title'}>
                {resource.name}
              </div>
              <div>
                {shortDesc}
              </div>
            </div>
            {this.renderFavoriteStar()}
          </a>
          <GradeLevels resource={resource} />
          {this.renderFavoriteStar()}
        </div>
      )
    }
    return (
      <div className={'portal-pages-finder-result col-4'} onClick={this.toggleLightbox} onMouseOver={this.handleMouseOver} onMouseOut={this.handleMouseOut}>
        <a href={resource.stem_resource_url}>
          <div className={'portal-pages-finder-result-image-preview'}>
            <img alt={resource.name} src={resource.icon.url} />
            <ResourceType resource={resource} />
          </div>
          <div className={'portal-pages-finder-result-name'}>
            {resourceName}
          </div>
          {this.renderFavoriteStar()}
        </a>
        <GradeLevels resource={resource} />
      </div>
    )
  }
})

export default StemFinderResult
