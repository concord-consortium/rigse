import { render, unmount } from "./react-render";

const Tooltip = {
  mountPointId: "portal-pages-tooltip-mount",

  open (component: any) {
    let mountPoint = document.getElementById(this.mountPointId);

    if (!mountPoint) {
      mountPoint = document.createElement("DIV");
      mountPoint.id = this.mountPointId;
      document.body.appendChild(mountPoint);
    }
    render(component, mountPoint);
  },

  close () {
    const mountPoint = document.getElementById(this.mountPointId);

    unmount(mountPoint);
  }

};

export default Tooltip;
