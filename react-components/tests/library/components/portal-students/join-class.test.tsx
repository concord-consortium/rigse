import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import "@testing-library/jest-dom";
import JoinClass from "../../../../src/library/components/portal-students/join-class";
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

describe("When I try to render join class", () => {
  it("should render enter classword by default", () => {
    render(<JoinClass />);
    expect(screen.getByText("Class Word")).toBeInTheDocument();
    expect(screen.getByLabelText("New Class Word:")).toBeInTheDocument();
    expect(screen.getByText("Not case sensitive")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Submit" })).toBeInTheDocument();
    expect(screen.getByText("A Class Word is created by a Teacher when he or she creates a new class. If you have been given the Class Word you can enter that word here to become a member of that class.")).toBeInTheDocument();
  });

  describe("with an invalid class word", () => {
    mockJqueryAjaxSuccess({
      success: false,
      message: "Invalid class word!"
    });

    it("should render an error message when checking the classword", async () => {
      render(<JoinClass />);
      fireEvent.change(screen.getByLabelText("New Class Word:"), { target: { value: "test" } });
      fireEvent.submit(screen.getByRole("button", { name: "Submit" }));

      expect(await screen.findByText("Invalid class word!")).toBeInTheDocument();
    });

    it("should render an error message when joining", async () => {
      const afterJoin = jest.fn();
      render(<JoinClass afterJoin={afterJoin} />);
      fireEvent.change(screen.getByLabelText("New Class Word:"), { target: { value: "test" } });
      fireEvent.submit(screen.getByRole("button", { name: "Submit" }));

      expect(await screen.findByText("Invalid class word!")).toBeInTheDocument();
      expect(afterJoin).not.toHaveBeenCalled();
    });
  });

  describe("with a valid class word", () => {
    mockJqueryAjaxSuccess({
      success: true,
      data: {
        teacher_name: "Teacher Teacherson"
      }
    });

    it("should render the join form after checking the classword", async () => {
      render(<JoinClass />);
      fireEvent.change(screen.getByLabelText("New Class Word:"), { target: { value: "test" } });
      fireEvent.submit(screen.getByRole("button", { name: "Submit" }));

      expect(await screen.findByText("The teacher of this class is Teacher Teacherson. Is this the class you want to join?")).toBeInTheDocument();
    });

    it("should handle the cancel button in the join form", async () => {
      const afterJoin = jest.fn();
      render(<JoinClass afterJoin={afterJoin} />);
      fireEvent.change(screen.getByLabelText("New Class Word:"), { target: { value: "test" } });
      fireEvent.submit(screen.getByRole("button", { name: "Submit" }));

      expect(await screen.findByText("The teacher of this class is Teacher Teacherson. Is this the class you want to join?")).toBeInTheDocument();
      expect(await screen.findByRole("button", { name: "Cancel" })).toBeInTheDocument();
    });

    it("should redirect after joining a class", async () => {
      const afterJoin = jest.fn();
      render(<JoinClass afterJoin={afterJoin} />);
      fireEvent.change(screen.getByLabelText("New Class Word:"), { target: { value: "test" } });
      fireEvent.submit(screen.getByRole("button", { name: "Submit" }));

      fireEvent.submit(await screen.findByRole("button", { name: "Join" }));

      expect(afterJoin).toHaveBeenCalled();
    });
  });
});
