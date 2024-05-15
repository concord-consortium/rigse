import ReactDOM from 'react-dom/client'

const reactRootMap = new Map()

export const render = function (component, idOrElement) {
  const element = typeof idOrElement === 'string' ? document.getElementById(idOrElement) : idOrElement

  if (!reactRootMap.has(element)) {
    const root = ReactDOM.createRoot(element)
    reactRootMap.set(element, root)
  }
  const root = reactRootMap.get(element)

  // NOTE: some components (e.g., the search results) re-render into the same div, but in React 18 it is NOT necessary
  // to unmount any previous component. It's enough to call render again.
  root.render(component)
}

export const unmount = function (idOrElement) {
  const element = typeof idOrElement === 'string' ? document.getElementById(idOrElement) : idOrElement

  if (reactRootMap.has(element)) {
    const root = reactRootMap.get(element)
    root.unmount()
    reactRootMap.delete(element)
  }
}