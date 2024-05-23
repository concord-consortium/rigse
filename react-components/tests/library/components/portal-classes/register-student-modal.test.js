import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import RegisterStudentModal from 'components/portal-classes/register-student-modal';

describe('When I try to render a register student modal', () => {
  it('should render', () => {
    render(<RegisterStudentModal />);

    expect(screen.getByText('Register & Add New Student')).toBeInTheDocument();
    expect(screen.getByLabelText('First Name')).toBeInTheDocument();
    expect(screen.getByLabelText('Last Name')).toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toBeInTheDocument();
    expect(screen.getByLabelText('Password Again')).toBeInTheDocument();
    expect(screen.getByText('Submit')).toBeInTheDocument();
    expect(screen.getByText('Cancel')).toBeInTheDocument();
  });

  it('should support the cancel button', () => {
    const cancel = jest.fn();
    render(<RegisterStudentModal onCancel={cancel} />);
    const cancelButton = screen.getByText('Cancel');

    fireEvent.click(cancelButton);
    expect(cancel).toHaveBeenCalled();
  });

  it('should not submit without the fields being filled', () => {
    const savedAlert = global.alert;
    global.alert = jest.fn();

    const submit = jest.fn();
    render(<RegisterStudentModal onSubmit={submit} />);
    const submitButton = screen.getByText('Submit');

    fireEvent.click(submitButton);

    expect(global.alert).toHaveBeenCalledWith('Please fill in all the fields');
    expect(submit).not.toHaveBeenCalled();

    global.alert = savedAlert;
  });

  it('should not submit without the passwords matching', () => {
    const savedAlert = global.alert;
    global.alert = jest.fn();

    const submit = jest.fn();
    render(<RegisterStudentModal onSubmit={submit} />);

    fireEvent.change(screen.getByLabelText('First Name'), { target: { value: 'Test' } });
    fireEvent.change(screen.getByLabelText('Last Name'), { target: { value: 'Testerson' } });
    fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'passw0rd' } });
    fireEvent.change(screen.getByLabelText('Password Again'), { target: { value: 'not same password' } });

    fireEvent.click(screen.getByText('Submit'));

    expect(global.alert).toHaveBeenCalledWith('Passwords do not match!');
    expect(submit).not.toHaveBeenCalled();

    global.alert.mockReset();

    fireEvent.change(screen.getByLabelText('Password Again'), { target: { value: 'passw0rd' } });

    fireEvent.click(screen.getByText('Submit'));

    expect(global.alert).not.toHaveBeenCalledWith('Passwords do not match!');
    expect(submit).toHaveBeenCalledWith({
      firstName: 'Test',
      lastName: 'Testerson',
      password: 'passw0rd',
      passwordConfirmation: 'passw0rd',
    });

    global.alert = savedAlert;
  });
});
