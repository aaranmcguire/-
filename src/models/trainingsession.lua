local Model = require("lapis.db.model").Model

return Model:extend("FiberTrainingSessions", {
	timestamp = true,
	relations = {
		{ "FiberDatasets", belongs_to = "Datasets" }
	}
})