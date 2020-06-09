
// Format is "EntityName: 'StringKey StringKey String Key'"

const resourceUpdateParams = {
  User: "firstName lastName email",
  AdminProject: "name landingPageSlug public projectCardImageUrl projectCardDescription"
}

const filterUpdateParams = (resource, allParams) => {
  const keys = resourceUpdateParams[resource].split(/\s+/)
  const params = {}
  console.dir(resource)
  console.dir(keys)
  console.dir(allParams)
  keys.forEach(key => params[key] = allParams[key]);
  console.dir(params)
  return params
}

export default filterUpdateParams