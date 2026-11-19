import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import RunWithCollaborators from "../../../../src/library/components/run-with-collaborators";
import { mockJquery } from "../../helpers/mock-jquery";

window.Portal = {
  API_V1: { AVAILABLE_COLLABORATORS: "/available_collaborators", COLLABORATIONS: "/collaborations" },
};

const message = "Not authorized. You may have switched back to teacher in another tab.";
const refused = { responseText: JSON.stringify({ success: false, message }) };

let answers: Record<string, (options: any) => void>;

describe("When a Run with collaborators request is refused", () => {
  mockJquery({
    // Answer later, as a real request does.
    ajax: jest.fn().mockImplementation((options) => setTimeout(() => answers[options.url](options)))
  });

  beforeEach(() => {
    answers = {
      "/available_collaborators": (options) => options.success([{ id: 2, name: "Student 2" }]),
      "/collaborations": (options) => options.error(refused),
    };
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("shows the server's message and lets the user try again when Run is refused", async () => {
    const { container } = render(<RunWithCollaborators offeringId={1} label="Run with others" href="#" />);
    fireEvent.click(screen.getByText("Run with others"));
    await screen.findByText("Student 2");

    fireEvent.change(screen.getByRole("combobox"), { target: { value: "2" } });
    fireEvent.click(screen.getByText("Add"));
    fireEvent.click(screen.getByRole("button", { name: "Run with others" }));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Error creating collaboration\n${message}`));
    expect(container.querySelector(".fa-spinner")).toBeNull();
    expect(screen.getByRole("button", { name: "Run with others" })).toBeEnabled();
  });

  it("shows the server's message when loading the collaborators is refused", async () => {
    answers["/available_collaborators"] = (options) => options.error(refused);
    render(<RunWithCollaborators offeringId={1} label="Run with others" href="#" />);

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Error loading available collaborators\n${message}`));
  });
});
