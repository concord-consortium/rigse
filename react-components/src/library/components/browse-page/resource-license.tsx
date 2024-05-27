import React from 'react'
import Component from '../../helpers/component'

const ResourceLicense = Component({

  render: function () {
    const resourceName = this.props.resourceName
    const license = this.props.license_info
    const credits = this.props.credits

    if (!license) {
      return null
    }

    let attributionName = 'The Concord Consortium'
    let attributionUrl = 'https://concord.org/'

    let licenseDescription = !credits
      ? license.description
      : license.description.replace('the Concord Consortium', credits)

    // alter attribution values when all material should be attributed to a specific project or partner
        if (Portal.theme === 'ngss-assessment') {
      attributionName = 'The Next Generation Science Assessment Project'
      attributionUrl = 'http://nextgenscienceassessment.org/'
      licenseDescription = license.description.replace('the Concord Consortium', attributionName)
    }

    const licenseAttribution = license.code === 'CC0'
      ? ''
      : !credits
        ? <p>Suggested attribution: {resourceName} by <a href={attributionUrl}>{attributionName}</a> is licensed under <a href={license.deed}>{license.code}</a>.</p>
        : <p>Suggested attribution: {resourceName} by {credits} is licensed under <a href={license.deed}>{license.code}</a>.</p>

    return (
      <div className='portal-pages-resource-lightbox-license'>
        <hr />
        <h2>License</h2>
        <div>
          {license.image !== '' && <img src={license.image} alt={license.code} />}
        </div>
        <h3>{license.code}</h3>
        <p>{license.name}</p>
        <p>{licenseDescription}</p>
        <p><a href={license.deed}>{license.code} (human-readable summary)</a><br />
          <a href={license.legal}>{license.code} (full license text)</a></p>
        {licenseAttribution}
      </div>
    )
  }
})

export default ResourceLicense
