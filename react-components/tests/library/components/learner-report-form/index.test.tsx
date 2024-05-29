import React from "react";
import { render, screen } from "@testing-library/react";
import LearnerReportForm from "../../../../src/library/components/learner-report-form";

describe("LearnerReportForm", () => {
  const externalReports = [
    { url: "url1", name: "first", label: "label1" },
    { url: "url2", name: "second", label: "label2" },
  ];

  describe("as non-admin or non-manager", () => {
    beforeEach(() => {
      jest.clearAllMocks();
      // form uses Portal global
      window.Portal = {
        currentUser: {
          isAdmin: false,
          isManager: false,
        },
        API_V1: {
          EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: "http://query-test.concord.org",
        },
      };
    });

    it("renders custom external report buttons", () => {
      render(<LearnerReportForm externalReports={externalReports} />);

      const externalReportButtons = screen.getAllByRole("button", { name: /label/ });
      expect(externalReportButtons).toHaveLength(2);

      const button1 = screen.getByRole("button", { name: "label1" });
      const button2 = screen.getByRole("button", { name: "label2" });

      expect(button1).toBeInTheDocument();
      expect(button2).toBeInTheDocument();
    });

    it("renders filter forms", () => {
      render(<LearnerReportForm externalReports={externalReports} />);

      expect(screen.getByText("Schools")).toBeInTheDocument();
      expect(screen.getByText("Teachers")).toBeInTheDocument();
      expect(screen.getByText("Resources")).toBeInTheDocument();
      expect(screen.getByText("Permission forms")).toBeInTheDocument();

      const selects = screen.getAllByRole("combobox");
      expect(selects).toHaveLength(4);

      expect(screen.getByText("Earliest date of last run")).toBeInTheDocument();
      expect(screen.getByText("Latest date of last run")).toBeInTheDocument();

      const earliestDateInput = screen.getByLabelText("Earliest date of last run");
      const latestDateInput = screen.getByLabelText("Latest date of last run");
      expect(earliestDateInput).toBeInTheDocument();
      expect(latestDateInput).toBeInTheDocument();

      expect(screen.queryByLabelText("Hide names")).not.toBeInTheDocument();
      expect(screen.queryByRole("checkbox")).not.toBeInTheDocument();
    });
  });

  describe("as admin", () => {
    beforeEach(() => {
      jest.clearAllMocks();
      // form uses Portal global
      window.Portal = {
        currentUser: {
          isAdmin: true,
          isManager: false,
        },
        API_V1: {
          EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: "http://query-test.concord.org",
        },
      };
    });

    it("renders hide names checkbox", () => {
      render(<LearnerReportForm externalReports={externalReports} />);

      expect(screen.getByLabelText("Hide names")).toBeInTheDocument();
      expect(screen.getByRole("checkbox")).toBeInTheDocument();
    });
  });

  describe("as manager", () => {
    beforeEach(() => {
      jest.clearAllMocks();
      // form uses Portal global
      window.Portal = {
        currentUser: {
          isAdmin: false,
          isManager: true,
        },
        API_V1: {
          EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: "http://query-test.concord.org",
        },
      };
    });

    it("renders hide names checkbox", () => {
      render(<LearnerReportForm externalReports={externalReports} />);

      expect(screen.getByLabelText("Hide names")).toBeInTheDocument();
      expect(screen.getByRole("checkbox")).toBeInTheDocument();
    });
  });
});
