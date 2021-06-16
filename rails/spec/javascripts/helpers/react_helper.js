//= require react-test-globals

// helper methods
window.renderStatic = function(reactClass, props ) {
  if (props == null) { props = {}; }
  ReactDOMServer.renderToStaticMarkup(((React.createFactory(reactClass))(props)));
};

// shortcuts for add-on test utilities (the add-ons are enabled in /config/environments/test.rb)
window.Simulate = ReactTestUtils.Simulate;
window.renderIntoDocument = ReactTestUtils.renderIntoDocument;
window.mockComponent = ReactTestUtils.mockComponent;
window.isElement = ReactTestUtils.isElement;
window.isElementOfType= ReactTestUtils.isElementOfType;
window.isDOMComponent= ReactTestUtils.isDOMComponent;
window.isCompositeComponent = ReactTestUtils.isCompositeComponent;
window.isCompositeComponentWithType= ReactTestUtils.isCompositeComponentWithType;
window.findAllInRenderedTree= ReactTestUtils.findAllInRenderedTree;
window.scryRenderedDOMComponentsWithClass = ReactTestUtils.scryRenderedDOMComponentsWithClass;
window.findRenderedDOMComponentWithClass= ReactTestUtils.findRenderedDOMComponentWithClass;
window.scryRenderedDOMComponentsWithTag= ReactTestUtils.scryRenderedDOMComponentsWithTag;
window.findRenderedDOMComponentWithTag= ReactTestUtils.findRenderedDOMComponentWithTag;
window.scryRenderedComponentsWithType = ReactTestUtils.scryRenderedComponentsWithType;
window.findRenderedComponentWithType = ReactTestUtils.findRenderedComponentWithType;
window.createRenderer = ReactTestUtils.createRenderer;
