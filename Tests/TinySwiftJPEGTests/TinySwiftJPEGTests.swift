import Testing
import TinySwiftJPEG
import Foundation

@Test func testGrayscaleGradient() async throws {
	// Write your test here and use APIs like `#expect(...)` to check expected conditions.
	let imageDimensions = (x: 1280, y: 800)
	let imageSize = imageDimensions.x * imageDimensions.y

	let dImageSize = Double(imageSize)
	let pixels = (0..<imageSize).flatMap { index in
		let pd = Double(index) / (dImageSize - 1)
		let p = UInt8(pd * 255)

		return [p, p, p, 255]
	}

	let pixelData = Data(pixels)

	let jpeg = try TinySwiftJPEG.encodeJPEG(
		from: pixelData,
		width: imageDimensions.x,
		height: imageDimensions.y,
		channels: .rgba)

	guard let expectationURL = Bundle.module.url(forResource: "expectation", withExtension: "jpg") else {
		throw TestError.fail
	}
	let expData = try Data(contentsOf: expectationURL)

	#expect(expData == jpeg)
}

@Test func testRGBGradient() async throws {
	// Write your test here and use APIs like `#expect(...)` to check expected conditions.
	let imageDimensions = (x: 1280, y: 800)
	let imageSize = imageDimensions.x * imageDimensions.y

	func indexToXY(index: Int) -> (x: Int, y: Int) {
		let y = index / imageDimensions.x
		let x = index - (y * imageDimensions.x)
		return (x, y)
	}

	let dImageSize = Double(imageSize)
	let pixels = (0..<imageSize).flatMap { index in
		let xy = indexToXY(index: index)
		let red = (Double(xy.x) / Double(imageDimensions.x)) * 255
		let green = (Double(xy.y) / Double(imageDimensions.y)) * 255
		let blue = 255 - red

		return [UInt8(red), UInt8(green), UInt8(blue), 255]
	}

	let pixelData = Data(pixels)

	let jpeg = try TinySwiftJPEG.encodeJPEG(
		from: pixelData,
		width: imageDimensions.x,
		height: imageDimensions.y,
		channels: .rgba)

	guard let expectationURL = Bundle.module.url(forResource: "color", withExtension: "jpg") else {
		throw TestError.fail
	}
	let expData = try Data(contentsOf: expectationURL)

	#expect(expData == jpeg)
}

enum TestError: Error {
	case fail
}
