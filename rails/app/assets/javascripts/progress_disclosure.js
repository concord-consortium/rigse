class ProgressDisclosure {
  constructor(disclosure_elem) {
    this.disclosure_elem = disclosure_elem;
    this.details_elms     = this.disclosure_elem.up('table').select('tr.details');
    this.showing_details = false;
    this.toggleDetailView();

    this.disclosure_elem.observe("click", evt => {
      evt.preventDefault();
      this.toggleDetailView();
    });
  }

  toggleDetailView() {
    if (this.showing_details) {
      this.showing_details = false;
      this.hideDetails();
      this.showClosedDisclosure();
    } else {
      this.showing_details = true;
      this.showDetails();
      this.showOpenedDisclosure();
    }
  }

  showOpenedDisclosure() {
    this.disclosure_elem.update('▶');
  }

  showClosedDisclosure() {
    this.disclosure_elem.update('▼');
  }

  showDetails() {
    this.details_elms.each(elm => elm.hide());
  }

  hideDetails() {
    this.details_elms.each(elm => elm.show());
  }
}

document.observe("dom:loaded", () => $$(".disclosure_widget").each(function(item) {
  new ProgressDisclosure(item);
}));