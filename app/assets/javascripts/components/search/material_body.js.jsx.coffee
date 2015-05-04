MaterialBody = React.createClass
  render: ->
    material = @props.material
    if material.sensors? and material.sensors.length > 0
      required_sensors = `<div id='required_equipment_container'>
        <span id='required_equipment'>Required sensor(s):</span>
        <span style={{fontWeight: 'bold'}}>{material.sensors.join(', ')}</span>
      </div>`
    else
      required_sensors = ''

    if material.class_count is 0
      material_usage_text = 'Not used in any class.'
    else if material.class_count == 1
      material_usage_text = 'Used in 1 class.'
    else
      material_usage_text =  'Used in ' + material.class_count + ' classes.'

    return `(
      <div className='material_body'>
        <div>
          <i>
            {material_usage_text}
          </i>
        </div>
        {required_sensors}
      </div>
    )`

window.MaterialBody = MaterialBody
