//
//  CryptoSwift
//
//  Copyright (C) 2014-2017 Marcin Krzyżanowski <marcin@krzyzanowskim.com>
//  This software is provided 'as-is', without any express or implied warranty.
//
//  In no event will the authors be held liable for any damages arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
//  - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
//  - This notice may not be removed or altered from any source or binary distribution.
//

//  http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.202.pdf
//  http://keccak.noekeon.org/specs_summary.html
//

public final class Sha3 {
    private static let round_constants: Array<UInt64> = [
        0x0000000000000001, 0x0000000000008082, 0x800000000000808a, 0x8000000080008000,
        0x000000000000808b, 0x0000000080000001, 0x8000000080008081, 0x8000000000008009,
        0x000000000000008a, 0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
        0x000000008000808b, 0x800000000000008b, 0x8000000000008089, 0x8000000000008003,
        0x8000000000008002, 0x8000000000000080, 0x000000000000800a, 0x800000008000000a,
        0x8000000080008081, 0x8000000000008080, 0x0000000080000001, 0x8000000080008008,
    ]

    // Parameters for Keccak256
    private static let blockSize: Int = 136
    private static let digestLength: Int = 32
    private static let markByte: UInt8 = 0x01

    public static func keccak256(_ data: Data) -> Data {
        var accumulated = Array<UInt8>()
        var accumulatedHash = Array<UInt64>(repeating: 0, count: digestLength)

        accumulated += Array(data).slice

        // Add padding
        let markByteIndex = accumulated.count

        // We need to always pad the input. Even if the input is a multiple of blockSize.
        let r = blockSize * 8
        let q = (r / 8) - (accumulated.count % (r / 8))
        accumulated += Array<UInt8>(repeating: 0, count: q)

        accumulated[markByteIndex] |= markByte
        accumulated[accumulated.count - 1] |= 0x80

        for chunk in accumulated.batched(by: blockSize) {
            process(block: chunk.uInt64Array.slice, currentHash: &accumulatedHash)
        }

        let result = accumulatedHash.reduce(Array<UInt8>()) { (result, value) -> Array<UInt8> in
            return result + bigEndianBytes(from: value)
        }

        return Data(bytes: result[0..<digestLength])
    }

    private static func bigEndianBytes(from value: UInt64) -> Array<UInt8> {
        let valuePointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        valuePointer.pointee = value

        let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
        var bytes = Array<UInt8>(repeating: 0, count: 8)
        for j in 0..<8 {
            bytes[j] = (bytesPointer + j).pointee
        }

        valuePointer.deinitialize(count: 1)
        valuePointer.deallocate()

        return bytes
    }

    ///  1. For all pairs (x,z) such that 0≤x<5 and 0≤z<w, let
    ///     C[x,z]=A[x, 0,z] ⊕ A[x, 1,z] ⊕ A[x, 2,z] ⊕ A[x, 3,z] ⊕ A[x, 4,z].
    ///  2. For all pairs (x, z) such that 0≤x<5 and 0≤z<w let
    ///     D[x,z]=C[(x1) mod 5, z] ⊕ C[(x+1) mod 5, (z –1) mod w].
    ///  3. For all triples (x, y, z) such that 0≤x<5, 0≤y<5, and 0≤z<w, let
    ///     A′[x, y,z] = A[x, y,z] ⊕ D[x,z].
    private static func θ(_ a: inout Array<UInt64>) {
        let c = UnsafeMutablePointer<UInt64>.allocate(capacity: 5)
        c.initialize(repeating: 0, count: 5)
        defer {
            c.deinitialize(count: 5)
            c.deallocate()
        }
        let d = UnsafeMutablePointer<UInt64>.allocate(capacity: 5)
        d.initialize(repeating: 0, count: 5)
        defer {
            d.deinitialize(count: 5)
            d.deallocate()
        }

        for i in 0..<5 {
            c[i] = a[i] ^ a[i &+ 5] ^ a[i &+ 10] ^ a[i &+ 15] ^ a[i &+ 20]
        }

        d[0] = c[1].rotateLeft(by: 1) ^ c[4]
        d[1] = c[2].rotateLeft(by: 1) ^ c[0]
        d[2] = c[3].rotateLeft(by: 1) ^ c[1]
        d[3] = c[4].rotateLeft(by: 1) ^ c[2]
        d[4] = c[0].rotateLeft(by: 1) ^ c[3]

        for i in 0..<5 {
            a[i] ^= d[i]
            a[i &+ 5] ^= d[i]
            a[i &+ 10] ^= d[i]
            a[i &+ 15] ^= d[i]
            a[i &+ 20] ^= d[i]
        }
    }

    /// A′[x, y, z]=A[(x &+ 3y) mod 5, x, z]
    private static func π(_ a: inout Array<UInt64>) {
        let a1 = a[1]
        a[1] = a[6]
        a[6] = a[9]
        a[9] = a[22]
        a[22] = a[14]
        a[14] = a[20]
        a[20] = a[2]
        a[2] = a[12]
        a[12] = a[13]
        a[13] = a[19]
        a[19] = a[23]
        a[23] = a[15]
        a[15] = a[4]
        a[4] = a[24]
        a[24] = a[21]
        a[21] = a[8]
        a[8] = a[16]
        a[16] = a[5]
        a[5] = a[3]
        a[3] = a[18]
        a[18] = a[17]
        a[17] = a[11]
        a[11] = a[7]
        a[7] = a[10]
        a[10] = a1
    }

    /// For all triples (x, y, z) such that 0≤x<5, 0≤y<5, and 0≤z<w, let
    /// A′[x, y,z] = A[x, y,z] ⊕ ((A[(x+1) mod 5, y, z] ⊕ 1) ⋅ A[(x+2) mod 5, y, z])
    private static func χ(_ a: inout Array<UInt64>) {
        for i in stride(from: 0, to: 25, by: 5) {
            let a0 = a[0 &+ i]
            let a1 = a[1 &+ i]
            a[0 &+ i] ^= ~a1 & a[2 &+ i]
            a[1 &+ i] ^= ~a[2 &+ i] & a[3 &+ i]
            a[2 &+ i] ^= ~a[3 &+ i] & a[4 &+ i]
            a[3 &+ i] ^= ~a[4 &+ i] & a0
            a[4 &+ i] ^= ~a0 & a1
        }
    }

    private static func ι(_ a: inout Array<UInt64>, round: Int) {
        a[0] ^= round_constants[round]
    }

    fileprivate static func process(block chunk: ArraySlice<UInt64>, currentHash hh: inout Array<UInt64>) {
        // expand
        hh[0] ^= chunk[0].littleEndian
        hh[1] ^= chunk[1].littleEndian
        hh[2] ^= chunk[2].littleEndian
        hh[3] ^= chunk[3].littleEndian
        hh[4] ^= chunk[4].littleEndian
        hh[5] ^= chunk[5].littleEndian
        hh[6] ^= chunk[6].littleEndian
        hh[7] ^= chunk[7].littleEndian
        hh[8] ^= chunk[8].littleEndian
        if blockSize > 72 { // 72 / 8, sha-512
            hh[9] ^= chunk[9].littleEndian
            hh[10] ^= chunk[10].littleEndian
            hh[11] ^= chunk[11].littleEndian
            hh[12] ^= chunk[12].littleEndian
            if blockSize > 104 { // 104 / 8, sha-384
                hh[13] ^= chunk[13].littleEndian
                hh[14] ^= chunk[14].littleEndian
                hh[15] ^= chunk[15].littleEndian
                hh[16] ^= chunk[16].littleEndian
                if blockSize > 136 { // 136 / 8, sha-256
                    hh[17] ^= chunk[17].littleEndian
                    // FULL_SHA3_FAMILY_SUPPORT
                    if blockSize > 144 { // 144 / 8, sha-224
                        hh[18] ^= chunk[18].littleEndian
                        hh[19] ^= chunk[19].littleEndian
                        hh[20] ^= chunk[20].littleEndian
                        hh[21] ^= chunk[21].littleEndian
                        hh[22] ^= chunk[22].littleEndian
                        hh[23] ^= chunk[23].littleEndian
                        hh[24] ^= chunk[24].littleEndian
                    }
                }
            }
        }

        // Keccak-f
        for round in 0..<24 {
            θ(&hh)

            hh[1] = hh[1].rotateLeft(by: 1)
            hh[2] = hh[2].rotateLeft(by: 62)
            hh[3] = hh[3].rotateLeft(by: 28)
            hh[4] = hh[4].rotateLeft(by: 27)
            hh[5] = hh[5].rotateLeft(by: 36)
            hh[6] = hh[6].rotateLeft(by: 44)
            hh[7] = hh[7].rotateLeft(by: 6)
            hh[8] = hh[8].rotateLeft(by: 55)
            hh[9] = hh[9].rotateLeft(by: 20)
            hh[10] = hh[10].rotateLeft(by: 3)
            hh[11] = hh[11].rotateLeft(by: 10)
            hh[12] = hh[12].rotateLeft(by: 43)
            hh[13] = hh[13].rotateLeft(by: 25)
            hh[14] = hh[14].rotateLeft(by: 39)
            hh[15] = hh[15].rotateLeft(by: 41)
            hh[16] = hh[16].rotateLeft(by: 45)
            hh[17] = hh[17].rotateLeft(by: 15)
            hh[18] = hh[18].rotateLeft(by: 21)
            hh[19] = hh[19].rotateLeft(by: 8)
            hh[20] = hh[20].rotateLeft(by: 18)
            hh[21] = hh[21].rotateLeft(by: 2)
            hh[22] = hh[22].rotateLeft(by: 61)
            hh[23] = hh[23].rotateLeft(by: 56)
            hh[24] = hh[24].rotateLeft(by: 14)

            π(&hh)
            χ(&hh)
            ι(&hh, round: round)
        }
    }

}
