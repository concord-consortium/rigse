{div, i, span} = React.DOM

window.SMaterialBodyClass = React.createClass
  renderMaterialUsage: ->
    classCount = @props.material.class_count
    if classCount?
      (div {},
        (i {},
          if classCount is 0
            'Not used in any class.'
          else if classCount == 1
            'Used in 1 class.'
          else
            'Used in ' + classCount + ' classes.'
        )
      )

  renderRequiredSensors: ->
    sensors = @props.material.sensors
    if sensors? and sensors.length > 0
      (div {className: 'required_equipment_container'},
        (span {}, 'Required sensor(s):')
        (span {style: {fontWeight: 'bold'}}, sensors.join(', '))
      )

  render: ->
    (div {className: 'material_body'},
      @renderMaterialUsage()
      @renderRequiredSensors()
    )

window.SMaterialBody = React.createFactory SMaterialBodyClass
