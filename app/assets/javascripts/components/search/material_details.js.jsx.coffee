MaterialDetails = React.createClass
  render: ->
    material = @props.material
    activities =  (material.activities || []).map (activity)->
      return if activity? then `<li key={activity.id}>{activity.name}</li>` else ''

    return `(
      <div className='toggle-details'>
        <i className='toggle-details-icon fa fa-chevron-down'></i>
        <i className='toggle-details-icon fa fa-chevron-up' style={{display: 'none'}}></i>
        <div className='material-details' style={{display: 'none'}}>
          <div className={ 'material-description ' + (material.has_activities || material.has_pretest) ? "two-cols" : "one-col"}>
            <h3>Description</h3>
            {material.description}
          </div>
          <div className='material-activities'>
            { material.has_pretest ? <h4>Pre- and Post-tests available.</h4> : "" }
            { activities.length > 0 ? <div><h3>Activities</h3><ul>{activities}</ul></div> : "" }
          </div>
        </div>
      </div>
    )`

window.MaterialDetails = MaterialDetails
