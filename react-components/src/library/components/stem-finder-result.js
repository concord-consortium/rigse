import React from 'react'
import Component from '../helpers/component'

import ResourceLightbox from './resource-lightbox'
import GradeLevels from './grade-levels'
import RelatedResourceResult from './related-resource-result'
import Lightbox from '../helpers/lightbox'
import portalObjectHelpers from '../helpers/portal-object-helpers'
import StandardsHelpers from '../helpers/standards-helpers'

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

  renderTimeRequired: function () {
    const resource = this.props.resource
    const timeRequired = resource.material_type === 'Activity'
      ? '45 minutes'
      : resource.material_type === 'Investigation'
        ? '2 weeks'
        : ''

    if (timeRequired === '') {
      return
    }
    return (
      <div className={`${css.metaTag} ${css.timeRequired}`}>
        {timeRequired}
      </div>
    )
  },

  renderLinks: function () {
    const resource = this.props.resource
    const assignLink = resource.links.assign_material
      ? <a href={`javascript: ${resource.links.assign_material.onclick}`}>{resource.links.assign_material.text}</a>
      : null
    const copyLink = resource.links.copy_url && Portal.currentUser.isTeacher
      ? <a href={resource.links.copy_url} target='_blank'>Copy</a>
      : null
    const printLink = resource.links.print_url
      ? <a href={resource.links.print_url} target='_blank'>Print</a>
      : null
    const teacherEditionLink = resource.has_teacher_edition && Portal.currentUser.isTeacher
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

  renderStandards: function () {
    const resource = this.props.resource
    // if (!resource.standard_statements || resource.standard_statements.length === 0) {
    //   return null
    // }

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

    // const unhelpedStandards = unhelped.map(function (statement) {
    //   var description = statement.description
    //   if (Array.isArray && Array.isArray(description)) {
    //     var formatted = ''
    //     for (var i = 0; i < description.length; i++) {
    //       if (description[i].endsWith(':')) {
    //         description[i] += ' '
    //       } else if (!description[i].endsWith('.')) {
    //         description[i] += '. '
    //       }
    //       formatted += description[i]
    //     }
    //     description = formatted
    //   }
    //   return (
    //     <div>
    //       <h3>{statement.notation}</h3>
    //       {description}
    //     </div>
    //   )
    // })

    return (
      <div className={`${css.collapsible} ${css.finderResultStandards}`}>
        <h2 onClick={this.toggleCollapsible} className={css.collapsibleHeading}>Standards</h2>
        <div className={css.collapsibleBody}>
          {/* helpers.NGSS.getDiv() */}
          {/* unhelpedStandards */}
          <h3>NGSS Alignments</h3>
          <h4>Science and Engineering Practices:</h4>
          <ul className={css.practices}>
            <li>Developing and Using Models</li>
            <li>Constructing Explanations</li>
          </ul>
          <h4>Crosscutting Concepts:</h4>
          <ul className={css.crosscuttingConcepts}>
            <li>Patterns</li>
            <li>Cause and Effect: Mechanism and Explanation</li>
            <li>Systems and System Models</li>
          </ul>
          <h4>Disciplinary Core Ideas:</h4>
          <h5>ESS2.B: Plate Tectonics and Large-Scale System Interactions</h5>
          <ul className={css.coreIdeas}>
            <li>Maps of ancient land and water patterns, based on investigations of rocks and fossils, make clear how Earth’s plates have moved great distances, collided, and spread apart. (MS-ESS2-3)</li>
            <li>The radioactive decay of unstable isotopes continually generates new energy within Earth’s crust and mantle, providing the primary source of the heat that drives mantle convection. Plate tectonics can be viewed as the surface expression of mantle convection. (HS-ESS2-3)</li>
            <li>Plate tectonics is the unifying theory that explains the past and current movements of the rocks at Earth’s surface and provides a framework for understanding its geologic history. (ESS2.B Grade 8 GBE) (secondary to HS-ESS1-5),(HS-ESS2-1)</li>
            <li>Plate movements are responsible for most continental and ocean-floor features and for the distribution of most rocks and minerals within Earth’s crust. (ESS2.B Grade 8 GBE) (HS-ESS2-1)</li>
          </ul>
          <h5>ESS1.C: The History of Planet Earth</h5>
          <ul className={css.coreIdeas}>
            <li>Continental rocks, which can be older than 4 billion years, are generally much older than the rocks of the ocean floor, which are less than 200 million years old. (HS-ESS1-5)</li>
            <li>Tectonic processes continually generate new ocean sea floor at ridges and destroy old sea floor at trenches. (HS.ESS1.C GBE),(secondary to MS-ESS2-3)</li>
          </ul>
        </div>
      </div>
    )
  },

  renderRelatedResources: function (e) {
    const resource = this.props.resource
    if (resource.related_materials.length === 0) {
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
    const resource = this.props.resource
    // console.log(resource)
    const finderResultClasses = this.state.isOpen ? `${css.finderResult} ${css.open}` : css.finderResult
    // truncate title and/or description if they are too long for resource card height
    // const maxCharTitle = 180
    const maxCharDesc = 135
    const resourceName = resource.name
    const shortDesc = this.state.isOpen ? resource.filteredShortDescription : portalObjectHelpers.shortenText(resource.filteredShortDescription, maxCharDesc, true)
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
          <div className={css.finderResultTextDescription}>
            {shortDesc}
          </div>
          <div className={css.metaTags}>
            <GradeLevels resource={resource} />
            {this.renderTimeRequired()}
          </div>
        </div>
        <div className={css.previewLink}>
          <a className={css.previewLinkButton} href={resource.links.preview.url} target='_blank'>{resource.links.preview.text}</a>
          <div className={`${css.projectLabel} ${css[projectClass]}`}>
            {projectName}
          </div>
        </div>
        {this.renderStandards()}
        {this.renderRelatedResources()}
        {this.renderLinks()}
        {this.renderFavoriteStar()}
      </div>
    )
  }
})

export default stemFinderResult
