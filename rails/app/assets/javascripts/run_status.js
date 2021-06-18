class RunStatus {
  constructor(buttonElem) {
    this.buttonElem = buttonElem;
    this.parse_offering_url(this.buttonElem.href);
    this.run_button_elm    = this.buttonElem.up('.run_buttons');
    this.run_status_elm    = this.run_button_elm.next('.run_in_progress');
    this.message_elm        = this.run_status_elm.down('.message');
    this.spinner_elm        = this.run_status_elm.down('.wait_image');
    this.showing_run_status = false;

    if (this.run_button_elm && this.run_status_elm) {
      this.buttonElem.observe("click", evt => {
        // evt.preventDefault()
        this.toggleRunStatusView();
        this.trigger_status_updates();
      });
    }
  }

  toggleRunStatusView() {
    if (this.showing_run_status) {
      this.showing_run_status = false;
      this.hide_run_status();
    } else {
      this.showing_run_status = true;
      this.show_run_status();
    }
  }

  show_run_status() {
    this.run_button_elm.hide();
    this.run_status_elm.show();
  }

  hide_run_status() {
    this.run_button_elm.show();
    this.run_status_elm.hide();
    if (this.interval_id) { clearInterval(this.interval_id); }
    this.interval_id = null;
  }

  parse_offering_url(url) {
    this.offering_id = url.match(/\/offerings\/\d+/)[0];
    if (this.offering_id) { this.offering_id = this.offering_id.match(/\d+/)[0]; }
  }

  update_status(msg) {
    this.message_elm.update(msg);
  }

  we_are_waiting() {
    this.message_elm.addClassName('waiting');
    this.message_elm.removeClassName('ready');
    this.spinner_elm.show();
  }

  we_are_ready() {
    this.message_elm.addClassName('ready');
    this.message_elm.removeClassName('waiting');
    this.spinner_elm.hide();
  }

  handle_error(msg) {
    this.message_elm.update(msg);
  }

  stop_status_updates() {
    this.update_status('completed');
    this.hide_run_status();
  }

  trigger_status_updates() {
    if (this.interval_id  !== null) {
      clearInterval(this.interval_id);
      this.interval_id = null;
    }
    this.we_are_waiting();
    const update_status = () => {
      new Ajax.Request('/portal/offerings/' + this.offering_id + '/launch_status.json', {
        method: 'get',
        onSuccess: transport => {
          const status_event = transport.responseJSON;
          if (!!status_event.event_details) {
            this.update_status(status_event.event_details);
          }
          if (!!status_event && (status_event.event_type === "activity_otml_requested")) {
            this.we_are_ready();
          }
          if (!!status_event && ((status_event.event_type === "no_session") || (status.event_type === "bundle_saved"))) {
            this.stop_status_updates();
          }
        },
        onFailure() {
          this.handle_error("launch status failure");
        }
      }
        );
    };
    this.update_status("Requesting activity launcher...");
    this.interval_id = setInterval(update_status,5000);
  }
}

document.observe("dom:loaded", () => $$("a.button.run.solo").each(function(item) {
  new RunStatus(item);
}));

// Expose RunStatus to global namespace as OfferingRunStatus.
window.OfferingRunStatus = RunStatus;

