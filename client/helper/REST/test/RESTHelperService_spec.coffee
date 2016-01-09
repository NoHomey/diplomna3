tested = require "./../RESTHelperService"

describe "RESTHelperService", ->

  request = REST = RESTHelperService = uploadService = undefined

  data = someData: "data"

  email = "email@email"

  callback = jasmine.createSpy()

  beforeEach ->

    resolve = (callback) ->
      callback
        statusCode: 200
        data: data

    request = jasmine.createSpy()

    request.and.callFake (send) ->
      then: resolve

    REST = jasmine.createSpy()

    REST.and.callFake (rest) ->
      get: request
      post: request
      put: request
      delete: request
      patch: request

    uploadService = jasmine.createSpy()

    uploadService.and.callFake (upload) ->
      request

    RESTHelperService = tested REST, uploadService

  describe "all request makers", ->

    it "creates restfull 'apis'", ->

      for called in ["login", "user", "config", "addresses", "order"]

        expect(REST).toHaveBeenCalledWith called

    it "creates file uploaders", ->

      for called in ["preview", "order"]
        expect(uploadService).toHaveBeenCalledWith called

  describe "RESTHelperService.upload.[]", ->

    files = ["file1", "file2"]

    run = (test) ->

      it "uploads files for #{test}", ->

        RESTHelperService.upload[test] files, callback

        expect(request).toHaveBeenCalledWith files

        expect(callback).toHaveBeenCalled()

    run test for test in ["preview", "order"]

  describe "RESTHelperService.email", ->

    it "checks if email is taken", ->

      RESTHelperService.email email, callback

      expect(request).toHaveBeenCalledWith email

      expect(callback).toHaveBeenCalled()

  describe ".register, .login and .profile", ->

    user =
      email: email
      password: "password"

    run = (test) ->

      describe "RESTHelperService.#{test}", ->

        message = "#{test} a new user"

        if test is "profile"
          message = "changes user's email/password"

        it message, ->

          RESTHelperService[test] user , callback

          expect(request).toHaveBeenCalledWith user

          expect(callback).toHaveBeenCalled()

    run test for test in ["register", "login", "profile"]

  testLog = (log) ->

    describe "RESTHelperService.#{log}", ->

      message = "checks if a user is currrently logged (for session)"

      if log is "logout"
        message = "logouts a user (destroies session)"

      it message, ->

        RESTHelperService[log] callback

        expect(callback).toHaveBeenCalled()

  testLog log for log in ["logged", "logout"]

  testWhat = (what, tests) ->

    describe "RESTHelperService.#{what}.[]", ->

      wich = what

      if wich is "config" then wich += "urations"

      run = (test) ->

        if test is "find"

          it "gets all user related #{wich}", ->

            RESTHelperService[what].find callback

            expect(callback).toHaveBeenCalled()

        else

          it "#{test}s #{wich}", ->

            RESTHelperService[what][test] {}, callback

            expect(request).toHaveBeenCalledWith {}

            expect(callback).toHaveBeenCalled()

      run test for test in tests

  testWhat what, ["create", "find", "delete", "update"] for what in ["config", "addresses"]

  testWhat "order", ["create", "find", "view"]