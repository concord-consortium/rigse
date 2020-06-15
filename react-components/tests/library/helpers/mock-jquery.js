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

  beforeEach(() => {
    global.jQuery = mock;
  });

  afterEach(() => {
    global.jQuery = realJQuery;
  })
}

