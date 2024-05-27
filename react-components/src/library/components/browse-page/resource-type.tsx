import React from 'react'
import Component from '../../helpers/component'

const ResourceType = Component({

  render: function () {
    const resource = this.props.resource
    const materialTypeLabels = {
      'Interactive': 'model',
      'Activity': 'activity',
      'Investigation': 'sequence',
      'Collection': 'collection'
    }
    // @ts-expect-error TS(7053): Element implicitly has an 'any' type because expre... Remove this comment to see the full error message
    const resourceType = materialTypeLabels[resource.material_type]

    if (resourceType === 'activity' || !resourceType) {
      return null
    }

    return (
      <div className={this.props.className || 'portal-pages-finder-result-resource-types'}>
        <div className={'portal-pages-finder-result-resource-type'}>
          {resourceType}
        </div>
      </div>
    )
  }
})

export default ResourceType
