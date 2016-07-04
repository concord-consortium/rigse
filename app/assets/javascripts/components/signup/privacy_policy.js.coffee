{a, div} = React.DOM

modulejs.define 'components/signup/privacy_policy', [], () ->
  React.createClass
    render: ->
      (div {className: 'privacy-policy'},
        'By clicking Sign Up!, you agree to our '
        (a {href: 'https://concord.org/privacy-policy', target: '_blank'}, 'privacy policy.')
      )
