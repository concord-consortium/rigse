const railsFormField = (prefix: any) => {
  return (field: any) => {
    return {
      id: `${prefix}_${field}`,
      name: `${prefix}[${field}]`,
      htmlFor: field
    }
  };
}

export default railsFormField
