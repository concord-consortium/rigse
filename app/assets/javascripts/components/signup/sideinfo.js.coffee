{div, li, p, ul} = React.DOM

modulejs.define 'components/signup/sideinfo', [], () ->
  React.createClass
    render: ->
      (div {},
        (div {className: 'side-info-header'}, 'Why sign up?')
        (p {}, 'It\'s free and you get access to several key features:')
        (ul {},
          (li {}, 'Create classes for your students and assign them activities')
          (li {}, 'Save student work')
          (li {}, 'Track student progress through activities')
        )
      )
