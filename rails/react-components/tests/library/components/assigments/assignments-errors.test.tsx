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
  });

  it("shows the server's message when loading the offering details fails", async () => {
    render(<Assignments initialClassData={makeClassData()} />);

    fireEvent.click(screen.getAllByText("+ SHOW DETAIL")[0]);

    await waitFor(() => {
      expect(window.alert).toHaveBeenCalledWith(`Offering details loading failed, please try to reload page and try again.\n${message}.\n\n${hint}`);
    });
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
});
