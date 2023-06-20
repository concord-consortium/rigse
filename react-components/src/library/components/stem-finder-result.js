import React from 'react'
import Component from '../helpers/component'
import { MakeTeacherEditionLink } from '../helpers/make-teacher-edition-links'
import GradeLevels from './grade-levels'
import StemFinderResultStandards from './stem-finder-result-standards'
import RelatedResourceResult from './related-resource-result'

import css from './stem-finder-result.scss'

// vars for special treatment of hover and click states on touch-enabled devices
let pageScrolling = false
let touchInitialized = false

const StemFinderResult = Component({
  getInitialState: function () {
    return {
      favorited: this.props.resource.is_favorite,
      hovering: false,
      isOpen: false,
      lightbox: false,
      showTeacherResourcesButton: false,
      showResource: this.props.showResource
    }
  },

  componentDidMount: function () {
    this.setState({ hasLoaded: true })
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
      gtag('event', 'click', {
        'category': 'Favorite Button',
        'resource': `${resource.name} removed from favorites`
      })
    } else {
      jQuery.post('/api/v1/materials/add_favorite', { id: resource.id, material_type: resource.class_name_underscored }, done)
      gtag('event', 'click', {
        'category': 'Favorite Button',
        'resource': `${resource.name} added to favorites`
      })
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

  // This function no longer called. Leaving here in case we want to restore call with different return value.
  renderTimeRequired: function () {
    const resource = this.props.resource
    const timeRequired = resource.material_type === 'Activity'
      ? '45 Minutes'
      : resource.material_type === 'Investigation'
        ? '2 Weeks'
        : resource.material_type === 'Interactive'
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

  renderTags: function () {
    const resource = this.props.resource

    // show the private badge only for private community resources
    if (!resource.is_official && (resource.publication_status === 'private')) {
      return (
        <div className={`${css.metaTag} ${css.private}`}>
          Private
        </div>
      )
    }
    // show the community badge only for public community resources
    if (!resource.is_official && (resource.publication_status === 'published')) {
      return (
        <div className={`${css.metaTag} ${css.community}`}>
          Community
        </div>
      )
    }
  },

  renderAssignedClasses: function () {
    const { resource } = this.props
    if (resource.assigned_classes.length < 1) {
      return
    }
    const assignedClasses = resource.assigned_classes.join(', ')
    return (
      <div className={css.assignedTo}>
        Assigned to {assignedClasses}
      </div>
    )
  },

  handlePreviewClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Resource Preview Button',
      'resource': resource.name
    })
  },

  handleViewCollectionClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Resource View Collection Button',
      'resource': resource.name
    })
  },

  handleTeacherEditionClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Resource Teacher Edition Button',
      'resource': resource.name
    })
  },

  handleTeacherResourcesClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Resource Teacher Resources Button',
      'resource': resource.name
    })
  },

  handleAssignClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Assign to Class Button',
      'resource': resource.name
    })
  },

  handleTeacherGuideClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Teacher Guide Link',
      'resource': resource.name
    })
  },

  handleAddToCollectionClick: function (e) {
    const { resource } = this.props
    gtag('event', 'click', {
      'category': 'Add to Collection Button',
      'resource': resource.name
    })
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
      ? <a href={assignHandler} onClick={this.handleAssignClick}>{resource.links.assign_material.text}</a>
      : null
    const editLinkUrl = resource.lara_activity_or_sequence && resource.links.external_lara_edit
      ? resource.links.external_lara_edit.url
      : resource.links.external_edit
        ? resource.links.external_edit.url
        : null
    const editLink = editLinkUrl
      ? <a href={editLinkUrl} target='_blank' rel='noopener'>Edit</a>
      : null
    const copyLink = resource.links.external_copy && !isCollection
      ? <a href={resource.links.external_copy.url} target='_blank' rel='noopener'>{resource.links.external_copy.text}</a>
      : null
    // const printLink = resource.links.print_url && !isCollection
    //   ? <a href={resource.links.print_url.url} target='_blank' rel='noopener'>{resource.links.print_url.text}</a>
    //   : null
    const teacherEditionLink = resource.has_teacher_edition && Portal.currentUser.isTeacher
      ? <a href={MakeTeacherEditionLink(resource.external_url)} target='_blank' rel='noopener' onClick={this.handleTeacherEditionClick}>Teacher Edition</a>
      : null
    const teacherGuideLink = resource.links.teacher_guide && Portal.currentUser.isTeacher
      ? <a href={resource.links.teacher_guide.url} target='_blank' rel='noopener' onClick={this.handleTeacherGuideClick}>{resource.links.teacher_guide.text}</a>
      : null
    const teacherResourcesLink = resource.links.teacher_resources && Portal.currentUser.isTeacher
      ? <a href={resource.links.teacher_resources.url} target='_blank' rel='noopener' onClick={this.handleTeacherResourcesClick}>{resource.links.teacher_resources.text}</a>
      : null
    const assignCollectionLink = resource.links.assign_collection && (Portal.currentUser.isAdmin || Portal.currentUser.isManager)
      ? <a href={resource.links.assign_collection.url} target='_blank' onClick={this.handleAddToCollectionClick}>{resource.links.assign_collection.text}</a>
      : null
    const portalSettingsLink = resource.links.edit && (Portal.currentUser.isAdmin || Portal.currentUser.isManager)
      ? <a href={resource.links.edit.url} target='_blank'>Settings</a>
      : null

    return (
      <>
        {assignLink}
        {teacherEditionLink}
        {teacherGuideLink}
        {teacherResourcesLink}
        {editLink}
        {copyLink}
        {assignCollectionLink}
        {portalSettingsLink}
      </>
    )
  },

  hasStandards: function () {
    const { resource } = this.props
    return resource.standard_statements.length > 0
  },

  renderStandards: function () {
    const { resource } = this.props
    return (
      <div className={`${css.collapsible} ${css.finderResultStandards}`}>
        <h2 onClick={this.toggleCollapsible} className={css.collapsibleHeading}>Standards</h2>
        <div className={css.collapsibleBody}>
          <StemFinderResultStandards standardStatements={resource.standard_statements} />
        </div>
      </div>
    )
  },

  renderMoreToggle: function () {
    const { resource } = this.props
    const needsMoreToggle = resource.filteredShortDescription.length > 210 || this.hasStandards()

    if (!needsMoreToggle) {
      return (null)
    }

    return (
      <>
        <a href='#' className={css.moreLink} onClick={this.toggleResource}>More</a>
        <a href='#' className={css.lessLink} onClick={this.toggleResource}>Less</a>
      </>
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
    const { resource, index } = this.props
    const resourceTypeClass = resource.material_type.toLowerCase()
    const finderResultClasses = this.state.isOpen ? `resourceItem ${css.finderResult} ${css.open} ${css[resourceTypeClass]}` : `resourceItem ${css.finderResult} ${css[resourceTypeClass]}`
    const resourceName = resource.name
    const resourceLink = resource.stem_resource_url
    const shortDesc = resource.filteredShortDescription
    const projectName = resource.projects[0] ? resource.projects[0].name : null
    const projectNameRegex = / |-|\./g
    const projectClass = projectName ? projectName.replace(projectNameRegex, '').toLowerCase() : null
    const transitionDelay = 100 * index

    return (
      <div className={finderResultClasses} style={{ transitionDelay: transitionDelay + 'ms' }}>
        <div className={css.finderResultImagePreview}>
          <img alt={resource.name} src={resource.icon.url} />
        </div>
        <div className={css.finderResultText}>
          <div className={css.finderResultTextName}>
            <a href={resourceLink} target='_blank' title={resourceName}>{resourceName}</a>
          </div>
          <div className={css.metaTags}>
            <GradeLevels resource={resource} />
            {this.renderTags()}
            {this.renderAssignedClasses()}
          </div>
          <div className={css.finderResultTextDescription}>
            {shortDesc}
          </div>
        </div>
        <div className={css.previewLink}>
          {resource.material_type !== 'Collection'
            ? <a className={css.previewLinkButton} href={resource.links.preview.url} target='_blank' onClick={this.handlePreviewClick}>{resource.links.preview.text}</a>
            : <a className={css.previewLinkButton} href={resource.links.preview.url} target='_blank' onClick={this.handleViewCollectionClick}>View Collection</a>
          }
          {resource.material_type !== 'Collection' &&
            <div className={`${css.projectLabel} ${css[projectClass]}`}>
              {projectName}
            </div>
          }
        </div>
        {this.hasStandards() && this.renderStandards()}
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

export default StemFinderResult
