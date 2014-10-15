angular.module('ccCollaboration', ['ui.select'])
  #
  # Services
  #
  # This service is used for communication between ccSetupCollaboration directive and CollaborationController.
  .service('ccCollaborationSetup', ->
    handlers = []
    {
      # publish
      start: (collaborationParams) ->
        angular.forEach handlers, (handler) ->
          handler(collaborationParams)
      # subscribe
      onStart: (handler) ->
        handlers.push handler
    }
  )
  #
  # Directives
  #
  # This directive is used to start collaboration setup. Note that offering-id attribute is required, e.g.:
  # <a cc-setup-collaboration data-offering-id="23"></a>
  .directive('ccSetupCollaboration', ['ccCollaborationSetup', (ccCollaborationSetup) ->
    restrict: 'A'
    link: ($scope, element, attrs) ->
      element.on 'click', (event) ->
        event.preventDefault()
        ccCollaborationSetup.start offeringId: attrs.offeringId
  ])
  # Validates students password, note that ID of the student should be provided, e.g.:
  # <input type="password" cc-good-student-password="123">
  .directive('ccStudentPassword', ['$http', ($http) ->
    require: 'ngModel',
    scope:
      ccStudentPassword: '='
    link: ($scope, element, attrs, ngModel) ->
      $scope.$watch 'ccStudentPassword', (pass) ->
        ngModel.$asyncValidators.goodStudentPassword = (password) ->
          # Note that $scope.ccStudentPassword is equal to student ID.
          $http.post(API_V1.STUDENT_CHECK_PASSWORD.replace(999, $scope.ccStudentPassword), {password: password})
  ])
  #
  # Controllers
  #
  .controller('CollaborationController', ['$scope', '$http', '$log', 'ccCollaborationSetup', ($scope, $http, $log, ccCollaborationSetup) ->
    ccCollaborationSetup.onStart (params) =>
      @setDefaultState()
      @offeringId = params.offeringId
      @loadCollaborators()
      $scope.$apply =>
        @setActive true

    @setDefaultState = ->
      @offeringId = null
      @availableCollaborators = []
      @collaborators = []
      @currentCollaborator = null
      @currentPassword = null
      @runStarted = false

    @cleanupCurrentCollaborator = ->
      idx = @availableCollaborators.indexOf @currentCollaborator
      return if idx == -1
      @availableCollaborators.splice idx, 1
      @currentCollaborator = null
      @currentPassword = null

    @setActive = (v) ->
      $scope.active = !!v

    @addCollaborator = ->
      @collaborators.push {id: @currentCollaborator.id, name: @currentCollaborator.name, password: @currentPassword}
      @cleanupCurrentCollaborator()

    @removeCollaborator = (collaborator) ->
      # Remove from currently selected collaborators.
      idx = @collaborators.indexOf collaborator
      return if idx == -1
      @collaborators.splice idx, 1
      # Add to available collaborators.
      delete collaborator.password
      @availableCollaborators.push collaborator

    @readyToRun = ->
      @collaborators.length > 0 && !@runStarted

    @run = ->
      params = {
        offering_id: @offeringId
        # Skip name attribute, it's not necessary.
        students: @collaborators.map (c) -> {id: c.id, password: c.password}
      }
      @runStarted = true
      $http.post(API_V1.COLLABORATIONS, params)
        .success (data, status, headers, config) =>
          # Redirect and close this dialog
          window.location.href = data.external_activity_url
        .error (data, status) =>
          $log.log "Error creating collaboration"

    @loadCollaborators = ->
      url = API_V1.AVAILABLE_COLLABORATORS
      params = {offering_id: @offeringId}
      $http({method: 'GET', url: url, params: params})
        .success (data, status, headers, config) =>
          @availableCollaborators = data
        .error (data, status) =>
          $log.log "Error loading available collaborators"

    # Initialization:
    $scope.active = false
    @setDefaultState()
  ])
