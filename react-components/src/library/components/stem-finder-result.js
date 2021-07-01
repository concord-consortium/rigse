import React from 'react'
import Component from '../helpers/component'
import { MakeTeacherEditionLink } from '../helpers/make-teacher-edition-links'
import ResourceLightbox from './resource-lightbox'
import GradeLevels from './grade-levels'
import RelatedResourceResult from './related-resource-result'
import Lightbox from '../helpers/lightbox'
// import portalObjectHelpers from '../helpers/portal-object-helpers'
import StandardsHelpers from '../helpers/standards-helpers'

import css from './stem-finder-result.scss'

// vars for special treatment of hover and click states on touch-enabled devices
let pageScrolling = false
let touchInitialized = false

const stemFinderResult = Component({
  getInitialState: function () {
    return {
      favorited: this.props.resource.is_favorite,
      hovering: false,
      isOpen: false,
      lightbox: false,
      showTeacherResourcesButton: false
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
    let active = this.state.favorited ? css.finderResultFavoriteActive : ''
    const divClass = css.finderResultFavorite + ' ' + active
    return (
      <div className={divClass} onClick={this.toggleFavorite}>
        <i className={'icon-favorite'} />
      </div>
    )
  },

  renderTimeRequired: function () {
    const resource = this.props.resource
    const timeRequired = resource.material_type === 'Activity'
      ? '45 Minutes'
      : resource.material_type === 'Investigation'
        ? '2 Weeks'
        : resource.material_type === 'Model'
          ? 'Varies'
          : null

    if (timeRequired === null) {
      return
    }
    return (
      <div className={`${css.metaTag} ${css.timeRequired}`}>
        {timeRequired}
      </div>
    )
  },

  renderLinks: function () {
    const { resource } = this.props
    const isCollection = resource.material_type === 'Collection'
    const isAssignWrapped = window.self !== window.top &&
      window.self.location.hostname === window.top.location.hostname
    const assignHandler = resource.links.assign_material && isAssignWrapped
      ? `javascript: window.parent.${resource.links.assign_material.onclick}`
      : resource.links.assign_material
        ? `javascript: ${resource.links.assign_material.onclick}`
        : null
    const assignLink = resource.links.assign_material && !isCollection
      ? <a href={assignHandler}>{resource.links.assign_material.text}</a>
      : null
    const copyLink = resource.links.copy_url && Portal.currentUser.isTeacher && !isCollection
      ? <a href={resource.links.copy_url} target='_blank'>Copy</a>
      : null
    const printLink = resource.links.print_url && !isCollection
      ? <a href={resource.links.print_url} target='_blank'>Print</a>
      : null
    const teacherEditionLink = resource.has_teacher_edition && Portal.currentUser.isTeacher
      ? <a href={MakeTeacherEditionLink(resource.external_url)} target='_blank'>Teacher Edition</a>
      : null

    return (
      <>
        {assignLink}
        {teacherEditionLink}
        {printLink}
        {copyLink}
      </>
    )
  },

  hasLongDescription: function () {
    const { resource } = this.props
    const hasDesc = resource.filteredShortDescription.length > 210
    return hasDesc
  },

  hasStandards: function () {
    const { resource } = this.props
    return resource.standard_statements.length > 0
  },

  isCollection: function () {
    const { resource } = this.props
    return resource.material_type === 'Collection'
  },

  renderMoreToggle: function () {
    if ((!this.hasLongDescription() && !this.hasStandards()) || this.isCollection()) {
      return (null)
    }

    return (
      <>
        <a href='#' className={css.moreLink} onClick={this.toggleResource}>More</a>
        <a href='#' className={css.lessLink} onClick={this.toggleResource}>Less</a>
      </>
    )
  },

  renderStandards: function () {
    const { resource } = this.props
    if (!this.hasStandards()) {
      return null
    }

    const allStatements = resource.standard_statements
    let helpers = {}
    let unhelped = []

    helpers.NGSS = StandardsHelpers.getStandardsHelper('NGSS')

    for (let i = 0; i < allStatements.length; i++) {
      let statement = allStatements[i]
      let helper = helpers[statement.type]

      if (helper) {
        helper.add(statement)
      } else {
        unhelped.push(statement)
      }
    }

    const unhelpedStandards = unhelped.map(function (statement) {
      var description = statement.description
      if (Array.isArray && Array.isArray(description)) {
        var formatted = ''
        for (var i = 0; i < description.length; i++) {
          if (description[i].endsWith(':')) {
            description[i] += ' '
          } else if (!description[i].endsWith('.')) {
            description[i] += '. '
          }
          formatted += description[i]
        }
        description = formatted
      }
      return (
        <div>
          <h3>{statement.notation}</h3>
          {description}
        </div>
      )
    })

    return (
      <div className={`${css.collapsible} ${css.finderResultStandards}`}>
        <h2 onClick={this.toggleCollapsible} className={css.collapsibleHeading}>Standards</h2>
        <div className={css.collapsibleBody}>
          {helpers.NGSS.getDiv()}
          {unhelpedStandards}
        </div>
      </div>
    )
  },

  renderRelatedResources: function (e) {
    const resource = this.props.resource
    if (resource.related_materials.length === 0 || resource.material_type === 'Collection') {
      return null
    }

    const relatedResources = resource.related_materials.map(function (resource, i) {
      if (i < 2) {
        return RelatedResourceResult({ key: i, resource: resource, replaceResource: this.replaceResource })
      }
    }.bind(this))

    return (
      <div className={css.collapsible}>
        <h2 onClick={this.toggleCollapsible} className={css.collapsibleHeading}>Related Activities</h2>
        {relatedResources}
      </div>
    )
  },

  toggleResource: function (e) {
    e.preventDefault()
    this.setState({ isOpen: !this.state.isOpen })
  },

  toggleCollapsible: function (e) {
    jQuery(e.currentTarget).parent().toggleClass(css.collapsibleOpen)
  },

  render: function () {
    const { resource } = this.props
    const resourceTypeClass = resource.material_type.toLowerCase()
    const finderResultClasses = this.state.isOpen ? `${css.finderResult} ${css.open} ${css[resourceTypeClass]}` : `${css.finderResult} ${css[resourceTypeClass]}`
    const resourceName = resource.name
    const shortDesc = resource.filteredShortDescription
    const projectName = resource.projects[0] ? resource.projects[0].name : null
    const projectNameRegex = / |-|\./g
    const projectClass = projectName ? projectName.replace(projectNameRegex, '').toLowerCase() : null

    return (
      <div className={finderResultClasses}>
        <div className={css.finderResultImagePreview}>
          <img alt={resource.name} src={resource.icon.url} />
        </div>
        <div className={css.finderResultText}>
          <div className={css.finderResultTextName}>
            {resourceName}
          </div>
          <div className={css.metaTags}>
            <GradeLevels resource={resource} />
            {this.renderTimeRequired()}
          </div>
          <div className={css.finderResultTextDescription}>
            {shortDesc}
          </div>
        </div>
        <div className={css.previewLink}>
          {resource.material_type !== 'Collection'
            ? <a className={css.previewLinkButton} href={resource.links.preview.url} target='_blank'>{resource.links.preview.text}</a>
            : <a className={css.previewLinkButton} href={resource.links.preview.url} target='_blank'>View Collection</a>
          }
          {resource.material_type !== 'Collection' &&
            <div className={`${css.projectLabel} ${css[projectClass]}`}>
              {projectName}
            </div>
          }
        </div>
        {this.renderStandards()}
        {this.renderRelatedResources()}
        <div className={css.finderResultLinks}>
          {this.renderLinks()}
          {this.renderMoreToggle()}
        </div>
        {this.renderFavoriteStar()}
      </div>
    )
  }
})

export default stemFinderResult
