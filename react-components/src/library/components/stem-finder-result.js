import React from 'react'
import Component from '../helpers/component'

import ResourceLightbox from './resource-lightbox'
import GradeLevels from './grade-levels'
import Lightbox from '../helpers/lightbox'
import portalObjectHelpers from '../helpers/portal-object-helpers'

import css from './stem-finder-result.scss'

// vars for special treatment of hover and click states on touch-enabled devices
let pageScrolling = false
let touchInitialized = false

const stemFinderResult = Component({
  getInitialState: function () {
    return {
      hovering: false,
      isOpen: false,
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
    } else {
      jQuery.post('/api/v1/materials/add_favorite', { id: resource.id, material_type: resource.class_name_underscored }, done)
    }
  },

  renderFavoriteStar: function () {
    let active = this.state.favorited ? css.finderResultFavoriteActive : ''
    const divClass = css.finderResultFavorite + ' ' + active
    return (
      <div className={divClass} onClick={this.toggleFavorite}>
        <i className={'icon-favorite'} />
      </div>
    )
  },

  renderLinks: function () {
    const resource = this.props.resource
    // console.log(resource)
    const assignLink = resource.links.assign_material
      ? <a href={`javascript: ${resource.links.assign_material.onclick}`}>{resource.links.assign_material.text}</a>
      : null
    const copyLink = resource.links.copy_url
      ? <a href={resource.links.copy_url} target='_blank'>Copy</a>
      : null
    const printLink = resource.links.print_url
      ? <a href={resource.links.print_url} target='_blank'>Print</a>
      : null
    const teacherEditionLink = resource.has_teacher_edition
      ? <a href={`${resource.links.preview.url}?mode=teacher-edition`} target='_blank'>Teacher Edition</a>
      : null

    return (
      <div className={css.finderResultLinks}>
        {assignLink}
        {teacherEditionLink}
        {printLink}
        {copyLink}
        <a href='#' className={css.moreLink} onClick={this.toggleResource}>More</a>
        <a href='#' className={css.lessLink} onClick={this.toggleResource}>Less</a>
      </div>
    )
  },

  toggleResource: function (e) {
    e.preventDefault()
    this.setState({ isOpen: !this.state.isOpen })
  },

  toggleCollapsible: function (e) {
    console.log(e)
    jQuery(e.currentTarget).parent().toggleClass(css.collapsibleOpen)
  },

  render: function () {
    const resource = this.props.resource
    const finderResultClasses = this.state.isOpen ? `${css.finderResult} ${css.open}` : css.finderResult
    // truncate title and/or description if they are too long for resource card height
    // const maxCharTitle = 180
    const maxCharDesc = 180
    const resourceName = resource.name
    const shortDesc = this.state.isOpen ? resource.filteredShortDescription : portalObjectHelpers.shortenText(resource.filteredShortDescription, maxCharDesc, true)
    const projectName = resource.projects[0] ? resource.projects[0].name : null
    const projectNameRegex = / |-|\./
    const projectClass = projectName ? projectName.replace(projectNameRegex, '').toLowerCase() : null
    console.log(projectClass)
    const projectNameShow = projectName
      ? projectName === 'NGSS Assessment'
        ? projectName.substr(0, 11) + '.' : projectName
      : null

    return (
      <div className={finderResultClasses}>
        <div className={css.finderResultImagePreview}>
          <img alt={resource.name} src={resource.icon.url} />
          <GradeLevels resource={resource} />
        </div>
        <div className={css.finderResultText}>
          <div className={css.finderResultTextName}>
            {resourceName}
          </div>
          <div className={css.finderResultTextDescription}>
            {shortDesc}
          </div>
        </div>
        <div className={css.previewLink}>
          <a className={css.previewLinkButton} href={resource.links.preview.url} target='_blank'>{resource.links.preview.text}</a>
          <div className={`${css.projectLabel} ${css[projectClass]}`}>
            {projectNameShow}
          </div>
        </div>
        <div className={css.collapsible}>
          <h2 onClick={this.toggleCollapsible} className={css.collapsibleHeading}>Standards</h2>
          <div className={css.collapsibleBody}>
            <p>Globular star cluster venture cosmos billions upon billions intelligent beings cosmic fugue. Hundreds of thousands hundreds of thousands with pretty stories for which there's little good evidence muse about as a patch of light laws of physics.</p>
            <p>Emerged into consciousness white dwarf vastness is bearable only through love the only home we've ever known made in the interiors of collapsing stars bits of moving fluff? A very small stage in a vast cosmic arena gathered by gravity made in the interiors of collapsing stars invent the universe a mote of dust suspended in a sunbeam made in the interiors of collapsing stars and billions upon billions upon billions upon billions upon billions upon billions upon billions.</p>
          </div>
        </div>
        <div className={css.collapsible}>
          <h2 onClick={this.toggleCollapsible} className={css.collapsibleHeading}>Related Materials</h2>
          <div className={css.collapsibleBody}>
            <p>Globular star cluster venture cosmos billions upon billions intelligent beings cosmic fugue. Hundreds of thousands hundreds of thousands with pretty stories for which there's little good evidence muse about as a patch of light laws of physics.</p>
            <p>Emerged into consciousness white dwarf vastness is bearable only through love the only home we've ever known made in the interiors of collapsing stars bits of moving fluff? A very small stage in a vast cosmic arena gathered by gravity made in the interiors of collapsing stars invent the universe a mote of dust suspended in a sunbeam made in the interiors of collapsing stars and billions upon billions upon billions upon billions upon billions upon billions upon billions.</p>
          </div>
        </div>
        {this.renderLinks()}
        {this.renderFavoriteStar()}
      </div>
    )
  }
})

export default stemFinderResult
