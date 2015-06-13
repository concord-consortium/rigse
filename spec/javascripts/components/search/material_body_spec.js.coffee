#= require helpers/react_helper
#= require components/search/material_body

describe 'SMaterialBodyClass', ->

  it "renders an empty div with no material class_count or sensors", ->
    result = renderStatic SMaterialBodyClass, {material: {}}
    expect(result).toBe '<div class="material_body"></div>'

  it "renders only the class count with a material class_count and no sensors", ->
    material = class_count: 0
    zeroResult = renderStatic SMaterialBodyClass, {material: material}
    expect(zeroResult).toBe '<div class="material_body"><div><i>Not used in any class.</i></div></div>'

    material.class_count = 1
    singleResult = renderStatic SMaterialBodyClass, {material: material}
    expect(singleResult).toBe '<div class="material_body"><div><i>Used in 1 class.</i></div></div>'

    material.class_count = 2
    multipleResult = renderStatic SMaterialBodyClass, {material: material}
    expect(multipleResult).toBe '<div class="material_body"><div><i>Used in 2 classes.</i></div></div>'

  it "renders only sensors", ->
    material = sensors: ['foo', 'bar']

    result = renderStatic SMaterialBodyClass, {material: material}
    expect(result).toBe '<div class="material_body"><div class="required_equipment_container"><span>Required sensor(s):</span><span style="font-weight:bold;">foo, bar</span></div></div>'

  it "renders class_count and sensors", ->
    material =
      class_count: 0
      sensors: ['foo', 'bar']

    result = renderStatic SMaterialBodyClass, {material: material}
    expect(result).toBe '<div class="material_body"><div><i>Not used in any class.</i></div><div class="required_equipment_container"><span>Required sensor(s):</span><span style="font-weight:bold;">foo, bar</span></div></div>'
