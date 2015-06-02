{div} = React.DOM

window.MBMaterialsCategoryClass = React.createClass
  hideForAnonymous: ->
    @props.loginRequired && Portal.currentUser.isAnonymous

  getVisibilityClass: ->
    if @hideForAnonymous() || !@props.visible then 'mb-hidden' else ''

  getSelectionClass: ->
    if @props.selected then 'mb-selected' else ''

  handleClick: ->
    @props.handleClick @props.column, @props.slug

  render: ->
    className = "mb-cell mb-category mb-clickable #{@props.customClass || ''} #{@getVisibilityClass()} #{@getSelectionClass()}"
    (div {className: className, onClick: @handleClick},
      @props.children
    )

window.MBMaterialsCategory = React.createFactory MBMaterialsCategoryClass
