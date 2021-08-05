import ReactDOM from 'react-dom'
/*
This is just a small reusable bit of code for mounting and unmounting a react component
in a new part of the document. The actual lightbox functionality is in resource-lightbox.

WARNING: Currently when the portal renders a URL for a lightbox resource it does not use
this object. The portal creates its own dom element and calls ReactDOM.render itself.
So any functionality you add to this object will probably need to be copied there too.
Code in ResourceLightbox is called in either case so it is better place to put things.
*/
const Lightbox = {
  mountPointId: 'portal-pages-lightbox-mount',

  open: function (component) {
    let mountPoint = document.getElementById(this.mountPointId)

    if (!mountPoint) {
      mountPoint = document.createElement('DIV')
      mountPoint.id = this.mountPointId
      document.body.appendChild(mountPoint)
    }
    ReactDOM.render(component, mountPoint)
  },

  close: function () {
    const mountPoint = document.getElementById(this.mountPointId)

    ReactDOM.unmountComponentAtNode(mountPoint)
  }

}

export default Lightbox
