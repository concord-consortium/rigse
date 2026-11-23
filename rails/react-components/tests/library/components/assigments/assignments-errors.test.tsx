import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react";
import Assignments from "../../../../src/library/components/assigments";
import ProgressTableRow from "../../../../src/library/components/common/offering-progress/offering-progress-row";
import { mockJquery } from "../../helpers/mock-jquery";

const message = "Not authorized";

const hint = "You may have switched to learner mode in another tab, so this page is out of date. Reload the page to continue.";
const refused = { responseText: JSON.stringify({ success: false, message, learner_mode_hint: hint }) };

window.Portal = {
  API_V1: { GET_TEACHER_PROJECT_VIEWS: "/project_views" },
  currentUser: { isTeacher: true },
};

const makeClassData = () => ({
  id: 1,
  name: "Class 1",
  class_word: "class1",
  teachers: [],
  offerings: [
    { id: 1, name: "Offering 1", url: "http://example.com/api/v1/offerings/1", active: true, locked: false, metadata: [] },
    { id: 2, name: "Offering 2", url: "http://example.com/api/v1/offerings/2", active: true, locked: false, metadata: [] },
  ],
});

describe("When a Class Assignments request is refused", () => {
  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      // The page also loads the teacher's collections. Leave that request unanswered.
      // Answer the others later, as a real request does.
      if (options.url !== "/project_views") {
        setTimeout(() => options.error(refused));
      }
    })
  });

  let shownDuringAlert: any;
  const recordDuringAlert = (read: () => any) => {
    (window.alert as jest.Mock).mockImplementation(() => { shownDuringAlert = read(); });
  };
  const offeringNames = () => screen.getAllByText(/^Offering \d$/).map(el => el.textContent);

  beforeEach(() => {
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
    shownDuringAlert = undefined;
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("puts the old order back, then shows the server's message when reordering fails", async () => {
    recordDuringAlert(offeringNames);
    const ref = React.createRef<Assignments>();
    render(<Assignments ref={ref} initialClassData={makeClassData()} />);

    act(() => ref.current?.onOfferingsReorder({ oldIndex: 0, newIndex: 1 }));

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Reordering failed, please try to reload page and try again.\n${message}.\n\n${hint}`);
    });
    expect(shownDuringAlert).toEqual(["Offering 1", "Offering 2"]);
  });

  it("shows the server's message and does not change the checkbox when an offering update fails", async () => {
    recordDuringAlert(() => (screen.getAllByRole("checkbox")[0] as HTMLInputElement).checked);
    render(<Assignments initialClassData={makeClassData()} />);

    fireEvent.click(screen.getAllByRole("checkbox")[0]);

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Offering update failed, please try to reload page and try again.\n${message}.\n\n${hint}`));
    expect(shownDuringAlert).toBe(true);
    expect((screen.getAllByRole("checkbox")[0] as HTMLInputElement).checked).toBe(true);
    expect((screen.getAllByRole("checkbox")[0] as HTMLInputElement).disabled).toBe(false);
  });

  it("shows the server's message and closes the row when loading the offering details fails", async () => {
    recordDuringAlert(() => screen.queryAllByText("- HIDE DETAIL").length);
    render(<Assignments initialClassData={makeClassData()} />);

    fireEvent.click(screen.getAllByText("+ SHOW DETAIL")[0]);

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Offering details loading failed, please try to reload page and try again.\n${message}.\n\n${hint}`);
    });
    expect(shownDuringAlert).toBe(0);
  });

  it("shows the server's message when a student update fails", async () => {
    const student = { id: 5, name: "Student 5", active: true, locked: false, startedActivity: false };
    render(
      <table>
        <tbody>
          <ProgressTableRow student={student} offering={{ id: 1 }} offeringDetails={{ id: 1 }} onSetStudentOfferingMetadata={jest.fn()} />
        </tbody>
      </table>
    );

    fireEvent.click(screen.getAllByRole("checkbox")[0]);

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Student metadata update failed, please try to reload page and try again.\n${message}.\n\n${hint}`);
    });
  });
});

describe("When a Class Assignments offering update succeeds", () => {
  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      if (options.url !== "/project_views") {
        setTimeout(() => options.success({}));
      }
    })
  });

  it("changes the checkbox after the server agrees", async () => {
    render(<Assignments initialClassData={makeClassData()} />);

    fireEvent.click(screen.getAllByRole("checkbox")[0]);

    await waitFor(() => expect((screen.getAllByRole("checkbox")[0] as HTMLInputElement).checked).toBe(false));
  });

  it("disables the offering's checkboxes until the server answers", async () => {
    render(<Assignments initialClassData={makeClassData()} />);
    const disabled = () => screen.getAllByRole("checkbox").map(el => (el as HTMLInputElement).disabled);

    fireEvent.click(screen.getAllByRole("checkbox")[1]);

    expect(disabled()).toEqual([true, true, false, false]);
    await waitFor(() => expect(disabled()).toEqual([false, false, false, false]));
  });

  it("disables the student checkboxes while an offering update waits for the server", () => {
    const student = { id: 5, name: "Student 5", active: true, locked: false, startedActivity: false };
    render(
      <table>
        <tbody>
          <ProgressTableRow student={student} offering={{ id: 1, updatePending: true }} offeringDetails={{ id: 1 }} onSetStudentOfferingMetadata={jest.fn()} />
        </tbody>
      </table>
    );

    expect(screen.getAllByRole("checkbox").map(el => (el as HTMLInputElement).disabled)).toEqual([true, true]);
  });
});

describe("When a Class Assignments reorder waits for the server", () => {
  let pending: any[];
  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      if (options.url !== "/project_views") {
        pending.push(options);
      }
    })
  });

  const checked = () => screen.getAllByRole("checkbox").map(el => (el as HTMLInputElement).checked);

  beforeEach(() => {
    pending = [];
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("ignores a second drag", () => {
    const ref = React.createRef<Assignments>();
    render(<Assignments ref={ref} initialClassData={makeClassData()} />);

    act(() => ref.current?.onOfferingsReorder({ oldIndex: 0, newIndex: 1 }));
    act(() => ref.current?.onOfferingsReorder({ oldIndex: 0, newIndex: 1 }));

    expect(pending).toHaveLength(1);
    expect(screen.getAllByText(/^Offering \d$/).map(el => el.textContent)).toEqual(["Offering 2", "Offering 1"]);
  });

  it("keeps a checkbox change made while the reorder waited when the reorder fails", async () => {
    const ref = React.createRef<Assignments>();
    render(<Assignments ref={ref} initialClassData={makeClassData()} />);

    act(() => ref.current?.onOfferingsReorder({ oldIndex: 0, newIndex: 1 }));
    // Offering 2 is now first. Hide it.
    fireEvent.click(screen.getAllByRole("checkbox")[0]);
    const [reorderRequest, updateRequest] = pending;
    act(() => updateRequest.success({}));
    act(() => reorderRequest.error(refused));

    await waitFor(() => expect(window.alert).toHaveBeenCalled());
    expect(screen.getAllByText(/^Offering \d$/).map(el => el.textContent)).toEqual(["Offering 1", "Offering 2"]);
    expect(checked()).toEqual([true, false, false, false]);
  });
});
