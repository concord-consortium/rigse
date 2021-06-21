import GradeLevels from './grade-levels'
import Component from '../helpers/component'
import portalObjectHelpers from '../helpers/portal-object-helpers'

const RelatedResourceResult = Component({
  getInitialState: function () {
    return {
      hovering: false
    }
  },

  UNSAFE_componentWillMount: function () {
    // process the related resource
    var resource = this.props.resource
    portalObjectHelpers.processResource(resource)
  },

  handleClick: function (e) {
    e.preventDefault()
    e.stopPropagation()
    this.props.replaceResource(this.props.resource)
    ga('send', 'event', 'Related Resource Card', 'Click', this.props.resource.name)
  },

  handleMouseOver: function () {
    if (!('ontouchstart' in document.documentElement)) {
      this.setState({ hovering: true })
    }
  },

  handleMouseOut: function () {
    this.setState({ hovering: false })
  },

  render: function () {
    var resource = this.props.resource
    var options = { className: 'portal-pages-finder-result col-6', onClick: this.handleClick, onMouseOver: this.handleMouseOver, onMouseOut: this.handleMouseOut }

    if (this.state.hovering) {
      return (
        <div {...options}>
          <div className='portal-pages-finder-result-description'>{resource.filteredShortDescription}</div>
          <GradeLevels resource={resource} />
        </div>
      )
    }

    return (
      <div {...options}>
        <div className='portal-pages-finder-result-image-preview'>
          <img alt={resource.name} src={resource.icon.url} />
        </div>
        <div className='portal-pages-finder-result-name'>{resource.name}</div>
        <GradeLevels resource={resource} />
      </div>
    )
  }
})

export default RelatedResourceResult
