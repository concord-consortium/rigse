import React from 'react'

export default class SMaterialIcon extends React.Component {
  constructor (props) {
    super(props)
    this.handleClick = this.handleClick.bind(this)
  }

  handleClick () {
    const { material } = this.props

    let apiUrl = null
    let params = {}

    if (!Portal.currentUser.isTeacher) {
      window.alert('You must be logged in as a teacher to favorite material.')
      return
    }

    if (material.is_favorite) {
      apiUrl = Portal.API_V1.MATERIALS_REMOVE_FAVORITE
      params = {
        favorite_id: material.favorite_id
      }
    } else {
      apiUrl = Portal.API_V1.MATERIALS_ADD_FAVORITE
      params = {
        id: material.id,
        material_type: material.class_name_underscored
      }
    }

    return jQuery.ajax({
      url: apiUrl,
      data: params,
      type: 'POST',
      dataType: 'json',
      success: data => {
        material.is_favorite = !material.is_favorite
        material.favorite_id = data.favorite_id
        this.setState({ material })
      },
      error: (jqXHR, textStatus, errorThrown) => {
        console.error('ERROR', jqXHR.responseText, jqXHR)
      }
    })
  }

  render () {
    let border, favClassMap, favDiv, outlineDiv
    const { material, configuration } = this.props
    const { icon } = material
    const starred = material.is_favorite

    let enableFavorites = false
    let favOutlineClass = ''

    //
    // Get display configuration info.
    //
    if (configuration) {
      ({ enableFavorites } = configuration)
      favClassMap = configuration.favoriteClassMap
      favOutlineClass = configuration.favoriteOutlineClass
    } else {
      //
      // Set some defaults
      //
      favClassMap = {
        true: 'stem-finder-result-favorite-active',
        false: 'stem-finder-result-favorite'
      }
    }

    //
    // Set the icon image
    //
    if (icon.url === null) {
      border = '1px solid black'
    } else {
      border = '0px'
    }

    const containerStyle = { 'border': border }

    //
    // Check for caller overrides
    //
    for (let prop of ['width', 'height']) {
      if (configuration[prop]) {
        containerStyle[prop] = configuration[prop]
      }
    }

    //
    // Create the favorites div if enabled.
    //
    if (enableFavorites) {
      //
      // Set favorite info.
      //
      let outlineClass
      let favClass = favClassMap[false]
      const favStar = '\u2605'
      const outlineStar = '\u2606'
      if (starred) {
        favClass += ' ' + favClassMap[true]
      } else {
        outlineClass = favClass + ' ' + favOutlineClass
      }

      favDiv = <div className={favClass} onClick={this.handleClick} dangerouslySetInnerHTML={{ __html: favStar }} />
      if (!starred) {
        outlineDiv = <div className={outlineClass} style={{ color: '#CCCCCC' }} onClick={this.handleClick} dangerouslySetInnerHTML={{ __html: outlineStar }} />
      }
    }

    return (
      <div className='material_icon' style={containerStyle}>
        <a className='thumb_link' href={material.links.browse && material.links.browse.url}>
          <img src={icon.url} width='100%' />
        </a>
        {favDiv}
        {outlineDiv}
      </div>
    )
  }
}
