export const mockJqueryAjaxSuccess = (result: any) => {
  // @ts-expect-error TS(2304): Cannot find name 'global'.
  const realJQuery = global.jQuery;

  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      options.success(result)
    })
  });

  afterEach(() => {
    // @ts-expect-error TS(2304): Cannot find name 'global'.
    global.jQuery = realJQuery;
  })
}

export const mockJquery = (mock: any) => {
  // @ts-expect-error TS(2304): Cannot find name 'global'.
  const realJQuery = global.jQuery;

  // @ts-expect-error TS(2304): Cannot find name 'global'.
  global.jQuery = mock;

  beforeEach(() => {
    // @ts-expect-error TS(2304): Cannot find name 'global'.
    global.jQuery = mock;
  });

  afterEach(() => {
    // @ts-expect-error TS(2304): Cannot find name 'global'.
    global.jQuery = realJQuery;
  })
}

export const mockJqueryAjax = () => {
  // @ts-expect-error TS(2304): Cannot find name 'global'.
  const realJQueryAjax = global.jQuery.ajax;

  // @ts-expect-error TS(2304): Cannot find name 'global'.
  global.jQuery.ajax = jest.fn().mockImplementation(() => {
    const fakeResponse = {
        value: "anything you can imagine"
    };
  });

  afterEach(() => {
    // @ts-expect-error TS(2304): Cannot find name 'global'.
    global.jQuery.ajax = realJQueryAjax;
  })
}
