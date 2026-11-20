// The alert text: the page's own text, then the message on a new line when there is one.
export const withMessage = (text: string, message?: string) => message ? `${text}\n${message}` : text;

// The alert text for a failed jQuery request: the page's own text, then the server's message on
// a new line when the response has one.
export const withServerMessage = (text: string, jqXHR: any) => {
  let message;
  try {
    message = JSON.parse(jqXHR?.responseText).message;
  } catch (e) {
    // The response is not JSON, for example a server error page.
  }
  return withMessage(text, message);
};

// The alert stops the page from drawing, so call this after an undone change to show the alert
// only after the change is off the screen.
export const alertAfterRender = (text: string) => {
  requestAnimationFrame(() => setTimeout(() => window.alert(text)));
};
