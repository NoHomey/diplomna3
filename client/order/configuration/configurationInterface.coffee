controller = ($controller, $scope, $q, RESTHelperService, simpleDialogService, progressService, confirmService) ->

  ctrl = $controller "baseInterface",
    "$scope": $scope
    "$q": $q
    "RESTHelperService": RESTHelperService
    "simpleDialogService": simpleDialogService
    "progressService": progressService
    "confirmService": confirmService
    "link": "configuration"
    "settings": @settings
    "exclude": []
    "awaiting": ["view"]

  textPosition = ->
    options = []
    directionX = ["left", "right", "center"]
    directionY = ["top", "bottom", "center"]
    for y in directionY
      for x in directionX
        options.push "#{y}-#{x}"
    options.pop()
    options

  textAngle = (position = "") ->
    if position.match /center-/
      return ["left", "right"]
    if position.match /-center/
      return ["bottom", "top"]
    ["left", "right", "bottom", "top"]

  listen = ->

    RESTHelperService.template.fetch "top.html", (res) -> ctrl.view = res

    stop = $scope.$on "configuration-validity", (event, value) ->
      ctrl.valid = [value]

    $scope.$on "$destroy", stop

  ctrl.btnBack = no

  ctrl.text = "Text"

  ctrl.options =
    side: ["pcb-side", "squeegee-side"]
    textPosition: textPosition()
    textAngle: textAngle()

  ctrl.changeStencilTransitioning = ->
    if not ctrl.configurationObject.stencil?
      ctrl.configurationObject.style.frame = no
    else
      ctrl.configurationObject.style.frame = (ctrl.configurationObject.stencil.transitioning.match /frame/)?

  ctrl.textAngle = textAngle

  ctrl.changeText = (text) ->
    color = "pcb-side"
    angle = ""
    def = "text-top-left-left"
    text = ctrl.configurationObject.text
    if not text?
      ctrl.configurationObject.style.text = color: color, view: def
      return
    if text.type is "engraved" and text.side
      color = text.side
    if text.type is "drilled"
      color = text.type
    if not text.position?
      ctrl.configurationObject.style.text = color: color, view: def
      return
    if text.angle in ctrl.options.textAngle
      angle = text.angle
    else
      angle = ctrl.options.textAngle[0]
    ctrl.configurationObject.style.text =
      color: color
      view: ["text", text.position, angle].join "-"

  ctrl.changeStencilPosition = ->
    if not ctrl.configurationObject.position?
      ctrl.configurationObject.style.outline = no
      ctrl.configurationObject.style.layout = no
      ctrl.configurationObject.style.mode = "portrait-centered"
    else
      aligment = ctrl.configurationObject.position.aligment ? "portrait"
      position = ctrl.configurationObject.position.position
      mode = ""
      if position isnt "pcb-centered"
        ctrl.configurationObject.style.outline = no
        ctrl.configurationObject.style.layout = position is "layout-centered"
        if ctrl.configurationObject.style.layout
          mode = "centered"
        else mode = "no"
        ctrl.configurationObject.style.mode = [aligment, mode].join "-"
      else
        ctrl.configurationObject.style.outline = yes
        ctrl.configurationObject.style.layout = no
        ctrl.configurationObject.style.mode = [aligment, "centered"].join "-"

  ctrl.change = ->
    if not ctrl.configurationObject.style? then ctrl.configurationObject.style = {}

  listen()

  ctrl

controller.$inject = ["$controller", "$scope", "$q", "RESTHelperService", "simpleDialogService", "progressService", "confirmService"]

module.exports = controller
