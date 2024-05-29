import React from "react";
import Component from "../helpers/component";

const Tooltip = Component({
  getInitialState () {
    return {
      id: this.props.id,
      text: this.props.text,
      posx: this.props.posx,
      posy: this.props.posy,
      type: this.props.type || "",
      close_delay: this.props.close_delay || 3000
    };
  },

  getDefaultProps () {
    return {};
  },

  componentDidMount () {
    this.setTimer();
  },

  componentWillUnmount () {
    window.clearTimeout(this._timer);
  },

  setTimer () {
    if (this._timer != null) {
      window.clearTimeout(this._timer);
    }

    this._timer = window.setTimeout(function () {
      jQuery("#" + this.state.id).fadeOut();
      this._timer = null;
    }.bind(this), this.state.close_delay);
  },

  handleClose (e: any) {
    this.props.toggleTooltip(e);
  },

  render (e: any) {
    return (
      <div className="portal-pages-tooltip-wrapper" onClick={this.handleClose}>
        <div className={"portal-pages-tooltip " + this.state.type} id={this.state.id} style={{ left: this.state.posx, top: this.state.posy }} onClick={this.handleClose}>
          <p>{ this.state.text }</p>
        </div>
      </div>
    );
  }
});

export default Tooltip;
