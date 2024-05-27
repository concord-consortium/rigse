import '@testing-library/jest-dom'
import jQuery from 'jquery'

window.jQuery = jQuery;
window.alert = jest.fn();
// mock google tag manager
window.gtag = jest.fn();
