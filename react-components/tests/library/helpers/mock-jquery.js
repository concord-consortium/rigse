export const mockJqueryAjaxSuccess = (result) => {
  const realJQuery = global.jQuery;

  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      options.success(result)
    })
  });

  afterEach(() => {
    global.jQuery = realJQuery;
  })
}

export const mockJquery = (mock) => {
  const realJQuery = global.jQuery;

  global.jQuery = mock;

  beforeEach(() => {
    global.jQuery = mock;
  });

  afterEach(() => {
    global.jQuery = realJQuery;
  })
}

export const mockJqueryAjax = () => {
  const realJQueryAjax = global.jQuery.ajax;

  global.jQuery.ajax = jest.fn().mockImplementation(() => {
    const fakeResponse = {
        value: "anything you can imagine"
    };
  });

  afterEach(() => {
    global.jQuery.ajax = realJQueryAjax;
  })
}
