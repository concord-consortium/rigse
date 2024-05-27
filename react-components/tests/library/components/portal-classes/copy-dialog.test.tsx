import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/portal-classes/copy... Remove this comment to see the full error message
import CopyDialog from 'components/portal-classes/copy-dialog';

describe('When I try to render class copy dialog', () => {
  const clazz = {
    name: 'test class',
    classWord: 'test_class',
    description: 'this is a test class',
  };

  it('should render', () => {
    render(<CopyDialog clazz={clazz} />);

    expect(screen.getByText('Copy Class')).toBeInTheDocument();
    expect(screen.getByDisplayValue('Copy of test class')).toBeInTheDocument();
    expect(screen.getByDisplayValue('Copy of test_class')).toBeInTheDocument();
    expect(screen.getByDisplayValue('this is a test class')).toBeInTheDocument();
    expect(screen.getByText('Save')).toBeInTheDocument();
    expect(screen.getByText('Cancel')).toBeInTheDocument();
  });

  it('should handle cancel', () => {
    const handleCancel = jest.fn();
    render(<CopyDialog clazz={clazz} handleCancel={handleCancel} />);
    const cancelButton = screen.getByText('Cancel');

    fireEvent.click(cancelButton);
    expect(handleCancel).toHaveBeenCalled();
  });

  it('should disable saving when name is whitespace', () => {
    render(<CopyDialog clazz={clazz} />);
    const nameInput = screen.getByDisplayValue('Copy of test class');
    const saveButton = screen.getByText('Save');

    expect(saveButton).not.toBeDisabled();
    expect(nameInput).toHaveValue('Copy of test class');

    fireEvent.change(nameInput, { target: { value: '   ' } });
    expect(saveButton).toBeDisabled();
  });

  it('should disable saving when classWord is whitespace', () => {
    render(<CopyDialog clazz={clazz} />);
    const classWordInput = screen.getByDisplayValue('Copy of test_class');
    const saveButton = screen.getByText('Save');

    expect(saveButton).not.toBeDisabled();
    expect(classWordInput).toHaveValue('Copy of test_class');

    fireEvent.change(classWordInput, { target: { value: '   ' } });
    expect(saveButton).toBeDisabled();
  });

  it('should handle save', () => {
    const handleSave = jest.fn();
    render(<CopyDialog clazz={clazz} handleSave={handleSave} />);
    const saveButton = screen.getByText('Save');

    fireEvent.click(saveButton);

    expect(handleSave).toHaveBeenCalledWith({
      name: 'Copy of test class',
      classWord: 'Copy of test_class',
      description: 'this is a test class',
    });
  });

  it('should update the save button text', () => {
    render(<CopyDialog clazz={clazz} saving={true} />);
    const saveButton = screen.getByText('Saving ...');

    expect(saveButton).toBeDisabled();
  });
});
