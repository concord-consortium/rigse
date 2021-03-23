import React from 'react'
import { MakeTeacherEditionLink } from '../helpers/make-teacher-edition-links'
import Component from '../helpers/component'
import ResourceLightbox from './resource-lightbox'
import shuffleArray from '../helpers/shuffle-array'
import portalObjectHelpers from '../helpers/portal-object-helpers'
import Lightbox from '../helpers/lightbox'
import ResourceType from './resource-type'

const MaterialsCollectionItem = Component({

  getInitialState: function () {
    return {
      hovering: false,
      lightbox: false
    }
  },

  UNSAFE_componentWillMount: function () {
    const item = this.props.item
    portalObjectHelpers.processResource(item)
  },

  handleMouseOver: function () {
    if (this.state.lightbox) {
      return
    }
    this.setState({ hovering: true })
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
    if (lightbox) {
      let resourceLightbox =
        ResourceLightbox({ resource: this.props.item, parentPage: window.location.pathname, toggleLightbox: this.toggleLightbox, showTeacherResourcesButton: this.props.showTeacherResourcesButton })
      Lightbox.open(resourceLightbox)
    } else {
      Lightbox.close()
    }
  },

  handleMoreClick: function (e) {
    const resource = this.state.resource
    ga('send', 'event', 'Resource Card More Button', 'Click', resource.name)
  },

  handleTeacherEditionClick: function (e) {
    const resource = this.state.resource
    ga('send', 'event', 'Resource Card Teacher Edition Button', 'Click', resource.name)
  },

  handleTeacherResourcesClick: function (e) {
    const resource = this.state.resource
    ga('send', 'event', 'Resource Card Teacher Resources Button', 'Click', resource.name)
  },

  handleAssignClick: function (e) {
    const resource = this.state.resource
    ga('send', 'event', 'Resource Card Assign to Class Button', 'Click', resource.name)
  },

  handleTeacherGuideClick: function (e) {
    const resource = this.state.resource
    ga('send', 'event', 'Resource Card Teacher Guide Link', 'Click', resource.name)
  },

  render: function () {
    const item = this.props.item
    const links = item.links
    const showTeacherResourcesButton = this.props.showTeacherResourcesButton
    const keywords = item.keywords ? item.keywords.replace(/[,|, ]|\r?\n/g, ' ') : ''

    return (
      <div className={'portal-pages-finder-materials-collection-item'} data-keywords={keywords}>
        <div className={'portal-pages-finder-materials-collection-item__image col-4'}>
          <a href={'#'} onClick={this.toggleLightbox}>
            <img src={item.icon.url} />
            {ResourceType({ resource: item })}
          </a>
        </div>
        <div className={'portal-pages-finder-materials-collection-item-info col-8'}>
          <h3 className={'portal-pages-finder-materials-collection-item__title'}>
            <a href={'#'} onClick={this.toggleLightbox}>
              {item.name}
            </a>
          </h3>
          <div className={'portal-pages-finder-materials-collection-item__description'} dangerouslySetInnerHTML={{ __html: item.longDescription }} />
          <div className={'portal-pages-finder-materials-collection-item__links'}>
            {links.preview ? <a className='portal-pages-primary-button' href={links.preview.url} target='_blank' onClick={this.handlePreviewClick}>Preview</a> : null}
            {Portal.currentUser.isTeacher && item.has_teacher_edition ? <a className='teacherEditionLink portal-pages-secondary-button' href={MakeTeacherEditionLink(item.external_url)} target='_blank' onClick={this.handleTeacherEditionClick}>Teacher Edition</a> : null}
            {links.teacher_resources && showTeacherResourcesButton ? <a className='teacherResourcesLink portal-pages-secondary-button' href={links.teacher_resources.url} target='_blank' onClick={this.handleTeacherResourcesClick}>{links.teacher_resources.text}</a> : null}
            {links.assign_material ? <a className='portal-pages-secondary-button' href={`javascript: ${links.assign_material.onclick}`} onClick={this.handleAssignClick}>{links.assign_material.text}</a> : null}
            <a className={'portal-pages-secondary-button'} href={'#'} onClick={this.toggleLightbox}>More...</a>
          </div>
        </div>
      </div>
    )
  }
})

const MaterialsCollection = Component({
  getInitialState: function () {
    return {
      materials: []
    }
  },

  getDefaultProps: function () {
    return {
      showTeacherResourcesButton: true
    }
  },

  UNSAFE_componentWillMount: function () {
    jQuery.ajax({
      url: Portal.API_V1.MATERIALS_BIN_COLLECTIONS,
      data: { id: this.props.collection,
        skip_lightbox_reloads: true
      },
      dataType: 'json',
      success: function (data) {
        let materials = data[0].materials
        if (this.props.randomize) {
          materials = shuffleArray(materials)
        }
        if (this.props.featured) {
          // props.featured is the ID of the material we
          // wish to insert at the start of the list
          let featuredID = this.props.featured
          let sortFeatured = function (a, b) {
            if (a.id === featuredID) return -1
            if (b.id === featuredID) return 1
            return 0
          }
          materials.sort(sortFeatured)
        }
        this.setState({ materials: materials })
        if (this.props.onDataLoad) {
          this.props.onDataLoad(materials)
        }
      }.bind(this)
    })
  },

  render: function () {
    const showTeacherResourcesButton = this.props.showTeacherResourcesButton

    if (this.state.materials.length === 0) {
      return null
    }

    return (
      <div className={'portal-pages-finder-materials-collection'}>
        {this.state.materials.map(function (material, i) {
          return MaterialsCollectionItem({ key: i, item: material, showTeacherResourcesButton: showTeacherResourcesButton })
        })}
      </div>
    )
  }
})

export default MaterialsCollection
