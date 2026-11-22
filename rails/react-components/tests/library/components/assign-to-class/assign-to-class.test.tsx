import openAssignToClassModal from "../../../../src/library/components/assign-to-class/assign-to-class";
import { render } from "../../../../src/library/helpers/react-render";
import { mockJquery } from "../../helpers/mock-jquery";

jest.mock("../../../../src/library/helpers/react-render", () => ({ render: jest.fn(), unmount: jest.fn() }));
jest.mock("../../../../src/library/helpers/modal", () => ({ showModal: jest.fn(), hideModal: jest.fn() }));

const hint = "You may have switched to learner mode in another tab, so this page is out of date. Reload the page to continue.";
const material = { name: "Material 1", preview_url: "http://example.com/1", material_type: "Activity", saves_student_data: true };
const classList = { assigned_classes: [], unassigned_classes: [{ id: 1, name: "Class 1" }] };

// Each request answers at once, with a success (done) or a failure (fail), like a jQuery promise.
let answers: Record<string, { ok: boolean, body: any }>;
const fakeRequest = (url: string) => {
  const { ok, body } = answers[url];
  const request: any = {
    done: (callback: any) => { if (ok) callback(body); return request; },
    fail: (callback: any) => { if (!ok) callback(body); return request; },
  };
  return request;
};

describe("openAssignToClassModal", () => {
  mockJquery(Object.assign(() => ({ length: 1, 0: document.createElement("div") }), { post: jest.fn(fakeRequest) }));

  const setUser = (isAnonymous: boolean) => {
    window.Portal = {
      API_V1: { MATERIAL_SHOW: "/show", MATERIAL_UNASSIGNED_CLASSES: "/unassigned_clazzes" },
      currentUser: { isAnonymous },
    };
  };

  beforeEach(() => {
    setUser(false);
    answers = {
      "/show": { ok: true, body: material },
      "/unassigned_clazzes": { ok: true, body: classList },
    };
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
    (render as jest.Mock).mockClear();
    window.jQuery.post.mockClear();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  const renderedProps = () => (render as jest.Mock).mock.calls[0][0].props;

  it("opens the pop-up with the class list", () => {
    openAssignToClassModal({ material_id: 1, material_type: "ExternalActivity" });
    expect(render).toHaveBeenCalledTimes(1);
    expect(renderedProps().classes).toEqual(classList);
    expect(window.alert).not.toHaveBeenCalled();
  });

  it("shows only an alert with the server's message when the class list is refused", () => {
    answers["/unassigned_clazzes"] = {
      ok: false,
      body: { responseText: JSON.stringify({ message: "You must be logged in as a teacher to assign materials", learner_mode_hint: hint }) },
    };
    openAssignToClassModal({ material_id: 1, material_type: "ExternalActivity" });
    expect(window.alert).toHaveBeenCalledWith(`There was an error: You must be logged in as a teacher to assign materials.\n${hint}`);
    expect(render).not.toHaveBeenCalled();
  });

  it("opens the pop-up without a class list for an anonymous user", () => {
    setUser(true);
    openAssignToClassModal({ material_id: 1, material_type: "ExternalActivity" });
    expect(render).toHaveBeenCalledTimes(1);
    expect(renderedProps().classes).toBeUndefined();
    expect(jQuery.post).not.toHaveBeenCalledWith("/unassigned_clazzes", expect.anything());
  });
});
