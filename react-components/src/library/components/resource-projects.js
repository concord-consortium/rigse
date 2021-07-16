import React from 'react'
import Component from '../helpers/component'
import pluralize from '../helpers/pluralize'

const ResourceProjects = Component({
  render: function () {
    const projects = this.props.projects
    const numProjects = projects.length
    if (numProjects === 0) {
      return null
    }

    const projectsList = projects.map(function (project, index) {
      return (
        <span>
          <strong>
            {project.landing_page_url ? <a href={project.landing_page_url}>{project.name}</a> : project.name}
          </strong>
          {index !== numProjects - 1 ? ' and ' : ''}
        </span>
      )
    })

    return (
      <div>
        <hr />
        <h2>Learn More</h2>
        <div className='portal-pages-resource-lightbox-learn-more'>
          This resource is part of the Concord Consortium&apos;s {projectsList} {pluralize(numProjects, ' project')}.
        </div>
      </div>
    )
  }
})

export default ResourceProjects
