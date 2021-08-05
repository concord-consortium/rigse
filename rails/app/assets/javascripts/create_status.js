class CreateStatus {
  constructor(parentElem, registerListener) {
    this.parentElem = parentElem;
    if (registerListener == null) { registerListener = true; }
    this.link_elm          = this.parentElem.down('input');
    this.create_status_elm = this.parentElem.down('.create_in_progress');

    if (this.link_elm && this.create_status_elm && registerListener) {
      this.link_elm.observe("click", evt => {
        this.hideButton();
      });
    }
  }

  hideButton() {
    this.link_elm.hide();
    this.create_status_elm.show();
  }

  showButton() {
    this.link_elm.show();
    this.create_status_elm.hide();
  }
}

window.CreateStatus = CreateStatus;

document.observe("dom:loaded", () => $$(".create_button").each(function(item) {
  new CreateStatus(item);
}));

