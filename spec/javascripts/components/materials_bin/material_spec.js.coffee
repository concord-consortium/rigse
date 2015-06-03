#= require helpers/react_helper
#= require component

describe 'MBMaterialClass', ->
  beforeEach ->
    Portal.currentUser = {isTeacher: false, isAdmin: false}

  it 'renders material name and description', ->
    result = renderStatic MBMaterialClass, material: {name: 'name foobar', description: 'desc barfoo'}
    expect(result).toEqual jasmine.stringMatching 'name foobar'
    expect(result).toEqual jasmine.stringMatching 'desc barfoo'

  it 'renders preview link', ->
    result = renderStatic MBMaterialClass, material: {preview_url: 'http://run.activity'}
    expect(result).toEqual jasmine.stringMatching 'http://run.activity'

  it 'renders description toggle', ->
    result = renderStatic MBMaterialClass, material: {description: 'foobar'}
    expect(result).toEqual jasmine.stringMatching 'mb-toggle-info-text'

  it 'renders assign to class link only if user is a teacher', ->
    result = renderStatic MBMaterialClass, material: {}
    expect(result).not.toEqual jasmine.stringMatching 'mb-assign-to-class'

    Portal.currentUser.isTeacher = true
    result = renderStatic MBMaterialClass, material: {}
    expect(result).toEqual jasmine.stringMatching 'mb-assign-to-class'

  it 'renders assign to collection link only if user is a teacher', ->
    result = renderStatic MBMaterialClass, material: {}
    expect(result).not.toEqual jasmine.stringMatching 'mb-assign-to-collection'

    Portal.currentUser.isAdmin = true
    result = renderStatic MBMaterialClass, material: {}
    expect(result).toEqual jasmine.stringMatching 'mb-assign-to-collection'
