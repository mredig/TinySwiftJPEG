private import TinyCJPEG
import Foundation

public enum TinySwiftJPEG: Sendable {

	public enum Channels: Int32, Sendable {
		case rgb = 3
		case rgba = 4
	}

	public enum Quality: Int32, Sendable {
		case high = 3
		case good = 2
		case low = 1
	}

	private class Context {
		var data = Data()

		static func from(pointer: UnsafeMutableRawPointer) -> Context {
			let typed = pointer.bindMemory(to: Context.self, capacity: 1)
			return typed.pointee
		}

		var pointer: UnsafeMutableRawPointer {
			let typedPointer = UnsafeMutablePointer<Context>.allocate(capacity: 1)
			typedPointer.pointee = self
			let rawPointer = UnsafeMutableRawPointer(typedPointer)

			return rawPointer
		}
	}

	/// Encodes raw image data to jpeg, leveraging the [tinyjpeg](https://github.com/serge-rgb/TinyJPEG) library.
	/// `data` must be encoded in 3 bytes interleaved RGB or 4 bytes interleaved RGBA (in that channel order) data.
	/// All other arguments should be relatively self explanatory. Returns a jpeg blob in `Data`.
	public static func encodeJPEG(
		from data: Data,
		rowStride: Int?,
		width: Int,
		height: Int,
		channels: Channels,
		quality: Quality = .good
	) throws(Error) -> Data {
		let context = Context()
		let rowStride = rowStride ?? (width * Int(channels.rawValue))
		let result = data.withUnsafeBytes { buffer in
			let inputPointer = buffer.bindMemory(to: UInt8.self).baseAddress
			return tje_encode_with_func(
				{ contextPointer, dataPointer, size in
					guard
						let contextPointer
					else { return }
					let context = Context.from(pointer: contextPointer)
					guard
						let dataPointer
					else { return }

					let newData = Data(bytes: dataPointer, count: Int(size))
					context.data.append(newData)
				},
				context.pointer,
				quality.rawValue,
				Int32(rowStride),
				Int32(width),
				Int32(height),
				channels.rawValue,
				inputPointer)
		}

		guard result == 1 else { throw .encodingFailed }

		return context.data
	}

	public enum Error: Swift.Error {
		case encodingFailed
	}
}
