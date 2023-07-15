type class = {
	new: <X, Y, Z, T>(TensorValue<X, Y, Z, T>?) -> Tensor<X, Y, Z, T>,
}

export type Array<Z, T> = {[Z]: T}
export type Matrix<X, Y, T> = {[X]: Array<Y, T>}
export type TensorValue<X, Y, Z, T> = {[X]: Matrix<Y, Z, T>}
export type Tensor<X, Y, Z, T> = {
	_ : TensorValue<X, Y, Z, T>, --The actual stored values of the Tensor
	
	--Class methods are explained below
	Set: (self: Tensor<X, Y, Z, T>, x: X, y: Y, z: Z, value: T) -> (),
	Get: (self: Tensor<X, Y, Z, T>, x: X, y: Y, z: Z) -> T?,
	Iter: ((self: Tensor<X, Y, Z, T>) -> () -> (X, Y, Z, T)) & ((self: Tensor<X, Y, Z, T>, true) -> () -> (X, Y, Z, T, number)),
	Clone: (self: Tensor<X, Y, Z, T>) -> Tensor<X, Y, Z, T>,
}

local Tensor = {}
Tensor.__index = Tensor

--Create a new Tensor object. Optional pre-existing tensor data structure (A 3D table organized as table[x][y][z] = v).
function Tensor.new<X, Y, Z, T>(tensor: TensorValue<X, Y, Z, T>?): Tensor<X, Y, Z, T>
	return setmetatable({_ = tensor or {}}, Tensor)::any
end

--Set a value in the Tensor.
function Tensor.Set<X, Y, Z, T>(self: Tensor<X, Y, Z, T>, x: X, y: Y, z: Z, value: T): ()
	local m: Matrix<Y, Z, T>? = self._[x]
	if m then
		local a: Array<Z, T>? = m[y]
		if a then
			a[z] = value
			return
		end
		m[y] = {[z] = value}
		return
	end	
	self._[x] = {[y] = {[z] = value}}
	return
end

--Retrieve a value from the Tensor. Returns nil if the value doesn't exist.
function Tensor.Get<X, Y, Z, T>(self: Tensor<X, Y, Z, T>, x: X, y: Y, z: Z): T?
	local m: Matrix<Y, Z, T>? = self._[x]
	if m then
		local a: Array<Z, T>? = m[y]
		if a then
			return a[z]
		end
	end
	return nil
end

--Returns an iterator function that will loop through all entries in the Tensor. Returns the position and the value.
function Tensor.Iter<X, Y, Z, T>(self: Tensor<X, Y, Z, T>, counter: boolean?): () -> (X, Y, Z, T, number?)
	if counter then
		return coroutine.wrap(function()
			local _c: number = 0
			for x: X, m: Matrix<Y, Z, T> in self._ do
				for y: Y, a: Array<Z, T> in m do
					for z: Z, v: T in a do
						_c += 1
						coroutine.yield(x, y, z, v, _c)
					end
				end
			end
		end)
	end
	return coroutine.wrap(function()
		for x: X, m: Matrix<Y, Z, T> in self._ do
			for y: Y, a: Array<Z, T> in m do
				for z: Z, v: T in a do
					coroutine.yield(x, y, z, v)
				end
			end
		end
	end)
end

--Clone a Tensor object.
function Tensor.Clone<X, Y, Z, T>(self: Tensor<X, Y, Z, T>): Tensor<X, Y, Z, T>
	local t: Tensor<X, Y, Z, T> = Tensor.new()
	for x, y, z, v: T in self:Iter() do
		t:Set(x, y, z, v)
	end
	return t
end

return (Tensor::any)::class