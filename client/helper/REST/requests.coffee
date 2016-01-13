crud =
  alias: ["find", "create", "delete", "update"]
  method: ["get", "post", "delete", "patch"]
  arg: [no, yes, yes, yes]

module.exports =

  user:
    alias: ["email", "register", "profile"]
    method: ["get", "post", "patch"]
    arg: (yes for i in [0..2])

  login:
    alias: ["logged", "login", "logout"]
    method: ["get", "post", "delete"]
    arg: [no, yes, no]

  config: crud

  addresses: crud

  order:
    alias: ["create", "find", "view"]
    method: ["get", "post", "put"]
    arg: [yes, no, yes]

  upload: ["preview", "order"]