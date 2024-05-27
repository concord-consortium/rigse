/* globals describe it expect */
import React from 'react'
import { render, screen } from '@testing-library/react'
// @ts-expect-error TS(2307): Cannot find module 'components/standards/standards... Remove this comment to see the full error message
import StandardsRow from 'components/standards/standards-row'

const material = {
  material_id: 1,
  material_type: "test-material-type",
};

const defaultStatement = {
  uri: "https://example.com/",
  is_applied: false,
  is_leaf: false,
  education_level: [],
  doc: "doc",
  description: "description",
  statement_label: "statement_label",
  statement_notation: "statement_notation",
}

describe('When I try to render a standards row', () => {
  const renderStandardsRow = (statement: any) => {
    return render(
      <table>
        <tbody>
          <StandardsRow statement={statement} material={material} />
        </tbody>
      </table>
    )
  }

  it("renders correctly with default statement", () => {
    renderStandardsRow(defaultStatement);

    expect(screen.getByText('doc')).toBeInTheDocument();
    expect(screen.getByText('description')).toBeInTheDocument();
    expect(screen.getByText('statement_label')).toBeInTheDocument();
    expect(screen.getByText('statement_notation')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: '🔗' })).toHaveAttribute('href', 'https://example.com/');
    expect(screen.getByRole('button', { name: 'Add' })).toBeInTheDocument();
  });

  it("renders is_applied correctly", () => {
    const statement = { ...defaultStatement, is_applied: true };
    renderStandardsRow(statement);

    expect(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
  });

  it("renders is_leaf correctly", () => {
    const statement = { ...defaultStatement, is_leaf: true };
    renderStandardsRow(statement);

    expect(screen.getByText('✔')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Add' })).toBeInTheDocument();
  });

  it("renders education_level correctly", () => {
    const statement = { ...defaultStatement, education_level: [1, 2, 3] };
    renderStandardsRow(statement);

    expect(screen.getByText('1, 2, 3')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Add' })).toBeInTheDocument();
  });
});
