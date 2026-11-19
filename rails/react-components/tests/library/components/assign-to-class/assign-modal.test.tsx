import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import AssignModal from "../../../../src/library/components/assign-to-class/assign-modal";
import { mockJquery } from "../../helpers/mock-jquery";

window.Portal = {
  API_V1: {
    ASSIGN_MATERIAL_TO_CLASS: "/assign_to_class",
  },
  currentUser: {
    isAnonymous: false,
  },
};

const learnerText = "You may have switched to learner mode in another tab.";
const classList = { assigned_classes: [], unassigned_classes: [{ id: 1, name: "Class 1" }] };

// Each request answers at once, with a success (done) or a failure (fail), like a jQuery promise.
type Answer = { ok: boolean, body: any };
let answers: Record<string, Answer>;
const fakeRequest = (url: string) => {
  const { ok, body } = answers[url];
  const request: any = {
    done: (callback: any) => { if (ok) callback(body); return request; },
    fail: (callback: any) => { if (!ok) callback(body); return request; },
  };
  return request;
};
const refusal = (message: string) => ({ ok: false, body: { responseText: JSON.stringify({ message }) } });

describe("When an assign request is refused in the pop-up", () => {
  mockJquery(Object.assign(() => ({ attr: () => "token" }), { post: jest.fn(fakeRequest) }));

  beforeEach(() => {
    answers = {
      "/assign_to_class": { ok: true, body: {} },
    };
  });

  const renderModal = () => render(
    <AssignModal material_id={1} material_type="ExternalActivity" classes={classList} closeFunc={jest.fn()} />
  );

  it("shows the server's message when assigning is refused", () => {
    answers["/assign_to_class"] = refusal(`You are not allowed to assign/remove ExternalActivity with id of 1 in class 1. ${learnerText}`);
    renderModal();

    fireEvent.click(screen.getByLabelText("Class 1"));
    fireEvent.click(screen.getByText("Save"));

    expect(screen.getByText(`There was an error: You are not allowed to assign/remove ExternalActivity with id of 1 in class 1. ${learnerText}`))
      .toBeInTheDocument();
  });

  it("adds a period to a server message that has none", () => {
    answers["/assign_to_class"] = refusal("You are not allowed to assign/remove ExternalActivity with id of 1 in class 1");
    renderModal();

    fireEvent.click(screen.getByLabelText("Class 1"));
    fireEvent.click(screen.getByText("Save"));

    expect(screen.getByText("There was an error: You are not allowed to assign/remove ExternalActivity with id of 1 in class 1."))
      .toBeInTheDocument();
  });

  it("shows a general message when the response is not JSON", () => {
    answers["/assign_to_class"] = { ok: false, body: { responseText: "<html>Server error</html>" } };
    renderModal();

    fireEvent.click(screen.getByLabelText("Class 1"));
    fireEvent.click(screen.getByText("Save"));

    expect(screen.getByText("There was an error. Please try again.")).toBeInTheDocument();
  });
});
