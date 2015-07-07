MaterialsBin = React.createFactory require 'components/materials_bin/materials_bin'
MaterialsCollection = React.createFactory require 'components/materials_collection/materials_collection'
FeaturedMaterials = React.createFactory require 'components/featured_materials/featured_materials'

Portal.renderMaterialsBin = (definition, selectorOrElement) ->
  React.render(MaterialsBin({materials: definition}), jQuery(selectorOrElement)[0])

Portal.renderMaterialsCollection = (collectionId, selectorOrElement, limit = Infinity) ->
  React.render MaterialsCollection(collection: collectionId, limit: limit), jQuery(selectorOrElement)[0]

Portal.renderFeaturedMaterials = (selectorOrElement) ->
  query = window.location.search
  query = query.slice(1) if query[0] == '?'
  React.render FeaturedMaterials(queryString: query), jQuery(selectorOrElement)[0]
