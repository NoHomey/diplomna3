module.exports = ($scope, simpleDialogService, RESTHelperService, infoOnlyService) ->
  controller = @
  controller.$inject = ["$scope", "simpleDialogService", "RESTHelperService", "infoOnlyService"]
  controller.invalid = []

  controller.listen = ->
    stop = $scope.$on "address-validity", (event, wich, value) ->
      index = -1
      switch wich
        when "delivery" then index = 0
        when "invoice" then index = 1
        when "firm" then index = 2
      controller.invalid[index] = value
    $scope.$on "$destroy", stop

  controller.getAddresses = ->
    RESTHelperService.addresses.find (res) ->
      if res.success
        controller.listOfAddresses = res.addresses

  controller.reset = ->
    controller.information =
      delivery: {}
      invoice: {}
      firm: {}
    controller.disabled = false
    controller.action = "create"

  controller.choose = ->
    controller.disabled = true
    controller.action = "preview"
    controller.information = controller.listOfAddresses[controller.address]

  controller.save = ->
    RESTHelperService.addresses.create addresses: (infoOnlyService controller.information), (res) ->
      if res.success then controller.information._id = res._id

  controller.fill = (dst, src) ->
    info = [
      "country"
      "city"
      "postcode"
      "address1"
      "address2"
      "firstname"
      "lastname"
    ]
    for key in info
      controller.information[src][key] =  controller.information[dst][key]

  controller.listen()

  controller
