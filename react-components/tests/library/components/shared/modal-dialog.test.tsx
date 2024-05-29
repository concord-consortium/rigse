
import React from "react";
import { render, screen } from "@testing-library/react";
import ModalDialog from "../../../../src/library/components/shared/modal-dialog";

describe("When I try to render a modal dialog", () => {

  it("should render without children", () => {
    render(<ModalDialog title="Test Dialog" />);

    const modalTitle = screen.getByText("Test Dialog");
    expect(modalTitle).toBeInTheDocument();

    const modal = screen.getByRole("dialog");
    expect(modal).toBeInTheDocument();

    const background = screen.getByTestId("modal-background");
    expect(background).toBeInTheDocument();
  });

  it("should render with children", () => {
    render(<ModalDialog title="Test Dialog"><div>children here...</div></ModalDialog>);

    const modalTitle = screen.getByText("Test Dialog");
    expect(modalTitle).toBeInTheDocument();

    const modal = screen.getByRole("dialog");
    expect(modal).toBeInTheDocument();

    const background = screen.getByTestId("modal-background");
    expect(background).toBeInTheDocument();

    const childrenContent = screen.getByText("children here...");
    expect(childrenContent).toBeInTheDocument();
  });
});
