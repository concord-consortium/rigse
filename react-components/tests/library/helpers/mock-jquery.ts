declare global {
  interface Window {
    jQuery: any;
  }
}

export const mockJqueryAjaxSuccess = (result: any) => {
  const realJQuery = window.jQuery;

  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      options.success(result);
    })
  });

  afterEach(() => {
    window.jQuery = realJQuery;
  });
};

export const mockJquery = (mock: any) => {
  const realJQuery = window.jQuery;

  window.jQuery = mock;

  beforeEach(() => {
    window.jQuery = mock;
  });

  afterEach(() => {
    window.jQuery = realJQuery;
  });
};

export const mockJqueryAjax = () => {
  const realJQueryAjax = window.jQuery.ajax;

  window.jQuery.ajax = jest.fn();

  afterEach(() => {
    window.jQuery.ajax = realJQueryAjax;
  });
};
