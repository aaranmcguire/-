local Model = require("lapis.db.model").Model

return Model:extend("FiberTrainingSessions", {
  relations = {
    { "FiberDatasets", belongs_to = "Datasets" }
  }
})