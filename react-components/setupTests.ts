import "@testing-library/jest-dom";

declare global {
  interface Window {
    gtag: any;
  }
}

window.gtag = jest.fn(); // google tag manager
