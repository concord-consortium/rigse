/* globals describe it expect */
import React from "react";
import { render, screen } from "@testing-library/react";
import TeacherForm from "../../../../src/library/components/signup/teacher_form";
import { mockJquery } from "../../helpers/mock-jquery";

window.Portal = {
  enewsSubscriptionEnabled: true,
  API_V1: {
    LOGIN_VALID: "http://example.com/login_valid",
    EMAILS: "http://example.com/emails",
    COUNTRIES: "http://example.com/countries",
    TEACHERS: "http://example.com/teachers",
  }
};

const mockedJQuery = {
  get: () => ({
    done: () => [
      { id: 1, name: "United States" },
      { id: 2, name: "Mexico" }
    ]
  })
};

describe("When I try to render signup user type selector", () => {

  mockJquery(mockedJQuery);

  it("should render", () => {
    render(<TeacherForm />);

    expect(screen.getByText("Country")).toBeInTheDocument();
    expect(screen.getByText("Send me updates about educational technology resources.")).toBeInTheDocument();
    expect(screen.getByText("By clicking Register!, you agree to our")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Register!" })).toBeInTheDocument();
  });

  it("should render with anonymous prop", () => {
    render(<TeacherForm anonymous={true} />);

    expect(screen.getByText("Username")).toBeInTheDocument();
    expect(screen.getByText("Email")).toBeInTheDocument();
    expect(screen.getByText("Send me updates about educational technology resources.")).toBeInTheDocument();
    expect(screen.getByText("Country")).toBeInTheDocument();
    expect(screen.getByText("By clicking Register!, you agree to our")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Register!" })).toBeInTheDocument();
  });

});
