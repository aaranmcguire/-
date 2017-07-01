local schema = require "lapis.db.schema"
local types = schema.types

return {
	[1] = function()
		schema.create_table("FiberDatasets", {
			{"id", types.text};
			{"name", types.text};
			{"type", types.integer}; -- 1 = Training; 2 = Validation
			{"data_location", types.text};
			{"alphabet", types.text};
			{"max_length", types.integer};
			{"created_at", schema.types.time};
			{"updated_at", schema.types.time};

			"PRIMARY KEY (id)";
		})
	end;

	[2] = function()
		schema.create_table("FiberTrainingSessions", {
			{"id", types.text};
			{"name", types.text};
			{"dataset", types.text}; -- Link to Dataset.
			{"status", types.integer};
			{"model_location", types.text};
			{"created_at", schema.types.time};
			{"updated_at", schema.types.time};

			"PRIMARY KEY (id)";
		})
	end;
}