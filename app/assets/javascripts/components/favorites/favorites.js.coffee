{div, br} = React.DOM

window.FavoritesListClass = React.createClass

  displayName: "FavoritesListClass"

  render: ->
    (div {}, 
      for item in @props.items
        (SMaterialIcon {material: item}) 
    )


window.FavoritesList = React.createFactory FavoritesListClass

Portal.renderFavorites = (array, dest) ->
  ReactDOM.render FavoritesList(items: array), jQuery(dest)[0]
