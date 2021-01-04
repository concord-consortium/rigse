import ReactDOM from 'react-dom'

var Tooltip = {
  mountPointId: 'portal-pages-tooltip-mount',

  open: function (component) {
    var mountPoint = document.getElementById(this.mountPointId)

    if (!mountPoint) {
      mountPoint = document.createElement('DIV')
      mountPoint.id = this.mountPointId
      document.body.appendChild(mountPoint)
    }
    ReactDOM.render(component, mountPoint)
  },

  close: function () {
    var mountPoint = document.getElementById(this.mountPointId)

    ReactDOM.unmountComponentAtNode(mountPoint)
  }

}

export default Tooltip
