{ Vows, assert, brains, Browser } = require("./helpers")
SSE = require("sse")

Vows.describe("EventSource").addBatch

  "":
    topic: ->
      sse_server = new SSE(brains)
      sse_server.on "connection", (client)->
        client.send "Hello"

    "creating":
      topic: ->
        brains.get "/sse/creating", (req, res)->
          res.send """
          <html>
            <head>
              <script src="/jquery.js"></script>
            </head>
            <body>
              <span id="es-url"></span>
            </body>
            <script>
              $(function() {
                es = new EventSource('http://localhost:3003');
                $('#es-url').text(es.url);
              });
            </script>
          </html>
          """
        browser = new Browser
        browser.wants "http://localhost:3003/sse/creating", @callback
      "should be possible": (browser)->
        assert.equal browser.text("#es-url"), "http://localhost:3003"

    "connecting":
      topic: ->
        brains.get "/sse/connecting", (req, res)->
          res.send """
          <html>
            <head></head>
            <body></body>
            <script>
              es = new EventSource('http://localhost:3003');
              es.onopen = function() {
                alert('open');
              };
            </script>
          </html>
          """
        done = @callback
        browser = new Browser()
        browser.onalert (message)->
          done null, browser
        browser.wants "http://localhost:3003/sse/connecting"
      "should raise an event": (browser)->
        assert.ok browser.prompted("open")

    "message":
      topic: ->
        brains.get "/sse/message", (req, res)->
          res.send """
          <html>
            <head></head>
            <body></body>
            <script>
              es = new EventSource('http://localhost:3003');
              es.onmessage = function(message) {
                alert(message.data);
              };
            </script>
          </html>
          """
        done = @callback
        browser = new Browser()
        browser.onalert (message)->
          done null, browser
        browser.wants "http://localhost:3003/websockets/message"
      "should raise an event with correct data": (browser)->
        assert.ok browser.prompted("Hello")

    "closing":
      topic: ->
        brains.get "/sse/closing", (req, res)->
          res.send """
          <html>
            <head></head>
            <body></body>
            <script>
              es = new WebSocket('http://localhost:3003');
              es.onclose = function() {
                alert('close');
              };
              es.close();
            </script>
          </html>
          """
        done = @callback
        browser = new Browser()
        browser.onalert (message)->
          done null, browser
        browser.wants "http://localhost:3003/websockets/closing"
      "should raise an event": (browser)->
        assert.ok browser.prompted("close")


.export(module)
