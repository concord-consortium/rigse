{div} = React.DOM

window.FavoritesListClass = React.createClass

  displayName: "FavoritesListClass"

  render: ->
    (div {}, "Hello Favorites!" )

window.FavoritesList = React.createFactory FavoritesListClass

Portal.renderFavorites = (results, dest) ->
  ReactDOM.render FavoritesList(results: results), jQuery(dest)[0]
