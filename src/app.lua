local lapis = require("lapis")
local configuration = require("lapis.config").get()
local respond_to = require("lapis.application").respond_to
local app = lapis.Application()

app:get("/(*)", function(self)
	self:write({"Not Found", status = 404})
end)

-- Predict Endpoint
app:get("/predict", function(self)
	require("nn")
	require("torch")
	require("cutorch")
	require("cunn")
	require("cudnn")

	-- We'll read in the correct path later.
	local module = torch.load("TestModel.t7")
	module = module:cuda()
	module:evaluate()

	-- We'll read from POST later.
	local input = self.params.text or '';
	print(input)

	-- Process input --

	local alphabet = "abcdefghijklmnopqrstuvwxyz0123456789-,;.!?:'\"/\\|_@#$%^&*~`+-=<>()[]{}"
	local dict = {}
	for i = 1, #alphabet do
		dict[alphabet:sub(i,i)] = i
	end

	local data = torch.Tensor(1024, #alphabet) -- 1024 may be able to be done dynamicly.
	data:zero();

	for i = #input, math.max(#input - 1024 + 1, 1), -1 do
      if dict[input:sub(i,i)] then
         data[#input - i + 1][dict[input:sub(i,i)]] = 1;
      end
   	end

   	print(type(data))

	-- Predict --

	local prediction = module:forward(data)
	local confidences, indices = torch.sort(prediction, true)
	
	-- We'll make a nice output later, giving the labels not the label index.
	return {
		json = {
			one = confidences,
			two = indices
		}
	}

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
