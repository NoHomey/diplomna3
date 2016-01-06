proxyquire = require "proxyquire"
proxyquire.noCallThru()

describe "loginHandle", ->

  req = handle = userModel = query = undefined

  send = sinon.spy()

  next = sinon.spy()

  sendSpy = sinon.spy()

  res = {}

  error = new Error()

  beforeEach ->

    send.reset()

    next.reset()

  describe "post", ->

    isAdmin = create = undefined

    req = body: user:
      email: "email@email"
      password: "password"

    id = "some id"

    before ->

      findOne = sinon.stub()

      findOne.onFirstCall().callsArgWith 1, error, null

      findOne.onSecondCall().callsArgWith 1, null, null

      findOne.callsArgWith 1, null, _id: id

      userModel = findOne: findOne

      create = sinon.stub()

      create.onFirstCall().returns
        then: (resolve, reject) ->
          reject error

      create.returns
        then: (resolve, reject) ->
          resolve()

      req.session = create: create

      isAdmin = sinon.stub()

      isAdmin.onFirstCall().returns
        then: (resolve, reject) ->
          reject error

      isAdmin.returns
        then: (resolve, reject) ->
          resolve {}

      handle = proxyquire "./../loginHandle",
        "./userModel": userModel
        "./admin/isAdmin": isAdmin
        "./../../lib/send": send

    it "passes down error from :findOne by calling next with error", ->

      handle.post req, res, next

      expect(next).to.have.been.calledWithExactly error

      expect(send).to.have.not.been.called

      expect(create).to.have.not.been.called

    it "sends login: false if none was found", ->

      handle.post req, res, next

      expect(send).to.have.been.calledWithExactly res, login: false

      expect(create).to.have.not.been.called

      expect(next).to.have.not.been.called

    it "passes down error from :create by calling next with error", ->

      handle.post req, res, next

      expect(next).to.have.been.calledWithExactly error

      expect(isAdmin).to.have.not.been.called

      expect(send).to.have.not.been.called

    it "passes down error from isAdmin by calling next with error", ->

      handle.post req, res, next

      expect(next).to.have.been.calledWithExactly error

      expect(send).to.have.not.been.called

    it "sends login: true and admin if there was no error", ->

      handle.post req, res, next

      expect(create).to.have.been.calledWithExactly uid: id

      expect(isAdmin).to.have.been.calledWithExactly id

      expect(send).to.have.been.calledWithExactly res, login: true, admin: {}

      expect(next).to.have.not.been.called

  describe "delete", ->

    before ->

      stub = sinon.stub()

      req = session: destroy: ->
        then: stub

      stub.onFirstCall().callsArg 0

      stub.onSecondCall().callsArgWith 1, error

      handle = proxyquire "./../loginHandle", "./../../lib/send": send

    it "sends if there is no error", ->

      handle.delete req, res, next

      expect(send).to.have.been.calledWithExactly res

      expect(next).to.have.not.been.called

    it "passes down error if there is error", ->

      handle.delete req, res, next

      expect(send).to.have.not.been.called

      expect(next).to.have.been.calledWithExactly error
