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
          handler collaborationParams
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
        return if element.hasClass('disabled')
        event.preventDefault()
        ccCollaborationSetup.start {offeringId: attrs.offeringId, jnlpUrl: attrs.jnlpUrl}
  ])


  #
  # Controllers
  #
  .controller('CollaborationController', ['$scope', '$http', '$log', 'ccCollaborationSetup', ($scope, $http, $log, ccCollaborationSetup) ->
    # Note that this methods lists and sets all the attributes (including public ones),
    # but perhaps shouldn't be used directly in HTML template.
    @_setDefaultState = ->
      @offeringId = null
      # If jnlpUrl is provided, it means we are configuring Java activity.
      @jnlpUrl = null
      @availableCollaborators = []
      @collaborators = []
      @currentCollaborator = null
      @currentPassword = null
      @runStarted = false
    #
    # Methods indented to be used by HTML template.
    #
    @isJavaActivity = ->
      !!@jnlpUrl

    @setActive = (v) ->
      $scope.active = !!v

    @addCollaborator = ->
      @collaborators.push {id: @currentCollaborator.id, name: @currentCollaborator.name, password: @currentPassword}
      @_cleanupCurrentCollaborator()

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
        students: @collaborators.map (c) -> {id: c.id}
      }
      @runStarted = true
      @_createCollaboration params
    #
    # Private methods
    #
    @_cleanupCurrentCollaborator = ->
      idx = @availableCollaborators.indexOf @currentCollaborator
      return if idx == -1
      @availableCollaborators.splice idx, 1
      @currentCollaborator = null
      @currentPassword = null

    @_loadCollaborators = ->
      url = Portal.API_V1.AVAILABLE_COLLABORATORS
      params = {offering_id: @offeringId}
      $http({method: 'GET', url: url, params: params})
        .success (data, status, headers, config) =>
          @availableCollaborators = data
        .error (data, status) =>
          $log.log "Error loading available collaborators"

    @_createCollaboration = (params) ->
      $http.post(Portal.API_V1.COLLABORATIONS, params)
        .success (data, status, headers, config) =>
          @_collaborationCreated data
        .error (data, status) =>
          $log.log "Error creating collaboration"

    @_collaborationCreated = (data) ->
      if @isJavaActivity()
        @_startRunStatus()
        newUrl = @jnlpUrl
      else
        newUrl = data.external_activity_url
      # Close the dialog.
      @setActive false
      # Finally redirect.
      window.location.href = newUrl

    @_startRunStatus = ->
      # It's not really pretty, but let's us reuse old RunStatus code.
      # Its constructor expects main button element (in fact one with ccSetupCollaboration
      # directive) as an argument. See: runnables_helper.rb and run_status.js.coffee.
      mainBtnElement = jQuery("[data-offering-id=#{@offeringId}]")[0]
      runStatus = new OfferingRunStatus(mainBtnElement)
      runStatus.toggleRunStatusView()
      runStatus.trigger_status_updates()

    #
    # Initialization
    #
    ccCollaborationSetup.onStart (params) =>
      # This handler is executed when a button with ccSetupCollaboration directive is clicked.
      @_setDefaultState()
      @offeringId = params.offeringId
      @jnlpUrl = params.jnlpUrl
      @_loadCollaborators()
      $scope.$apply =>
        @setActive true

    $scope.active = false
    @_setDefaultState()
  ])
