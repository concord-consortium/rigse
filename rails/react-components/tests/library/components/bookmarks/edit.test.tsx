import React from "react";
import { render, fireEvent, screen, waitFor, act } from "@testing-library/react";
import EditBookmarks from "../../../../src/library/components/bookmarks/edit";
import { mockJquery, mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

describe("When I try to render sortable bookmarks", () => {
  const clone = (obj: any) => JSON.parse(JSON.stringify(obj));

  const singleBookmark = [
    {
      id: 1,
      is_visible: true,
      name: "Link 1",
      position: 0,
      url: "http://example.com/1",
    },
  ];

  const multipleBookmarks = [
    {
      id: 1,
      is_visible: true,
      name: "Link 1",
      position: 0,
      url: "http://example.com/1",
    },
    {
      id: 2,
      is_visible: false,
      name: "Link 2",
      position: 1,
      url: "http://example.com/2",
    },
    {
      id: 3,
      is_visible: true,
      name: "Link 3",
      position: 2,
      url: "http://example.com/3",
    },
  ];

  mockJqueryAjaxSuccess({
    success: true,
  });

  it("should render 0 bookmarks", () => {
    render(<EditBookmarks classId={1} bookmarks={[]} />);
    expect(screen.getByText("Create Link")).toBeInTheDocument();
  });

  it("should render 1 bookmark", () => {
    render(<EditBookmarks classId={1} bookmarks={singleBookmark} />);
    expect(screen.getByText("Link 1")).toBeInTheDocument();
    expect(screen.getByText("Create Link")).toBeInTheDocument();
  });

  it("should render multiple bookmarks", () => {
    render(<EditBookmarks classId={1} bookmarks={multipleBookmarks} />);
    expect(screen.getByText("Link 1")).toBeInTheDocument();
    expect(screen.getByText("Link 2")).toBeInTheDocument();
    expect(screen.getByText("Link 3")).toBeInTheDocument();
  });

  it("should handle toggle to edit and then cancel", () => {
    render(<EditBookmarks classId={1} bookmarks={singleBookmark} />);

    const editButton = screen.getByText("Edit");
    fireEvent.click(editButton);

    expect(screen.getByPlaceholderText("Name")).toBeInTheDocument();
    expect(screen.getByPlaceholderText("URL")).toBeInTheDocument();

    const cancelButton = screen.getByText("Cancel");
    fireEvent.click(cancelButton);

    expect(screen.queryByPlaceholderText("Name")).not.toBeInTheDocument();
    expect(screen.queryByPlaceholderText("URL")).not.toBeInTheDocument();
  });

  it("should handle toggle to edit and then save", () => {
    render(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);

    const editButton = screen.getByText("Edit");
    fireEvent.click(editButton);

    const nameInput = screen.getByPlaceholderText("Name");
    const urlInput = screen.getByPlaceholderText("URL");
    const saveButton = screen.getByText("Save");

    fireEvent.change(nameInput, { target: { value: "Updated Link Name" } });
    fireEvent.change(urlInput, { target: { value: "http://example.com/updated" } });
    fireEvent.click(saveButton);

    expect(screen.getByText("Updated Link Name")).toBeInTheDocument();
    const updatedLink = screen.getByText("Updated Link Name").closest("a");
    expect(updatedLink).toHaveAttribute("href", "http://example.com/updated");
  });

  it("should handle toggle to hide -> unhide -> hide", async () => {
    render(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);

    const hideButton = screen.getByText("Hide");
    fireEvent.click(hideButton);

    expect(await screen.findByText("Show")).toBeInTheDocument();

    fireEvent.click(screen.getByText("Show"));
    expect(await screen.findByText("Hide")).toBeInTheDocument();

    fireEvent.click(screen.getByText("Hide"));
    expect(await screen.findByText("Show")).toBeInTheDocument();
  });

  it("should handle the delete button", async () => {
    render(<EditBookmarks classId={1} bookmarks={clone(singleBookmark)} />);
    const deleteButton = screen.getByText("Delete");

    // before delete
    expect(screen.getByText("Link 1")).toBeInTheDocument();

    window.confirm = jest.fn(() => false);
    fireEvent.click(deleteButton);
    expect(screen.getByText("Link 1")).toBeInTheDocument();

    window.confirm = jest.fn(() => true);
    fireEvent.click(deleteButton);
    await waitFor(() => expect(screen.queryByText("Link 1")).not.toBeInTheDocument());
  });
});

describe("When I try to create bookmarks", () => {
  mockJqueryAjaxSuccess({
    success: true,
    data: {
      id: 1,
      is_visible: true,
      name: "New Link",
      position: 0,
      url: "http://example.com/new",
    },
  });

  it("should handle the create button", () => {
    render(<EditBookmarks classId={1} bookmarks={[]} />);
    const createButton = screen.getByText("Create Link");

    expect(screen.getByText("Create Link")).toBeInTheDocument();

    fireEvent.click(createButton);

    expect(screen.getByPlaceholderText("Name")).toBeInTheDocument();
    expect(screen.getByPlaceholderText("URL")).toBeInTheDocument();
  });
});

describe("When a Links request is refused", () => {
  const message = "You are not authorized to edit bookmarks for this class. You may have switched to learner mode in another tab.";
  const refusal = { success: false, message };
  let respond: (options: any) => void;
  let alertSpy: jest.SpyInstance;

  mockJquery({
    ajax: jest.fn().mockImplementation((options) => respond(options))
  });

  const makeBookmarks = () => [
    { id: 1, is_visible: true, name: "Link 1", position: 0, url: "http://example.com/1" },
    { id: 2, is_visible: true, name: "Link 2", position: 1, url: "http://example.com/2" },
  ];
  const linkNames = () => screen.queryAllByText(/^Link \d$/).map(el => el.textContent);

  // Records what the page shows while the alert is open.
  let shownDuringAlert: any;
  const recordDuringAlert = (read: () => any) => {
    alertSpy.mockImplementation(() => { shownDuringAlert = read(); });
  };

  beforeEach(() => {
    respond = (options) => options.error({ responseText: JSON.stringify(refusal) }, "error", "Bad Request");
    alertSpy = jest.spyOn(window, "alert").mockImplementation(() => undefined);
    window.confirm = jest.fn(() => true);
    shownDuringAlert = undefined;
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("shows the server's message when creating fails", async () => {
    render(<EditBookmarks classId={1} bookmarks={makeBookmarks()} />);

    fireEvent.click(screen.getByText("Create Link"));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to create link!\n${message}`));
    expect(screen.queryByPlaceholderText("Name")).not.toBeInTheDocument();
  });

  it("shows the server's message when the response is not successful", async () => {
    respond = (options) => options.success(refusal);
    render(<EditBookmarks classId={1} bookmarks={makeBookmarks()} />);

    fireEvent.click(screen.getByText("Create Link"));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to create link!\n${message}`));
  });

  it("puts the old name back, then shows the server's message when editing fails", async () => {
    recordDuringAlert(linkNames);
    render(<EditBookmarks classId={1} bookmarks={makeBookmarks()} />);

    fireEvent.click(screen.getAllByText("Edit")[0]);
    fireEvent.change(screen.getByPlaceholderText("Name"), { target: { value: "Changed" } });
    fireEvent.click(screen.getByText("Save"));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to update link!\n${message}`));
    expect(shownDuringAlert).toEqual(["Link 1", "Link 2"]);
  });

  it("shows the server's message and does not change the link when hiding fails", async () => {
    recordDuringAlert(() => screen.queryAllByText("Hide").length);
    render(<EditBookmarks classId={1} bookmarks={makeBookmarks()} />);

    fireEvent.click(screen.getAllByText("Hide")[0]);

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to toggle visibility of link!\n${message}`));
    expect(shownDuringAlert).toBe(2);
  });

  it("shows the server's message and keeps the link when deleting fails", async () => {
    recordDuringAlert(linkNames);
    render(<EditBookmarks classId={1} bookmarks={makeBookmarks()} />);

    fireEvent.click(screen.getAllByText("Delete")[0]);

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to delete link!\n${message}`));
    expect(shownDuringAlert).toEqual(["Link 1", "Link 2"]);
  });

  it("puts the old order back, then shows the server's message when sorting fails", async () => {
    recordDuringAlert(linkNames);
    const ref = React.createRef<EditBookmarks>();
    render(<EditBookmarks ref={ref} classId={1} bookmarks={makeBookmarks()} />);

    act(() => ref.current?.handleSortEnd({ oldIndex: 0, newIndex: 1 }));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to save link sort order!\n${message}`));
    expect(shownDuringAlert).toEqual(["Link 1", "Link 2"]);
  });
});
