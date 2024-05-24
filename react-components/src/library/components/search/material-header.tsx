import React from 'react'

import { SGenericLink } from './material-links'

export default class SMaterialHeader extends React.Component {
  renderMaterialProperties () {
    const reqDownload = this.props.material.material_properties.indexOf('Requires download') !== -1
    const className = reqDownload ? 'RequiresDownload' : 'RunsInBrowser'
    return (
      <span className={className}>
        {reqDownload ? 'Requires download' : 'Runs in browser'}
      </span>
    )
  }

  render () {
    const { material } = this.props
    return (
      <span className='material_header'>
        <span className='material_meta_data'>
          {this.renderMaterialProperties()}
          {material.is_official
            ? <span className='is_official'>Official</span>
            : <span className='is_community'>Community</span>}
          {material.publication_status !== 'published'
            ? <span className='publication_status'>{material.publication_status}</span>
            : undefined}
        </span>
        <br />
        {material.links.browse != null
          ? <a href={material.links.browse.url}>{material.name}</a>
          : material.name}
        {material.links.edit != null
          ? <span className='superTiny'><SGenericLink link={material.links.edit} /></span>
          : undefined}
        {material.links.external_edit_iframe != null && !material.lara_activity_or_sequence
          ? <span className='superTiny'><SGenericLink link={material.links.external_edit_iframe} /></span>
          : undefined}
      </span>
    )
  }
}
