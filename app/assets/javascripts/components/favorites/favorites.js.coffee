{div, br} = React.DOM

window.FavoritesListClass = React.createClass

  displayName: "FavoritesListClass"

  render: ->
    (div {}, 
      for item in @props.items
        (SMaterialIcon {    material: item, \
                            key: "#{item.class_name}#{item.id}" } ) 
    )


window.FavoritesList = React.createFactory FavoritesListClass

Portal.renderFavorites = (array, dest) ->
  ReactDOM.render FavoritesList(items: array), jQuery(dest)[0]
