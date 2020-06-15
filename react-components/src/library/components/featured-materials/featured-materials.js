import React from 'react'

// TODO: removed this when real SMaterialsList is converted
class SMaterialsList extends React.Component {
  render () {
    return <div>{this.props.materials}</div>
  }
}

export default class FeaturedMaterials extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      materials: []
    }
    this.mounted = false
  }

  componentDidMount () {
    this.mounted = true
    jQuery.ajax({
      url: Portal.API_V1.MATERIALS_FEATURED,
      data: this.props.queryString,
      dataType: 'json',
      success: data => {
        if (this.mounted) {
          this.setState({ materials: data })
        }
      }
    })
  }

  componentWillUnmount () {
    this.mounted = false
  }

  render () {
    return <SMaterialsList materials={this.state.materials} />
  }
}
