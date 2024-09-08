--!strict

--testing code for the Tensor module

local Tensor = require(script.Tensor)
type Tensor<T> = Tensor.Tensor<T> --just for ease of use

local foo: Tensor<Vector3> = Tensor.new()

--populate the tensor
for x = -5, 5 do
	for y = -5, 5 do 
		for z = -5, 5 do
			foo:Set(x, y, z, Vector3.new(x, y, z))
		end
	end
end

print(':Set() OK')

assert(foo:Get(1, 2, 3) == Vector3.new(1, 2, 3)) --find a value in the tensor
assert(foo:Get(math.huge, math.huge, math.huge) == nil) --value not found

print(':Get() OK')

foo:Set(1, 2, 3, nil)
assert(foo:Get(1, 2, 3)==nil) --remove a value

print(':Set(nil) OK')

assert(select('#', foo:Iter()()) == 4) --coroutine iterator should return 4 items
for x, y, z, v in foo:Iter() do
	assert(Vector3.new(x, y, z) == v) --values should match their positions
end

print(':Iter() OK')

local bar = foo:Clone()
assert(bar:Get(5, 5, 5) == foo:Get(5, 5, 5))

print(':Clone() OK')
