import React from 'react'
import Component from '../../helpers/component'
import pluralize from '../../helpers/pluralize'

import css from './style.scss'

const ResourceProjects = Component({
  render: function () {
    const projects = this.props.projects
    const numProjects = projects.length
    if (numProjects === 0) {
      return null
    }

    const projectsList = projects.map(function (project, index) {
      return (
        <span key={project.landing_page_url}>
          <strong>
            {project.landing_page_url ? <a href={project.landing_page_url}>{project.name}</a> : project.name}
          </strong>
          {index !== numProjects - 1 ? ' and ' : ''}
        </span>
      )
    })

    return (
      <div class={css.resourceMetadataGroup}>
        <h2>Learn More</h2>
        <p>This resource is part of the Concord Consortium&apos;s {projectsList} {pluralize(numProjects, ' project')}.</p>
      </div>
    )
  }
})

export default ResourceProjects
