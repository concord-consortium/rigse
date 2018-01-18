// created from http://react-day-picker.js.org/examples/?overlay

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var overlayStyle = {
  position: 'absolute',
  background: 'white',
  boxShadow: '0 2px 5px rgba(0, 0, 0, .15)'
};

var DayPickerOverlay = function (_React$Component) {
  _inherits(DayPickerOverlay, _React$Component);

  function DayPickerOverlay() {
    var _ref;

    var _temp, _this, _ret;

    _classCallCheck(this, DayPickerOverlay);

    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    return _ret = (_temp = (_this = _possibleConstructorReturn(this, (_ref = DayPickerOverlay.__proto__ || Object.getPrototypeOf(DayPickerOverlay)).call.apply(_ref, [this].concat(args))), _this), _this.state = {
      showOverlay: false,
      selectedDay: null
    }, _this.input = null, _this.daypicker = null, _this.clickedInside = false, _this.clickTimeout = null, _this.handleContainerMouseDown = function () {
      _this.clickedInside = true;
      // The input's onBlur method is called from a queue right after onMouseDown event.
      // setTimeout adds another callback in the queue, but is called later than onBlur event
      _this.clickTimeout = setTimeout(function () {
        _this.clickedInside = false;
      }, 0);
    }, _this.handleInputFocus = function () {
      _this.setState({
        showOverlay: true
      });
    }, _this.handleInputBlur = function () {
      var showOverlay = _this.clickedInside;

      _this.setState({
        showOverlay: showOverlay
      });

      // Force input's focus if blur event was caused by clicking on the calendar
      if (showOverlay) {
        _this.input.focus();
      }
    }, _this.handleInputChange = function (e) {
      var value = e.target.value;

      var momentDay = moment(value, 'L', true);
      if (momentDay.isValid()) {
        _this.props.onChange(value);
        _this.setState({
          selectedDay: momentDay.toDate(),
        }, function () {
          _this.daypicker.showMonth(_this.state.selectedDay);
        });
      } else {
        _this.props.onChange(value);
        _this.setState({ selectedDay: null });
      }
    }, _this.handleDayClick = function (day) {
      _this.props.onChange(moment(day).format('L'));
      _this.setState({
        selectedDay: day,
        showOverlay: false
      });
      _this.input.blur();
    }, _temp), _possibleConstructorReturn(_this, _ret);
  }

  _createClass(DayPickerOverlay, [{
    key: 'componentWillUnmount',
    value: function componentWillUnmount() {
      clearTimeout(this.clickTimeout);
    }
  }, {
    key: 'render',
    value: function render() {
      var _this2 = this;

      return React.createElement(
        'div',
        { onMouseDown: this.handleContainerMouseDown },
        React.createElement('input', {
          type: 'text',
          name: this.props.name,
          ref: function ref(el) {
            _this2.input = el;
          },
          placeholder: 'DD/MM/YYYY',
          value: this.props.value,
          onChange: this.handleInputChange,
          onFocus: this.handleInputFocus,
          onBlur: this.handleInputBlur
        }),
        this.state.showOverlay && React.createElement(
          'div',
          { style: { position: 'relative' } },
          React.createElement(
            'div',
            { style: overlayStyle },
            React.createElement(DayPicker, {
              ref: function ref(el) {
                _this2.daypicker = el;
              },
              initialMonth: this.state.selectedDay || undefined,
              onDayClick: this.handleDayClick,
              selectedDays: this.state.selectedDay
            })
          )
        )
      );
    }
  }]);

  return DayPickerOverlay;
}(React.Component);
