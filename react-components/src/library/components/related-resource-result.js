import GradeLevels from './grade-levels'
import Component from '../helpers/component'
import portalObjectHelpers from '../helpers/portal-object-helpers'

import css from './related-resource-result.scss'

const RelatedResourceResult = Component({
  UNSAFE_componentWillMount: function () {
    // process the related resource
    var resource = this.props.resource
    portalObjectHelpers.processResource(resource)
  },

  handleClick: function (e) {
    e.preventDefault()
    e.stopPropagation()
    this.props.replaceResource(this.props.resource)
    gtag('event', 'click', {
      'category': 'Related Resource Card',
      'resource': this.props.resource.name,
    });
  },

  render: function () {
    var resource = this.props.resource

    return (
      <div className={css.finderRelatedResult}>
        <div className={css.finderRelatedResultImagePreview}>
          <img alt={resource.name} src={resource.icon.url} />
          <GradeLevels resource={resource} />
        </div>
        <div className={css.finderRelatedResultText}>
          <div className={css.finderRelatedResultTextName}><a href={resource.links.browse.url} target='_blank'>{resource.name}</a></div>
          <div className={css.finderRelatedResultTextDescription}>{resource.filteredShortDescription}</div>
        </div>
      </div>
    )
  }
})

export default RelatedResourceResult
