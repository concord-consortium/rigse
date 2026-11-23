// The alert text: the page's own text, then the message on a new line when there is one.
export const withMessage = (text: string, message?: string) => message ? `${text}\n${message}` : text;

const nonEmptyString = (value: any) => typeof value === "string" && value ? value : undefined;

// The server's message from a parsed JSON error response, with a period added if it has no end
// punctuation, or undefined if there is none. After a learner mode switch in another tab, the
// response can also have a learner_mode_hint. It goes after a blank line.
export const serverMessage = (body: any): string | undefined => {
  let message = nonEmptyString(body?.message);
  const hint = nonEmptyString(body?.learner_mode_hint);
  if (message && !/[.!?]$/.test(message)) {
    message = `${message}.`;
  }
  return message && hint ? `${message}\n\n${hint}` : message || hint;
};

// The alert text for a failed jQuery request: the page's own text, then the server's message on
// a new line when the response has one.
export const withServerMessage = (text: string, jqXHR: any) => {
  let body;
  try {
    body = JSON.parse(jqXHR?.responseText);
  } catch (e) {
    // The response is not JSON, for example a server error page.
  }
  return withMessage(text, serverMessage(body));
};

// The alert stops the page from drawing. To show it only after an undone change is off the
// screen, call this from the setState callback of that change. React runs the callback after it
// applies the change, and this then waits for the browser to draw it.
export const alertAfterRender = (text: string) => {
  requestAnimationFrame(() => setTimeout(() => window.alert(text)));
};
