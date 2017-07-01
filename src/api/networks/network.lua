local Network = torch.class("Network")
local nn = require("nn")

function Network:__init()

end

function Network:model()

	local net = nn.Sequential():type('torch.CudaTensor');

	-- #alphabet x 1014
	net:add(cudnn.TemporalConvolution(69, 256, 7))
	net:add(nn.Threshold())
	net:add(nn.TemporalMaxPooling(3, 3))

	-- 336 x 256
	net:add(cudnn.TemporalConvolution(256, 256, 7))
	net:add(nn.Threshold())
	net:add(nn.TemporalMaxPooling(3, 3))

	-- 110 x 256
	net:add(cudnn.TemporalConvolution(256, 256, 3))
	net:add(nn.Threshold())

	-- 108 x 256
	net:add(cudnn.TemporalConvolution(256, 256, 3))
	net:add(nn.Threshold())

	-- 106 x 256
	net:add(cudnn.TemporalConvolution(256, 256, 3))
	net:add(nn.Threshold())

	-- 104 x 256
	net:add(cudnn.TemporalConvolution(256, 256, 3))
	net:add(nn.Threshold())
	net:add(nn.TemporalMaxPooling(3, 3))

	-- 34 x 256
	net:add(nn.Reshape(8704))

	-- 8704
	net:add(nn.Linear(8704, 1024))
	net:add(nn.Threshold())
	net:add(nn.Dropout(0.5))

	-- 1024
	net:add(nn.Linear(1024, 1024))
	net:add(nn.Threshold())
	net:add(nn.Dropout(0.5))

	-- 1024
	net:add(nn.Linear(1024, 3))
	net:add(cudnn.LogSoftMax())

	-- weight initialization
	local w,dw = net:getParameters()
	w:normal():mul(5e-2)

	return net
end

function Network:loss()
	return nn.ClassNLLCriterion();
end