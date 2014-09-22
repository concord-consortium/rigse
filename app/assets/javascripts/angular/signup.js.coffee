angular.module("registrationApp", ["ccDirectives",'ui.select','ui.validate', "ngMessages"])
  .controller "RegistrationController", [ '$scope', '$http', '$log', 'errorList',  ($scope, $http, $log, errorList) ->
    self = @
    self.questions = []          # these are the ones the student has chosen
    self.security_questions = [] # these are given to us from the server
    self.serverErrors = errorList.list
    
    self.addError = () ->
      errorList.addError('first_name',self.last_name,'message')

    self.loadCountries = () ->
      self.loadRemoteCollection('countries')

    self.loadStates = () ->
      self.loadRemoteCollection('states')

    self.loadSecurityQuestions = () ->
      self.loadRemoteCollection('security_questions')

    self.loadDisrticts = () ->
      params = { state: self.state }
      self.loadRemoteCollection('districts',params)

    self.loadDomesticSChools = () ->
      params = { district_id : self.district.id }
      self.loadRemoteCollection('schools',params)

    self.loadIntlSchools = () ->
      params = { country_id : self.country.id }
      self.loadRemoteCollection('schools',params)

    self.countrySelected = () ->
      if self.isDomestic()
        self.loadStates()
      else
        self.loadIntlSchools()

    self.stateSelected = () ->
      if self.isDomestic()
        self.loadDisrticts()

    self.districtSelected = () ->
      if self.isDomestic()
        self.loadDomesticSChools()

    self.loadRemoteCollection = (collectionName, params={}) ->
      url = API_V1[collectionName.toUpperCase()]
      $http({method: 'GET', url: url, params: params})
      .success (data, status, headers, config) ->
        $log.log("loaded #{collectionName} collection from #{url}")
        self[collectionName] = data

      .error (data, status) ->
        $log.log "Error loading #{collectionName} collection"
        self[collectionName] || =[]

    self.postToResource = (resourceName, data={}, successCall, failCall) ->
      url = API_V1[resourceName.toUpperCase()]
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

    self.readyToRegister = () ->
      (self.first_name && self.last_name && self.password_confirmation && self.registrationType)

    self.sendRegistration = () ->
      resource = "#{self.registrationType}s"
      self.postToResource resource, self.form_params(), (data) ->
        self.did_finish = true
        # copy data into this controller
        for field of data
          self[field] = data[field]

    self.form_params = () ->
      return {
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

    self.startRegistration = () ->
      self.didStartRegistration = true
      self.loadCountries() if self.registrationType == "teacher"
      self.loadSecurityQuestions() if self.registrationType == "student"

    self.nowShowing = () ->
      return "page1" unless self.didStartRegistration
      return "success" if self.did_finish
      return self.registrationType

    self.isDomestic = () ->
      return false unless self.country
      self.country.id == API_V1.USA_ID
    
    self.showState = () ->
      self.isDomestic()

    self.showDistrict = () ->
      self.showState() && self.state

    self.showSchool = () ->
      return false unless self.country
      (self.showDistrict() && self.district) || (! self.isDomestic())
  ]