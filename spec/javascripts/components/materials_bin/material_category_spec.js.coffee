#= require helpers/react_helper
#= require component

describe 'MBMaterialsCategoryClass', ->
  beforeEach ->
    Portal.currentUser = {isAnonymous: true}

  describe 'when loginRequired property is set to true', ->
    it 'should be hidden for anonymous user', ->
      result = renderStatic MBMaterialsCategoryClass, visible: true, loginRequired: true
      expect(result).toEqual jasmine.stringMatching 'mb-hidden'

    it 'should be visible for logged in user', ->
      Portal.currentUser.isAnonymous = false
      result = renderStatic MBMaterialsCategoryClass, visible: true, loginRequired: true
      expect(result).not.toEqual jasmine.stringMatching 'mb-hidden'

  describe 'when loginRequired property is set to false', ->
    it 'should be visible for anonymous user', ->
      result = renderStatic MBMaterialsCategoryClass, visible: true
      expect(result).not.toEqual jasmine.stringMatching 'mb-hidden'

    it 'should be visible for logged in user', ->
      Portal.currentUser.isAnonymous = false
      result = renderStatic MBMaterialsCategoryClass, visible: true, loginRequired: false
      expect(result).not.toEqual jasmine.stringMatching 'mb-hidden'
