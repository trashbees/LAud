local class = require "class"

local M = {}

M.Audio = class() do
  function M.Audio:_init(...)
    self.head = {}
    self.samples = {}
    local args = {...}
    if args[1] then
      local f = io.open(args[1], "rb")
      self.head.ChunkID = f:read(4)
      self.head.ChunkSize = string.unpack("<I",f:read(4))
      self.head.Format = f:read(4)
      if self.head.Format ~= "WAVE" then
        error("Could not read \"" ..
        args[1] .. "\" as WAVE file") end
      --
      f:seek("cur", 4) -- "fmt "
      self.head.Subchunk1Size = string.unpack("<I", f:read(4))
      self.head.AudioFormat = string.unpack("<I1", f:read(2))
      self.head.NumChannels = string.unpack("<I1", f:read(2))
      --
      self.head.SampleRate = string.unpack("<I", f:read(4))
      self.head.ByteRate = string.unpack("<I",f:read(4))
      self.head.BlockAlign = string.unpack("<I1", f:read(2))
      self.head.BitsPerSample = string.unpack("<I1", f:read(2))
      --
      f:seek("cur", 4) -- "data"
      self.head.Subchunk2Size = string.unpack("<I", f:read(4))
      -- everything handled after this should be a sample!!!!
      
      while true do
        local b = f:read(self.head.BitsPerSample/4)
        if b == nil then break end
        self.samples[#self.samples + 1] = b
      end
      
      f:close()
    end
  end

  function M.Audio:reconstructHead()
    local head =  string.pack(">c4", self.head.ChunkID) ..
                  string.pack("<I", self.head.ChunkSize) ..
                  string.pack(">c4", self.head.Format) ..
                  string.pack(">c4", "fmt ") ..
                  string.pack("<I", self.head.Subchunk1Size) ..
                  string.pack("<I2", self.head.AudioFormat) ..
                  string.pack("<I2", self.head.NumChannels) ..
                  string.pack("<I", self.head.SampleRate) ..
                  string.pack("<I", self.head.ByteRate) ..
                  string.pack("<I2", self.head.BlockAlign) ..
                  string.pack("<I2", self.head.BitsPerSample) ..
                  string.pack(">c4", "data") ..
                  string.pack("<I", self.head.Subchunk2Size)
    return head
  end
  
  function M.Audio:reconstructSamples()
    local samples = ""
    for i, v in ipairs(self.samples) do
      samples = samples .. v
    end
    return samples
  end
  
  function M.Audio:reconstructAudio()
    return self:reconstructHead() .. self:reconstructSamples()
  end
  
  function M.Audio:append(aud)
    for i,v in ipairs(aud.samples) do
      self.samples[#self.samples + 1] = v
    end
    self:recalcSize()
  end
  
  function M.Audio:recalcSize()
    self.head.Subchunk2Size = #self.samples * 4
  end
end

return M
