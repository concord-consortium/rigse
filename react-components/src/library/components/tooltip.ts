import Component from '../helpers/component'

const Tooltip = Component({
  getInitialState: function () {
    return {
      id: this.props.id,
      text: this.props.text,
      posx: this.props.posx,
      posy: this.props.posy,
      type: this.props.type || '',
      close_delay: this.props.close_delay || 3000
    }
  },

  getDefaultProps: function () {
    return {}
  },

  componentDidMount: function () {
    this.setTimer()
  },

  componentWillUnmount: function () {
    window.clearTimeout(this._timer)
  },

  setTimer: function () {
    if (this._timer != null) {
      window.clearTimeout(this._timer)
    }

    this._timer = window.setTimeout(function () {
      jQuery('#' + this.state.id).fadeOut()
      this._timer = null
    }.bind(this), this.state.close_delay)
  },

  handleClose: function (e) {
    this.props.toggleTooltip(e)
  },

  render: function (e) {
    return (
      <div className='portal-pages-tooltip-wrapper' onClick={this.handleClose}>
        <div className={'portal-pages-tooltip ' + this.state.type} id={this.state.id} style={{ left: this.state.posx, top: this.state.posy }} onClick={this.handleClose}>
          <p>{this.state.text}</p>
        </div>
      </div>
    )
  }
})

export default Tooltip
