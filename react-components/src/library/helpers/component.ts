import createClass from 'create-react-class'
import createFactory from './create-factory'

var Component = function (options: any) {
  return createFactory(createClass(options)) as any
}

export default Component
