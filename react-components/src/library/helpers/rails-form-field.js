const railsFormField = (prefix) => {
  return (field) => {
    return {
      id: `${prefix}_${field}`,
      name: `${prefix}[${field}]`,
      htmlFor: field
    }
  }
}

export default railsFormField
