import React from 'react'

import { SMaterialLinks } from './material-links'
import SMaterialHeader from './material-header'

export default class SMaterialInfo extends React.Component {
  renderLinks () {
    const { material } = this.props
    for (let key of Object.keys(material.links || {})) {
      const link = material.links[key]
      link.key = key
    }

    const links = []
    if (material.links.preview) {
      links.push(material.links.preview)
    }
    if (material.links.print_url) {
      links.push(material.links.print_url)
    }
    if (material.lara_activity_or_sequence) {
      if (material.links.external_lara_edit) {
        links.push(material.links.external_lara_edit)
      }
    } else {
      if (material.links.external_edit) {
        links.push(material.links.external_edit)
      }
    }
    if (material.links.external_copy) {
      links.push(material.links.external_copy)
    }
    if (material.links.teacher_guide) {
      links.push(material.links.teacher_guide)
    }
    if (material.material_type !== 'Collection') {
      if (material.links.assign_material) {
        links.push(material.links.assign_material)
      }
      if (material.links.assign_collection) {
        links.push(material.links.assign_collection)
      }
    }
    if (material.links.unarchive) {
      links.push(material.links.unarchive)
    }

    return <SMaterialLinks links={links} />
  }

  renderParentInfo () {
    const { material } = this.props
    if (material.parent) {
      return <span>{`from ${material.parent.type} "${material.parent.name}"`}</span>
    }
  }

  renderAuthorInfo () {
    const credits = (this.props.material.credits != null ? this.props.material.credits.length : undefined) > 0
      ? this.props.material.credits
      : (this.props.material.user != null ? this.props.material.user.name.length : undefined) > 0
        ? this.props.material.user.name
        : null
    if (credits) {
      return (
        <div>
          <span style={{ fontWeight: 'bold' }}>{`By ${credits}`}</span>
        </div>
      )
    }
  }

  renderClassInfo () {
    const assignedClasses = this.props.material.assigned_classes
    if ((assignedClasses != null) && (assignedClasses.length > 0)) {
      return <span className='assignedTo'>{`(Assigned to ${assignedClasses.join(', ')})`}</span>
    }
  }

  render () {
    return (
      <div>
        <div style={{ overflow: 'hidden' }}>
          <table width='100%'>
            <tbody>
              <tr>
                <td>{this.renderLinks()}</td>
              </tr>
              <tr>
                <td>
                  <SMaterialHeader material={this.props.material} />
                  {this.renderParentInfo()}
                  {this.renderAuthorInfo()}
                </td>
              </tr>
              <tr>
                <td>{this.renderClassInfo()}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    )
  }
}
