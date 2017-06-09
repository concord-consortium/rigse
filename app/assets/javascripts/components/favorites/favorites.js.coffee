{div, span, br} = React.DOM

window.FavoritesListClass = React.createClass

  displayName: "FavoritesListClass"

  render: ->

    #
    # Configuration passed to SMaterialIcon
    #
    configuration = {
        enableFavorites:    true,
        favoriteClassMap:   {
            true:   "stem-finder-result-favorite-active",
            false:  "stem-finder-result-favorite"
        },
        width:              "300px",
        height:             "250px"
    }

    (div { style: { display: "flex", \
                    flexFlow: "row wrap"} }, 

      for item in @props.items
        (div {  style: {    width: "300px",     \
                            flex: "1 1 45%",    \
                            display: "table" }, \
                key: "div-#{item.class_name}#{item.id}" }, 

            (SMaterialIcon {    material: item, \
                                key: "#{item.class_name}#{item.id}", \
                                configuration: configuration } )

            (span {}, (br {}))
            (span { style: { paddingLeft: "30px" } }, "#{item.name}")
            (span {}, 
                (br {})
                (br {})
            )
        )
    )


window.FavoritesList = React.createFactory FavoritesListClass

Portal.renderFavorites = (array, dest) ->
  ReactDOM.render FavoritesList(items: array), jQuery(dest)[0]
