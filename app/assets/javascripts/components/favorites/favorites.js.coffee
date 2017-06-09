{div, br} = React.DOM

window.FavoritesListClass = React.createClass

  displayName: "FavoritesListClass"

  render: ->

    configuration = {
        enableFavorites:    true,
        favoriteClassMap:   {
            true:   "stem-finder-result-favorite-active",
            false:  "stem-finder-result-favorite"
        }
    }

    (div {}, 
      for item in @props.items
        (SMaterialIcon {    material: item, \
                            key: "#{item.class_name}#{item.id}", \
                            configuration: configuration } ) 
    )


window.FavoritesList = React.createFactory FavoritesListClass

Portal.renderFavorites = (array, dest) ->
  ReactDOM.render FavoritesList(items: array), jQuery(dest)[0]
