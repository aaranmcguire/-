local lapis = require("lapis")
local configuration = require("lapis.config").get()
local respond_to = require("lapis.application").respond_to
local app = lapis.Application()

app:get("/(*)", function(self)
	self:write({"Not Found", status = 404})
end)

-- Predict Endpoint
app:get("/predict", function(self)
	-- local require("")
	self:write({"Not Found", status = 404})

end)

-- Dataset Endpoints
app:match("/dataset(/:id)", respond_to({
	before = function(self)
		if type(self.params.id) ~= null then
			self.dataset = Dataset:find(self.params.id)
			if not self.dataset then
				self:write({"Not Found", status = 404})
			end
		end
	end,
	GET = function(self)
		-- Return all datasets or single dataset.
	end,
	POST = function(self)
		-- Create new dataset.
	end,
	DELETE = function(self)
		-- Delete dataset.
	end
}))

-- Training Endpoints
app:match("/train(/:id)", respond_to({
	before = function(self)
		if type(self.params.id) ~= null then
			self.dataset = Dataset:find(self.params.id)
			if not self.dataset then
				self:write({"Not Found", status = 404})
			end
		end
	end,
	GET = function(self)
		-- Return all Training Sessions or single Training Session.
	end,
	POST = function(self)
		-- Create new Training Session.
	end,
	DELETE = function(self)
		-- Delete Training Session.
	end
}))


return app
