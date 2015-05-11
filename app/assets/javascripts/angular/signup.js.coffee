angular.module('ccSignup', ['ccSignupDirectives', 'ui.select', 'ui.validate', 'ngMessages'])
  .controller 'RegistrationController', [ '$scope', '$http', '$log', 'errorList', 'gaPageView', ($scope, $http, $log, errorList, gaPageView) ->
    self = @
    self.questions = []          # these are the ones the student has chosen
    self.answers   = []          # these are the ones the student has chosen
    self.security_questions = [] # these are given to us from the server
    self.serverErrors = errorList.list
    self.editSchool = false

    self.addError = () ->
      errorList.addError('first_name',self.last_name,'message')

    self.loadCountries = () ->
      callback = () ->
        jQuery('input[placeholder], textarea[placeholder]').placeholder()
        
      self.loadRemoteCollection('countries', {}, callback)

    self.loadStates = () ->
      self.loadRemoteCollection('states')

    self.loadSecurityQuestions = () ->
      callback = () ->
        jQuery('input[placeholder], textarea[placeholder]').placeholder()
      
      self.loadRemoteCollection('security_questions', {}, callback)

    self.loadDisrticts = () ->
      params = { state: self.state }
      self.loadRemoteCollection('districts',params)

    self.loadSchools = (success_fn = null) ->
      if self.isDomestic()
        self.loadDomesticSchools(success_fn)
      else
        self.loadIntlSchools(success_fn)

    self.loadDomesticSchools = (success_fn = null) ->
      params = { district_id : self.district.id }
      self.loadRemoteCollection('schools',params, success_fn)

    self.loadIntlSchools = (success_fn = null) ->
      params = { country_id : self.country.id }
      self.loadRemoteCollection('schools',params, success_fn)

    self.countrySelected = () ->
      if self.isDomestic()
        self.loadStates()
      else
        self.loadSchools()
      delete self.state
      delete self.district
      delete self.school

    self.stateSelected = () ->
      if self.isDomestic()
        self.loadDisrticts()
        delete self.district
        delete self.school

    self.districtSelected = () ->
      if self.isDomestic()
        self.loadDomesticSchools()
      delete self.school

    self.loadRemoteCollection = (collectionName, params={}, success_fn=null) ->
      url = Portal.API_V1[collectionName.toUpperCase()]
      $http({method: 'GET', url: url, params: params})
      .success (data, status, headers, config) ->
        $log.log("loaded #{collectionName} collection from #{url}")
        self[collectionName] = data
        if success_fn
          success_fn()
      .error (data, status) ->
        $log.log "Error loading #{collectionName} collection"
        self[collectionName] || =[]

    self.postToResource = (resourceName, data={}, successCall, failCall) ->
      url = Portal.API_V1[resourceName.toUpperCase()]
      $http({method: 'POST', url: url, data: data})
      .success (data, status, headers, config) ->
        $log.log("added #{resourceName} to #{url}")
        self[resourceName] = data
        successCall(data) if successCall
      .error (data, status) ->
        $log.log "Error posting #{resourceName} collection"
        errrorfields = data.message
        self.errors = []
        for item of errrorfields
          $log.log("Error in #{item}")
          errorList.addError(item, self[item], errrorfields[item])
        failCall(data) if failCall

    self.uniqueQuestions = (value) ->
      return true unless value && value.length > 0
      self.questions.indexOf(value) == -1 ? true : false

    self.schoolValid = () ->
      self.school ?= {}
      if self.isDomestic()
        return self.school.name && self.school.name.length > 0
      for school_prop in [self.school.name, self.state, self.school.city]
        return false unless school_prop && school_prop.length > 0
      return true

    self.readyToRegister = () ->
      (self.first_name && self.last_name && self.password_confirmation && self.registrationType)

    self.sendRegistration = () ->
      resource = "#{self.registrationType}s"
      self.postToResource resource, self.form_params(), (data) ->
        self.did_finish = true
        # copy data into this controller
        for field of data
          self[field] = data[field]
        gaPageView.push("/thanks_for_sign_up/#{self.registrationType}/")
        
    self.sendSchool = () ->
      resource = "schools"
      data =
        school_name: self.school.name
        country_id: self.country.id
        state: self.state
        city: self.school.city

      data['district_id']  = self.district.id if self.district

      self.postToResource resource, data, (returnData) ->
        id = returnData['school_id']

        self.loadSchools () ->
          for school in self.schools
            if school.id == id
              self.school = school
          self.editSchool = false


    self.form_params = () ->
      data = {
        'first_name': self.first_name
        'last_name':  self.last_name
        'password':   self.password
        'password_confirmation': self.password_confirmation
        'email': self.email
        'login': self.login
        'class_word': self.class_word
        'answers': self.answers
        'questions': self.questions
      }
      if self.school
        data['school_id'] = self.school.id
      return data


    self.startRegistration = () ->
      self.didStartRegistration = true
      self.loadCountries() if self.registrationType == "teacher"
      self.loadSecurityQuestions() if self.registrationType == "student"
      gaPageView.push("/begin_sign_up/#{self.registrationType}/")

    self.nowShowing = () ->
      return "page1" unless self.didStartRegistration
      return "success" if self.did_finish
      return self.registrationType

    self.isInternational= () ->
      !self.isDomestic()

    self.isDomestic = () ->
      return false unless self.country
      return false unless self.country.name == "United States"
      return true

    self.showState = () ->
      return self.isDomestic()

    self.showDistrict = () ->
      self.showState() && self.state

    self.showSchool = () ->
      return false unless self.country
      (self.showDistrict() && self.district) || (! self.isDomestic())

    self.disableSubmit = (form_valid) ->
      return true if self.editSchool
      return !form_valid

    self.setEditSchool = () ->
      self.editSchool = true

    self.setPickSchool = () ->
      self.editSchool = false

    # how are we getting school info?
    self.schoolEditmode = () ->
      if self.editSchool
        # full form US version
        return "us_edit" if self.isDomestic()
        # for form internation version
        jQuery('input[placeholder], textarea[placeholder]').placeholder();
        return "intl_edit"
      else
        return "dropdown"
  ]

