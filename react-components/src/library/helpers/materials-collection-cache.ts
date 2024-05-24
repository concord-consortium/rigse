const cache = {}

export const loadMaterialsCollections = (ids, callback) => {
  const onComplete = () => {
    const data = ids.map(id => cache[id] || { name: 'MISSING-COLLECTION-' + id, materials: [] })
    callback(data)
  }

  // ensure we only request each id once
  const missingIds = ids.filter(id => !cache[id])
  if (missingIds.length === 0) {
    onComplete()
    return
  }

  jQuery.ajax({
    url: Portal.API_V1.MATERIALS_BIN_COLLECTIONS,
    data: {
      id: missingIds,
      skip_lightbox_reloads: true
    },
    dataType: 'json',
    success: (missingData) => {
      missingIds.forEach((id, index) => {
        cache[id] = missingData[index]
      })
    },
    complete: () => {
      onComplete()
    }
  })
}

export const loadMaterialsCollection = (id, callback) => {
  loadMaterialsCollections([id], (data) => {
    callback(data[0])
  })
}
