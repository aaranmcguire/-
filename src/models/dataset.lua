local Model = require("lapis.db.model").Model

return Model:extend("FiberDatasets", {
	timestamp = true,
	relations = {
		{ "FiberTrainingSessions", has_many = "TrainingSessions" }
	}
})