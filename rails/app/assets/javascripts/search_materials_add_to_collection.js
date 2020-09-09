Portal.assignMaterialToSpecificClass = function(assign, classId, materialId, materialClassName) {
    params = {
      assign: assign ? 1 : 0,
      class_id: classId,
      material_id: materialId,
      material_type: materialClassName
    };
    jQuery.post(Portal.API_V1.ASSIGN_MATERIAL_TO_CLASS, params);
};
