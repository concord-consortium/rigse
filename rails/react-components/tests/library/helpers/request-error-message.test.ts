import { serverMessage, withServerMessage } from "../../../src/library/helpers/request-error-message";

describe("serverMessage", () => {
  it("returns the message", () => {
    expect(serverMessage({ message: "Not authorized" })).toBe("Not authorized");
  });

  it("puts the learner mode hint on a new line after the message", () => {
    expect(serverMessage({ message: "Not authorized", learner_mode_hint: "Reload the page." }))
      .toBe("Not authorized\nReload the page.");
  });

  it("returns undefined when there is no message", () => {
    expect(serverMessage({})).toBeUndefined();
    expect(serverMessage(undefined)).toBeUndefined();
    expect(serverMessage("error")).toBeUndefined();
  });
});

describe("withServerMessage", () => {
  it("adds the message and the hint from a JSON response", () => {
    const jqXHR = { responseText: JSON.stringify({ message: "Not authorized", learner_mode_hint: "Reload the page." }) };
    expect(withServerMessage("Unable to save!", jqXHR)).toBe("Unable to save!\nNot authorized\nReload the page.");
  });

  it("returns only the page's text when the response is not JSON", () => {
    expect(withServerMessage("Unable to save!", { responseText: "<html></html>" })).toBe("Unable to save!");
  });
});
