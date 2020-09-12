# LAud

Incredibly rudimentary Lua audio class

## How to use

For maximum suffering, drop `laud.lua` and `class.lua` somewhere in your project directory. If you have an issue with the mega-generic filename `class.lua` (sorry) you can change the name + change the first line of `laud.lua` to `local class = require "[new file name]"`.

import LAud + open an existing audio file:

```lua
laud = require "laud"

lauddata = laud.Audio("path\to\file.wav")
```

Cool / interesting things you can do with LAud:

* look at header data
* view 100% raw, unformatted samples individually
* reconstruct the header, samples, and the file as a whole
* concatenate audio

### Looking at header data

The header data is in `lauddata.head`. It has the following fields:
* ChunkID
* ChunkSize
* Format
* Subchunk1Size
* AudioFormat
* NumChannels
* SampleRate
* ByteRate
* BlockAlign
* BitsPerSample
* Subchunk2Size

`Subchunk2Size` is used in `Audio:recalcSize()`, which should be called after any length modification is made to the length of the audio (if you're doing that manually)

### Messing with samples

LAud stores samples in whatever format they happened to be in when the file was read, which isn't really optimal but if you know the format of a WAVE file you could convert it back and forth to make any modifications significantly easier (the field is just called `samples`). The only thing it can do internally with this data is 1) reconstruct the data chunk using the sample list and 2) append another LAud Audio object onto the end of it.

```lua
lauddata:reconstructAudio() -- reconstructs the entire object as a string
lauddata:reconstructSamples() -- reconstructs just the samples
lauddata:recosntructHead() -- just the head (not super useful....)
lauddata:append(lauddata2) -- plops another set of samples at the end of the audio
```

## Known issues
* There is almost no data sanitation. It does not check if you're trying to append two files with a different number of channels, sample rate, sample size, etc.
* This does not work with anything but WAVE files. I made it throw a fun little error. This is basically the only check I do on the data.
* There are a lot of instances where it SHOULD break where it doesn't, another side-effect of not checking the data.

## Warning

You probably shouldn't use this as-is.

I'm showcasing it because I've seen almost no examples on how to do this online. I had to do a bunch of research and a lot of trial and error to get it to work. I think it's useful for my specific purposes, getting a quick and dirty knowledge base on how the format works, and for figuring out how you'd implement this kind of thing in your own project.

Here's a good resource on what WAVE PCM files should look like: http://soundfile.sapp.org/doc/WaveFormat/

Here's where you can look at how the string reformatting works: https://www.lua.org/manual/5.3/manual.html#6.4.2

This was made for one purpose only -- to concatenate audio files for some rough TTS in a game. It has almost no functionality useful for outside of that.
