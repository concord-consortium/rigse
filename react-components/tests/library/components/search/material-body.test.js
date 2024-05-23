import React from 'react';
import { render, screen } from '@testing-library/react';
import SMaterialBody from 'components/search/material-body';

describe('When I try to render search material bodies', () => {

  it("should render singular values", () => {
    const material = {
      class_count: 1,
      sensors: ["sensor"]
    }
    render(<SMaterialBody material={material} />);

    expect(screen.getByText('Used in 1 class.')).toBeInTheDocument();
    expect(screen.getByText('Required sensor(s):')).toBeInTheDocument();
    expect(screen.getByText('sensor')).toHaveStyle('font-weight: bold');
  });

  it("should render non-singular values", () => {
    const material = {
      class_count: 2,
      sensors: ["sensor1", "sensor2"]
    }
    render(<SMaterialBody material={material} />);

    expect(screen.getByText('Used in 2 classes.')).toBeInTheDocument();
    expect(screen.getByText('Required sensor(s):')).toBeInTheDocument();
    expect(screen.getByText('sensor1, sensor2')).toHaveStyle('font-weight: bold');
  });

});
