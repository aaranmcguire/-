local lapis = require("lapis")
local configuration = require("lapis.config").get()
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local util = require("lapis.util")
local encoding = require("lapis.util.encoding")
local app = lapis.Application()

-- Models
local Dataset = require("models/dataset")
local TrainingSession = require("models/trainingsession")

-- Predict Endpoint
app:get("/predict", function(self)
	local nn = require("nn")
	local torch = require("torch")
	local cutorch = require("cutorch")
	local cunn = require("cunn")
	local cudnn = require("cudnn")

	-- We'll read in the correct path later.
	local module = torch.load("TestModel.t7")
	module = module:cuda()
	module:evaluate()

	-- We'll read from POST later.
	local input = self.params.text:lower() or '';

	-- Process input --
	local alphabet = "abcdefghijklmnopqrstuvwxyz0123456789-,;.!?:'\"/\\|_@#$%^&*~`+-=<>()[]{}"
	local dict = {}
	for i = 1, #alphabet do
		dict[alphabet:sub(i,i)] = i
	end

	local data = torch.Tensor(#input, #alphabet):zero() -- 1024 may be able to be done dynamicly.

	for i = #input, math.max(#input - #input + 1, 1), -1 do
      if dict[input:sub(i,i)] then
         data[#input - i + 1][dict[input:sub(i,i)]] = 1;
      end
   	end

	-- Predict --
	local prediction = module:forward(data:cuda())
	local confidences, indices = torch.sort(prediction, true)

	module = nil;
	data = nil;
	collectgarbage();

	-- We'll make a nice output later, giving the labels not the label index.
	return {
		json = {
			-- ["confidences"] = (100 - math.max(confidences[1],1))/100,
			["prediction"] = indices[1]
		}
	}
end)

-- Dataset Endpoints
app:match("/dataset(/:id)", respond_to({
	before = function(self)
		if self.params.id then
			self.dataset = Dataset:find(self.params.id)
			if not self.dataset then
				self:write({"Not Found", status = 404})
			end
		end
	end,
	GET = function(self)
		-- Return all datasets or single dataset.
		return {
			json = {
				["Result"] = self.dataset or Dataset:select(nil)
			}
		}
	end,
	POST = json_params(function(self)
		-- Create new dataset.
		return {
			json = {
				Dataset:create({
					["id"] = encoding.encode_base64(os.time() .. self.params.name),
					["name"] = self.params.name,
					["type"] = self.params.type,
					["data_location"] = self.params.data_location,
					["alphabet"] = self.params.alphabet,
					["max_length"] = self.params.max_length
				});
			}
		}
	end),
	DELETE = function(self)
		-- Delete dataset.
		self.dataset:delete()
	end
}))

-- Training Endpoints
app:match("/train(/:id)", respond_to({
	before = function(self)
		if self.params.id then
			self.dataset = TrainingSession:find(self.params.id)
			if not self.dataset then
				self:write({"Not Found", status = 404})
			end
		end
	end,
	GET = function(self)
		-- Return all Training Sessions or single Training Session.
		return {
			json = {
				["Result"] = self.dataset or TrainingSession:select(nil)
			}
		}
	end,
	POST = json_params(function(self)
		-- Create new Training Session.
		return {
			json = {
				Dataset:create({
					["id"] = encoding.encode_base64(os.time() .. self.params.name),
					["name"] = self.params.name
				});
			}
		}
	end),
	DELETE = function(self)
		-- Delete dataset.
		self.dataset:delete()
	end
}))

-- 404 Wildcard Endpoint
app:get("/(*)", function(self)
	self:write({"Not Found", status = 404})
end)

return app