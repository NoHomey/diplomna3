module.exports = ($translate, $scope, RESTHelperService, authenticationService) ->
  @$inject = ["$translate", "$scope", "RESTHelperService", "authenticationService"]

  controller = @

  controller.languages = ["bg", "en"]

  controller.current = $translate.use()

  init = ->

    getLanguage = ->
      RESTHelperService.language.find "id", (res) ->
        if res.language?
          controller.current = res.language
          $translate.use controller.current
          $scope.$digest()

    if authenticationService.isAuthenticated()
      getLanguage()

    stop = $scope.$on "authentication", getLanguage

    $scope.$on "$destroy", stop

  controller.change = (language) ->
    $translate.use language
    if authenticationService.isAuthenticated()
      RESTHelperService.language.change language: language, (res) ->

  init()

  controller
