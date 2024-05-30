const cache: any = {};

export const loadMaterialsCollections = (ids: any, callback: any) => {
  const onComplete = () => {
    const data = ids.map((id: any) => cache[id] || { name: "MISSING-COLLECTION-" + id, materials: [] });
    callback(data);
  };

  // ensure we only request each id once
  const missingIds = ids.filter((id: any) => !cache[id]);
  if (missingIds.length === 0) {
    onComplete();
    return;
  }

  jQuery.ajax({
    url: Portal.API_V1.MATERIALS_BIN_COLLECTIONS,
    data: {
      id: missingIds,
      skip_lightbox_reloads: true
    },
    dataType: "json",
    success: (missingData) => {
      missingIds.forEach((id: any, index: any) => {
        cache[id] = missingData[index];
      });
    },
    complete: () => {
      onComplete();
    }
  });
};

export const loadMaterialsCollection = (id: any, callback: any) => {
  loadMaterialsCollections([id], (data: any) => {
    callback(data[0]);
  });
};
