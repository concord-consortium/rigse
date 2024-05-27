import React from 'react'

const createFactory = (type: any): React.FC<any> => React.createElement.bind(null, type)

export default createFactory
