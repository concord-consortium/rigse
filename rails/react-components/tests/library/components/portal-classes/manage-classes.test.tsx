import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react";
import ManageClasses from "../../../../src/library/components/portal-classes/manage-classes";
import { mockJquery, mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

describe("When I try to render manage classes", () => {
  mockJqueryAjaxSuccess({
    success: true,
  });

  const classes = [
    {
      id: 1,
      name: "test class 1",
      classWord: "test_class_1",
      description: "this is a test class 1",
      is_archived: false,
    },
    {
      id: 2,
      name: "test class 2",
      classWord: "test_class_2",
      description: "this is a test class 2",
      is_archived: true,
    },
    {
      id: 3,
      name: "test class 3",
      classWord: "test_class_3",
      description: "this is a test class 3",
      is_archived: false,
    },
  ];

  it("should render", () => {
    render(<ManageClasses classes={classes} />);

    expect(screen.getByText("My Classes (3 Total, 2 Active)")).toBeInTheDocument();
    expect(screen.getByText("test class 1")).toBeInTheDocument();
    expect(screen.getByText("test class 2")).toBeInTheDocument();
    expect(screen.getByText("test class 3")).toBeInTheDocument();
    expect(screen.getAllByText("Archive")).toHaveLength(2);
    expect(screen.getByText("Unarchive")).toBeInTheDocument();
    expect(screen.getAllByText("Copy")).toHaveLength(3);
  });

  it("should handle toggling activation", async () => {
    render(<ManageClasses classes={classes} />);
    expect(screen.getAllByText("Unarchive")).toHaveLength(1);

    fireEvent.click(screen.getAllByText("Archive")[0]);
    await waitFor(() => expect(screen.getAllByText("Unarchive")).toHaveLength(2));

    fireEvent.click(screen.getAllByText("Unarchive")[0]);
    await waitFor(() => expect(screen.getAllByText("Unarchive")).toHaveLength(1));
  });

  it("should handle copying", () => {
    render(<ManageClasses classes={classes} />);
    const copyButton = screen.getAllByText("Copy")[0];

    expect(screen.queryByText("Copy Class")).not.toBeInTheDocument();
    fireEvent.click(copyButton);
    expect(screen.getByText("Copy Class")).toBeInTheDocument();
    expect(screen.getByDisplayValue("Copy of test class 1")).toBeInTheDocument();

    // NOTE: the copy dialog is tested in its own test file
  });
});

describe("When a Manage Classes request is refused", () => {
  const message = "Not authorized";
  const hint = "You may have switched to learner mode in another tab, so this page is out of date. Reload the page to continue.";
  const refusal = { success: false, message, learner_mode_hint: hint };
  let respond: (options: any) => void;

  mockJquery({
    ajax: jest.fn().mockImplementation((options) => respond(options))
  });

  const refuseWithError = () => {
    respond = (options) => options.error({ responseText: JSON.stringify(refusal) }, "error", "Forbidden");
  };

  const makeClasses = () => [
    { id: 1, name: "test class 1", classWord: "test_class_1", description: "", is_archived: false },
    { id: 2, name: "test class 2", classWord: "test_class_2", description: "", is_archived: false },
  ];

  beforeEach(() => {
    refuseWithError();
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("shows the server's message and does not change the class", async () => {
    let archiveButtonsDuringAlert: number | undefined;
    (window.alert as jest.Mock).mockImplementation(() => {
      archiveButtonsDuringAlert = screen.queryAllByText("Archive").length;
    });
    render(<ManageClasses classes={makeClasses()} />);

    fireEvent.click(screen.getAllByText("Archive")[0]);

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Unable to toggle archived state of the class!\n${message}.\n\n${hint}`);
    });
    expect(archiveButtonsDuringAlert).toBe(2);
    expect(screen.getAllByText("Archive")).toHaveLength(2);
  });

  it("shows the server's message when the response is not successful", async () => {
    respond = (options) => options.success(refusal);
    render(<ManageClasses classes={makeClasses()} />);

    fireEvent.click(screen.getAllByText("Archive")[0]);

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Unable to toggle archived state of the class!\n${message}.\n\n${hint}`);
    });
  });

  it("puts the old order back, then shows the server's message", async () => {
    let namesDuringAlert: (string | null)[] = [];
    (window.alert as jest.Mock).mockImplementation(() => {
      namesDuringAlert = screen.getAllByText(/^test class \d$/).map(el => el.textContent);
    });
    const ref = React.createRef<ManageClasses>();
    render(<ManageClasses ref={ref} classes={makeClasses()} />);

    act(() => ref.current?.handleSortEnd({ oldIndex: 0, newIndex: 1 }));

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Unable to save class sort order!\n${message}.\n\n${hint}`);
    });
    expect(namesDuringAlert).toEqual(["test class 1", "test class 2"]);
  });

  it("ignores a second drag while a sort waits for the server", async () => {
    const pending: any[] = [];
    respond = (options) => pending.push(options);
    const names = () => screen.getAllByText(/^test class \d$/).map(el => el.textContent);
    const ref = React.createRef<ManageClasses>();
    render(<ManageClasses ref={ref} classes={makeClasses()} />);

    act(() => ref.current?.handleSortEnd({ oldIndex: 0, newIndex: 1 }));
    act(() => ref.current?.handleSortEnd({ oldIndex: 0, newIndex: 1 }));

    expect(pending).toHaveLength(1);
    expect(names()).toEqual(["test class 2", "test class 1"]);

    act(() => pending[0].error({ responseText: JSON.stringify(refusal) }, "error", "Forbidden"));
    await waitFor(() => expect(names()).toEqual(["test class 1", "test class 2"]));

    act(() => ref.current?.handleSortEnd({ oldIndex: 0, newIndex: 1 }));
    expect(pending).toHaveLength(2);
  });

  it("shows the server's message and stops saving the copy", async () => {
    render(<ManageClasses classes={makeClasses()} />);

    fireEvent.click(screen.getAllByText("Copy")[0]);
    fireEvent.click(screen.getByText("Save"));

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Unable to copy the class!\n${message}.\n\n${hint}`);
    });
    expect(screen.getByText("Save")).toBeEnabled();
  });
});
