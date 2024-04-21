--[[
	Tensor class implementation (a 3-dimensional table)
	by @Prototrode (Roblox and Discord handle)
	
	NOTE: Not extensively tested, might be unstable. Only used for one or two of my projects.
]]

--!native
--!strict

export type ArrayValue<T> = {[number]: T?}
export type MatrixValue<T> = {[number]: ArrayValue<T>}
export type TensorValue<T> = {[number]: MatrixValue<T>}
export type TensorHash<T> = {[Vector3]: T}

type class = {
	__index: class,
	new: <T>() -> Tensor<T>,
	fromHash: <T>(hash: TensorHash<T>) -> Tensor<T>, --opposite of Tensor:Hash()
}

type ProtoTensor<T> = {
	self: TensorValue<T>
}

export type Tensor<T> = ProtoTensor<T> & {
	
	--add a new entry; set to nil to remove
	Set: (self: Tensor<T>, x: number, y: number, z: number, v: T?) -> (),
	
	--retrieve an entry; nil if it doesn't exist
	Get: (self: Tensor<T>, x: number, y: number, z: number) -> T?,
	
	--returns a coroutine iterator in (x, y, z, value) format
	Iter: (self: Tensor<T>) -> () -> (number, number, number, T),
	
	--clones the tensor and returns the new one
	Clone: (self: Tensor<T>) -> Tensor<T>,
	
	--create a hashmap equivalent of the tensor in {[Vector3]: value} format
	Hash: (self: Tensor<T>) -> TensorHash<T>,
	
	--get the total number of items stored in the tensor
	Len: (self: Tensor<T>) -> number,
}

local Tensor: class & Tensor<any> = {}::any
Tensor.__index = Tensor

Tensor.new = function<T>(): Tensor<T>
	local self: ProtoTensor<T> = {
		self = {},
	}
	local self: Tensor<T> = setmetatable(self, Tensor)::any
	
	return self
end

Tensor.fromHash = function<T>(hash: TensorHash<T>): Tensor<T>
	local self: Tensor<T> = Tensor.new()
	for vec, val in hash do
		self:Set(vec.X, vec.Y, vec.Z, val)
	end
	return self
end

Tensor.Set = function<T>(self: Tensor<T>, x: number, y: number, z: number, v: T?)
	local mat: MatrixValue<T>? = self.self[x]
	if mat then
		local arr: ArrayValue<T>? = mat[y]
		if arr then
			arr[z] = v
			return
		end
		mat[y] = {[z] = v}
		return
	end
	self.self[x] = {[y] = {[z] = v}}
end

Tensor.Get = function<T>(self: Tensor<T>, x: number, y: number, z: number): T?
	local mat: MatrixValue<T>? = self.self[x]
	if mat then
		local arr: ArrayValue<T>? = mat[y]
		if arr then
			return arr[z]
		end
	end	
	return nil
end

Tensor.Iter = function<T>(self: Tensor<T>): () -> (number, number, number, T)
	return coroutine.wrap(function()
		for x, mat in self.self do
			for y, arr in mat do
				for z, val in arr do
					coroutine.yield(x, y, z, val)
				end
			end
		end
	end)
end

Tensor.Clone = function<T>(self: Tensor<T>): Tensor<T>
	local new: Tensor<T> = Tensor.new()
	for x, y, z, v in self:Iter() do
		new:Set(x, y, z, v)
	end
	return new
end

Tensor.Hash = function<T>(self: Tensor<T>): TensorHash<T>
	local hash: TensorHash<T> = {}
	for x, y, z, v in self:Iter() do
		hash[Vector3.new(x, y, z)] = v
	end
	return hash
end

Tensor.Len = function<T>(self: Tensor<T>): number
	local amount: number = 0
	for _ in self:Iter() do
		amount += 1
	end
	return amount
end

return Tensor::class
