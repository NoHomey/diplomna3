describe "sendFileMiddleware", ->
    sendFileMiddleware = join = req = res = undefined

    beforeEach ->
        proxyquire = require "proxyquire"
        join = sinon.stub()
        req = {}
        res =
            set: sinon.spy()
            status: sinon.stub()
            sendFile: sinon.spy()
        sendFileMiddleware = proxyquire "./../sendFileMiddleware", "path": join: join
        res.status.returns res

    it "sends a file from a given directory", ->
        dir = sendFileMiddleware "./test"
        join.returns "./test/test.html"
        middleware = dir "test.html"
        middleware req, res
        (expect res.set).to.have.been.calledWithExactly "Content-Encoding", "gzip"
        (expect res.status).to.have.been.calledWithExactly 200
        (expect res.sendFile).to.have.been.calledWithExactly "./test/test.html"

    it "shouldn't set \"Content-Encoding\" header if gzip argument is false", ->
        dir = sendFileMiddleware "./test", no
        join.returns "./test/test.html"
        middleware = dir "test.html"
        middleware req, res
        (expect res.set).to.have.not.been.calledWithExactly "Content-Encoding", "gzip"

    it "should override \"Content-Type\" header with \"text/html\" if deduc is false", ->
        dir = sendFileMiddleware "./test"
        join.returns "./test/test.html"
        middleware = dir "test.html", no
        middleware req, res
        (expect res.sendFile).to.have.been.calledWithExactly "./test/test.html", headers: "Content-Type": "text/html"
