const fadeIn = function (component: any) {
  const fadeInDuration = component.props.fadeIn || 0;
  if (isNaN(fadeInDuration) || !fadeInDuration) {
    component.setState({ opacity: 1 });
    return;
  }

  const interval = 10;
  const increment = interval / fadeInDuration;
  const animateOpacity = function () {
    const opacity = Math.min(component.state.opacity + increment, 1);
    component.setState({ opacity });
    if (opacity === 1) {
      window.clearInterval(animation);
    }
  };
  const animation = window.setInterval(animateOpacity, interval);
};

export default fadeIn;
