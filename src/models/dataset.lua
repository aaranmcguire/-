local Model = require("lapis.db.model").Model

return Model:extend("FiberDatasets", {
  relations = {
    { "FiberTrainingSessions", has_many = "TrainingSessions" }
  }
})