import React from 'react'
import Component from '../helpers/component'

const ResourceRequirements = Component({
  render: function () {
    const materialProperties = this.props.materialProperties
    const sensors = this.props.sensors
    const requirementsOutput = materialProperties.indexOf('Requires download') > -1
      ? <p>This resource requires Java. You can download Java for free from <a href='http://java.com/' title='Get Java'>java.com</a>.<br /><br />Using macOS 10.9 or newer? You&apos;ll also need to install our launcher app. <a href='http://static.concord.org/installers/cc_launcher_installer.dmg' title='Download the CCLauncher installer'>Download the launcher installer</a>, open the .dmg file, and drag the CCLauncher app to your Applications folder. Then return to this page and launch the resource.</p>
      : <p>This activity runs entirely in a Web browser. Preferred browsers are: <a href='http://www.google.com/chrome/' title="Get Google\'s Chrome Web Browser">Google Chrome</a> (versions 30 and above) <a href='http://www.apple.com/safari/' title="Get Apple\'s Safari Web Browser">Safari</a> (versions 7 and above), <a href='http://www.firefox.com/' title='Get the Firefox Web Browser'>Firefox</a> (version 30 and above), <a href='http://www.microsoft.com/ie/' title="Get Microsoft\'s Internet Explorer Web Browser">Internet Explorer</a> (version 10 or higher), and <a href='https://www.microsoft.com/en-us/windows/microsoft-edge#f7x5cdShtkSvrROV.97' title="Get Microsoft\'s Edge Web Browser">Microsoft Edge</a>.</p>
    let requirementsSensors = ''

    if (sensors !== undefined && sensors.length > 0) {
      let sensorTypes = ''
      let sensorTerm = 'sensor'

      if (sensors.length === 1) {
        sensorTypes = 'a ' + sensors[0].toLowerCase()
      } else {
        sensorTerm = 'sensors'
        for (let i = 0; i < sensors.length; i++) {
          if (i !== sensors.length - 1) {
            sensorTypes += sensors[i].toLowerCase() + ', '
          } else {
            if (sensors.length === 2) {
              sensorTypes = sensorTypes.replace(/, $/, '') // prevents things like "motion, and temperature sensors"
            }
            sensorTypes += ' and ' + sensors[i].toLowerCase()
          }
        }
      }

      requirementsSensors = <p>This resource requires the use of {sensorTypes} {sensorTerm}. You will also need the Concord Consortium's SensorConnector software installed. Learn more about supported sensors and download the SensorConnector from <a href='https://sensorconnector.concord.org/' target='_blank'>sensorconnector.concord.org</a>.</p>
    }
    return (
      <div className='portal-pages-resource-lightbox-requirements'>
        <h2>Requirements</h2>
        {requirementsOutput}
        {requirementsSensors}
      </div>
    )
  }
})

export default ResourceRequirements
