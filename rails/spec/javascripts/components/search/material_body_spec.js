//= require helpers/react_helper

describe('SMaterialBodyClass', function() {

  it("renders an empty div with no material class_count or sensors", function() {
    const result = renderStatic(SMaterialBodyClass, {material: {}});
    expect(result).toBe('<div class="material_body"></div>');
  });

  it("renders only the class count with a material class_count and no sensors", function() {
    const material = {class_count: 0};
    const zeroResult = renderStatic(SMaterialBodyClass, {material});
    expect(zeroResult).toBe('<div class="material_body"><div><i>Not used in any class.</i></div></div>');

    material.class_count = 1;
    const singleResult = renderStatic(SMaterialBodyClass, {material});
    expect(singleResult).toBe('<div class="material_body"><div><i>Used in 1 class.</i></div></div>');

    material.class_count = 2;
    const multipleResult = renderStatic(SMaterialBodyClass, {material});
    expect(multipleResult).toBe('<div class="material_body"><div><i>Used in 2 classes.</i></div></div>');
  });

  it("renders only sensors", function() {
    const material = {sensors: ['foo', 'bar']};

    const result = renderStatic(SMaterialBodyClass, {material});
    expect(result).toBe('<div class="material_body"><div class="required_equipment_container"><span>Required sensor(s):</span><span style="font-weight:bold;">foo, bar</span></div></div>');
  });

  it("renders class_count and sensors", function() {
    const material = {
      class_count: 0,
      sensors: ['foo', 'bar']
    };

    const result = renderStatic(SMaterialBodyClass, {material});
    expect(result).toBe('<div class="material_body"><div><i>Not used in any class.</i></div><div class="required_equipment_container"><span>Required sensor(s):</span><span style="font-weight:bold;">foo, bar</span></div></div>');
  });
});
