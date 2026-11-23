import { serverMessage, withServerMessage } from "../../../src/library/helpers/request-error-message";

describe("serverMessage", () => {
  it("adds a period to a message with no end punctuation", () => {
    expect(serverMessage({ message: "Not authorized" })).toBe("Not authorized.");
  });

  it("keeps a message that already ends with punctuation", () => {
    expect(serverMessage({ message: "Not authorized!" })).toBe("Not authorized!");
  });

  it("puts the learner mode hint after a blank line", () => {
    expect(serverMessage({ message: "Not authorized", learner_mode_hint: "Reload the page." }))
      .toBe("Not authorized.\n\nReload the page.");
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
    expect(withServerMessage("Unable to save!", jqXHR)).toBe("Unable to save!\nNot authorized.\n\nReload the page.");
  });

  it("returns only the page's text when the response is not JSON", () => {
    expect(withServerMessage("Unable to save!", { responseText: "<html></html>" })).toBe("Unable to save!");
  });
});
