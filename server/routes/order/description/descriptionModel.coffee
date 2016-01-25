mongoose = require "mongoose"

schema = new mongoose.Schema
  order:
    type: mongoose.Schema.Types.ObjectId
    ref: "Order"
  text: [String]

module.exports = mongoose.model "Description", schema