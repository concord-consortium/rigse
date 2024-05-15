import { render, unmount } from './react-render'

var Tooltip = {
  mountPointId: 'portal-pages-tooltip-mount',

  open: function (component) {
    var mountPoint = document.getElementById(this.mountPointId)

    if (!mountPoint) {
      mountPoint = document.createElement('DIV')
      mountPoint.id = this.mountPointId
      document.body.appendChild(mountPoint)
    }
    render(component, mountPoint)
  },

  close: function () {
    var mountPoint = document.getElementById(this.mountPointId)

    unmount(mountPoint)
  }

}

export default Tooltip
