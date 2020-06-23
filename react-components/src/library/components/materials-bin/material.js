import React from 'react'

export default class MBMaterial extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      descriptionVisible: false,
      assigned: props.material.assigned
    }
    this.assignToSpecificClass = this.assignToSpecificClass.bind(this)
    this.toggleDescription = this.toggleDescription.bind(this)
    this.assignToClass = this.assignToClass.bind(this)
    this.assignToCollection = this.assignToCollection.bind(this)
    this.archive = this.archive.bind(this)
  }

  assignToSpecificClass (e) {
    Portal.assignMaterialToSpecificClass(e.target.checked, this.props.assignToSpecificClass, this.props.material.id, this.props.material.class_name)
    this.setState({ assigned: e.target.checked })
  }

  toggleDescription (e) {
    this.setState({ descriptionVisible: !this.state.descriptionVisible })
    e.preventDefault()
  }

  assignToClass (e) {
    Portal.assignMaterialToClass(this.props.material.id, this.props.material.class_name)
    e.preventDefault()
  }

  assignToCollection (e) {
    Portal.assignMaterialToCollection(this.props.material.id, this.props.material.class_name)
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
        <span className='mb-material-links'>
          {this.props.assignToSpecificClass
            ? <input type='checkbox' onChange={this.assignToSpecificClass} checked={this.state.assigned} /> : undefined}
          {data.edit_url != null
            ? <a className='mb-edit' href={data.edit_url} title='Edit this activity'>
              <span className='mb-edit-text'>Edit</span>
            </a> : undefined}
          {data.copy_url != null
            ? <a className='mb-copy' href={data.copy_url} title='Make your own version of this activity'>
              <span className='mb-copy-text'>Copy</span>
            </a> : undefined}
          {this.hasShortDescription()
            ? <a className='mb-toggle-info' href='' onClick={this.toggleDescription} title='View activity description'>
              <span className='mb-toggle-info-text'>Info</span>
            </a> : undefined}
          {data.preview_url != null
            ? <a className='mb-run' href={data.preview_url} title='Run this activity in the browser'>
              <span className='mb-run-text'>Run</span>
            </a> : undefined}
          {!this.props.assignToSpecificClass && (data.assign_to_class_url != null)
            ? <a className='mb-assign-to-class' href={data.assign_to_class_url} onClick={this.assignToClass} title='Assign this activity to a class'>
              <span className='mb-assign-to-class-text'>Assign or Share</span>
            </a> : undefined}
          {data.assign_to_collection_url != null
            ? <a className='mb-assign-to-collection' href={data.assign_to_collection_url} onClick={this.assignToCollection} title='Assign this activity to a collection'>
              <span className='mb-assign-to-collection-text'>Assign to collection</span>
            </a> : undefined}
        </span>
        <span className='mb-material-name'>{data.name}</span>
        {data.archive_url != null
          ? <a className='mb-archive-link' onClick={this.archive} title='archive this'>(archive this)</a>
          : undefined}
        {this.hasShortDescription()
          ? <MBMaterialDescription
            description={data.short_description}
            visible={this.state.descriptionVisible}
          /> : undefined}
      </div>
    )
  }
}

// Helper components:

class MBMaterialDescription extends React.Component {
  getVisibilityClass () {
    if (!this.props.visible) {
      return 'mb-hidden'
    } else {
      return ''
    }
  }

  render () {
    return (
      <div
        className={`mb-material-description ${this.getVisibilityClass()}`}
        dangerouslySetInnerHTML={{ __html: this.props.description }} />
    )
  }
}
