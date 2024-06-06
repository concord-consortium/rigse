import React from "react";
import { render, screen, act, fireEvent, getByTestId } from "@testing-library/react";
import PermissionFormsV2 from "../../../../src/library/components/permission-forms-v2";
import { useFetch } from "../../../../src/library/hooks/use-fetch";

jest.mock("../../../../src/library/hooks/use-fetch");

window.Portal = {
  API_V1: {
    PROJECTS: "/api/v1/projects",
    PERMISSION_FORMS: "/api/v1/permission_forms",
  }
};

describe("PermissionFormsV2", () => {
  beforeEach(() => {
    const mockPermissions = [
      { id: 1, name: 'Form 1', project_id: 1 },
      { id: 2, name: 'Form 2', project_id: 2 },
      { id: 3, name: 'Form 3', project_id: 1 },
    ];
    const mockProjects = [
      { id: 1, name: 'Project 1' },
      { id: 2, name: 'Project 2' },
    ];

    (useFetch as jest.Mock).mockImplementation((url: string) => {
      if (url === window.Portal.API_V1.PERMISSION_FORMS) {
        return {
          data: mockPermissions,
          refetch: jest.fn().mockResolvedValue({ data: mockPermissions }),
        };
      } else if (url === window.Portal.API_V1.PROJECTS) {
        return {
          data: mockProjects,
          refetch: jest.fn().mockResolvedValue({ data: mockProjects }),
        };
      }
    });
  });

  it("renders and filters list of permission forms", () => {
    render(<PermissionFormsV2 />);

    expect(screen.getByText('Form 1')).toBeInTheDocument();
    expect(screen.getByText('Form 2')).toBeInTheDocument();
    expect(screen.getByText('Form 3')).toBeInTheDocument();

    const projectSelect = screen.getByTestId('top-project-select');
    fireEvent.change(projectSelect, { target: { value: 1 } });

    expect(screen.getByText('Form 1')).toBeInTheDocument();
    expect(screen.getByText('Form 3')).toBeInTheDocument();
    expect(screen.queryByText('Form 2')).not.toBeInTheDocument();
  });
});
