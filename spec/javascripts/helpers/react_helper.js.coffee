#= require react

# helper methods
window.renderStatic = (reactClass, props={} ) ->
  React.renderToStaticMarkup ((React.createFactory reactClass) props)

# shortcuts for add-on test utilities (the add-ons are enabled in /config/environments/test.rb)
window.Simulate = React.addons.TestUtils.Simulate
window.renderIntoDocument = React.addons.TestUtils.renderIntoDocument
window.mockComponent = React.addons.TestUtils.mockComponent
window.isElement = React.addons.TestUtils.isElement
window.isElementOfType= React.addons.TestUtils.isElementOfType
window.isDOMComponent= React.addons.TestUtils.isDOMComponent
window.isCompositeComponent = React.addons.TestUtils.isCompositeComponent
window.isCompositeComponentWithType= React.addons.TestUtils.isCompositeComponentWithType
window.findAllInRenderedTree= React.addons.TestUtils.findAllInRenderedTree
window.scryRenderedDOMComponentsWithClass = React.addons.TestUtils.scryRenderedDOMComponentsWithClass
window.findRenderedDOMComponentWithClass= React.addons.TestUtils.findRenderedDOMComponentWithClass
window.scryRenderedDOMComponentsWithTag= React.addons.TestUtils.scryRenderedDOMComponentsWithTag
window.findRenderedDOMComponentWithTag= React.addons.TestUtils.findRenderedDOMComponentWithTag
window.scryRenderedComponentsWithType = React.addons.TestUtils.scryRenderedComponentsWithType
window.findRenderedComponentWithType = React.addons.TestUtils.findRenderedComponentWithType
window.createRenderer = React.addons.TestUtils.createRenderer
