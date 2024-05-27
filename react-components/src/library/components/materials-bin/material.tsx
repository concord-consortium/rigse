import React from 'react'

export default class MBMaterial extends React.Component<any, any> {
  constructor (props: any) {
    super(props)
    this.state = {
      descriptionVisible: false,
      assigned: props.material.assigned
    }
    this.assignToSpecificClass = this.assignToSpecificClass.bind(this)
    this.toggleDescription = this.toggleDescription.bind(this)
    this.assignToClass = this.assignToClass.bind(this)
    this.archive = this.archive.bind(this)
  }

  assignToSpecificClass (e: any) {
        Portal.assignMaterialToSpecificClass(e.target.checked, this.props.assignToSpecificClass, this.props.material.id, this.props.material.class_name)
    this.setState({ assigned: e.target.checked })
  }

  toggleDescription (e: any) {
    this.setState({ descriptionVisible: !this.state.descriptionVisible })
    e.preventDefault()
  }

  assignToClass (e: any) {
    const isAssignWrapped = window.self !== window.top &&
      window.self.location.hostname === window.top?.location.hostname
    isAssignWrapped
      ? window.parent.Portal.assignMaterialToClass(this.props.material.id, this.props.material.class_name)
            : Portal.assignMaterialToClass(this.props.material.id, this.props.material.class_name)
    e.preventDefault()
  }

  hasShortDescription () {
    return (this.props.material.short_description != null) && (this.props.material.short_description !== '')
  }

  archive () {
        return Portal.confirm({
      message: `Archive '${this.props.material.name}'?`,
      callback: () => {
        return this.props.archive(this.props.material.id, this.props.material.archive_url)
      }
    })
  }

  render () {
    const data = this.props.material
    return (
      <div className='mb-material'>
        <div className='mb-material-thumbnail'>
          <img alt={data.name} src={data.icon.url} />
        </div>
        <div className='mb-material-text'>
          <h4 className='mb-material-name'>{data.name}</h4>
          {this.hasShortDescription() &&
            <div className='mb-material-description' dangerouslySetInnerHTML={{ __html: data.short_description }} />
          }
          <div className='mb-material-links'>
            {data.preview_url != null
              ? <a className='mb-edit' href={data.preview_url} title='Preview this activity' target='_blank' rel='noopener'>Preview</a>
              : undefined}
            {data.edit_url != null
              ? <a className='mb-edit' href={data.edit_url} title='Edit this activity' target='_blank' rel='noopener'>Edit</a>
              : undefined}
            {data.copy_url != null
              ? <a className='mb-copy' href={data.copy_url} title='Make your own version of this activity' target='_blank' rel='noopener'>Copy</a>
              : undefined}
            {!this.props.assignToSpecificClass && (data.assign_to_class_url != null)
              ? <a className='mb-assign-to-class' href={data.assign_to_class_url} onClick={this.assignToClass} title='Assign this activity to a class'>Assign</a>
              : undefined}
            {data.assign_to_collection_url != null
              ? <a className='mb-assign-to-collection' href={data.assign_to_collection_url} title='Assign this activity to a collection' target='_blank' rel='noopener'>Assign to collection</a>
              : undefined}
            {data.archive_url != null
              ? <a className='mb-archive-link' onClick={this.archive} title='archive this'>(archive this)</a>
              : undefined}
          </div>
        </div>
      </div>
    )
  }
}
