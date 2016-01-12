describe "registerService", ->

  tested = require "./../registerService"

  registerService = showDialogService = loginService = undefined

  event = {}

  extend = {}

  beforeEach ->

    showDialogService = showDialog: jasmine.createSpy()

    loginService = jasmine.createSpy()

    registerService = tested showDialogService, loginService

  it "should make a proper call to showDialog", ->

    locals = {}

    handle = success: jasmine.any Function

    registerService event, extend

    expect(showDialogService.showDialog).toHaveBeenCalledWith event, "register", locals, handle, extend

  it "should open login dialog on success", ->

    showDialogService.showDialog.and.callFake (evnt, dlg, lcls, hndl, extnd) ->
      hndl.success()

    registerService event, extend

    expect(loginService).toHaveBeenCalledWith event
