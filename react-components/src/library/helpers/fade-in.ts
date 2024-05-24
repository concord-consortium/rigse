var fadeIn = function (component) {
  var fadeInDuration = component.props.fadeIn || 0
  if (isNaN(fadeInDuration) || !fadeInDuration) {
    component.setState({ opacity: 1 })
    return
  }

  var interval = 10
  var increment = interval / fadeInDuration
  var animateOpacity = function () {
    var opacity = Math.min(component.state.opacity + increment, 1)
    component.setState({ opacity: opacity })
    if (opacity === 1) {
      window.clearInterval(animation)
    }
  }
  var animation = window.setInterval(animateOpacity, interval)
}

export default fadeIn
