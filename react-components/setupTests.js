import '@testing-library/jest-dom'
import jQuery from 'jquery'

global.jQuery = jQuery;
global.alert = jest.fn();
// mock google tag manager
global.gtag = jest.fn();
