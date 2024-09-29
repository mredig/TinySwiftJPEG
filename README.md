# TinySwiftJPEG

A simple Swift wrapper around the [TinyJPEG](https://github.com/serge-rgb/TinyJPEG) library.

It makes the interface very Swifty as seen here:

```swift
// this is all just generating simple, raw image data
let imageDimensions = (x: 1275, y: 800)
let imageRowStride = 1280 * 4

func offset(for point: Point, channelCount: Int) -> Int {
	(point.y * imageRowStride) + point.x * channelCount
}

let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: imageRowStride * imageDimensions.y, alignment: 32)
for y in 0..<imageDimensions.y {
	for x in 0..<imageDimensions.x {
		let redIndex = offset(for: (x, y), channelCount: 4)

		let red = (Double(x) / Double(imageDimensions.x)) * 255
		let green = (Double(y) / Double(imageDimensions.y)) * 255
		let blue = 255 - red

		buffer[redIndex] = UInt8(red)
		buffer[redIndex + 1] = UInt8(green)
		buffer[redIndex + 2] = UInt8(blue)
		buffer[redIndex + 3] = 255
	}
}

let pixelData = Data(bytesNoCopy: buffer.baseAddress!, count: buffer.count, deallocator: .free)

// now that that's done (you'll probably get this from CoreGraphics or any other library
providing raw, 8 bits/channel RGB or RGBA interleaved data), here's the actual magic:

let jpeg = try TinySwiftJPEG.encodeJPEG( // this is the actual magic
	from: pixelData,
	rowStride: imageRowStride,
	width: imageDimensions.x,
	height: imageDimensions.y,
	channels: .rgba)

try jpeg.write(to: URL(filePath: "/path/to/output.jpg")
```

I made a small modification to the TinyJPEG library to allow for a different count of bytes per row
than simply just `width * channelCount` (channel count being either 3 or 4, depending on alpha) as
that's a very common situation in CoreGraphics (and probably elsewhere). That should save us an
unecessary byte copy!
