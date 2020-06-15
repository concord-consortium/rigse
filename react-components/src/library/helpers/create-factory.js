import React from 'react'

const createFactory = type => React.createElement.bind(null, type)

export default createFactory
