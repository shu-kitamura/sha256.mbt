///|
let k : ReadOnlyArray[UInt] = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
  0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
  0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
  0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
  0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
  0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
  0xc67178f2,
]

///|
fn to_ascii_bytes(input : String) -> Array[Byte] {
  // The original Python version encodes with ASCII; mirror that here.
  input
  .to_array()
  .map(fn(ch) {
    if !ch.is_ascii() {
      panic()
    }
    ch.to_int().to_byte()
  })
}

///|
fn padding(data : Array[Byte]) -> Array[Byte] {
  let length = data.length()
  let n = loop 1 {
    n => if length * 8 < 1 << (8 * n) { n } else { continue n + 1 }
  }
  let total_length = if length % 64 < 56 {
    (length / 64 + 1) * 64
  } else {
    (length / 64 + 2) * 64
  }
  let padded = Array::make(total_length, (0).to_byte())
  for i = 0; i < length; i = i + 1 {
    padded[i] = data[i]
  }
  padded[length] = (0x80).to_byte()
  let bit_length = length * 8
  for i = 0; i < n; i = i + 1 {
    let shift = (n - 1 - i) * 8
    let value = (bit_length >> shift) & 0xff
    padded[total_length - n + i] = value.to_byte()
  }
  padded
}

///|
fn bytes_to_u32_be(data : Array[Byte], offset : Int) -> UInt {
  let b0 = data[offset].to_uint()
  let b1 = data[offset + 1].to_uint()
  let b2 = data[offset + 2].to_uint()
  let b3 = data[offset + 3].to_uint()
  (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
}

///|
fn preprocess(input : String) -> Array[Array[UInt]] {
  let padded = padding(to_ascii_bytes(input))
  let num_blocks = padded.length() / 64
  let blocks : Array[Array[UInt]] = Array::new()
  for block_index = 0; block_index < num_blocks; block_index = block_index + 1 {
    let base = block_index * 64
    let words = Array::make(16, UInt::default())
    for t = 0; t < 16; t = t + 1 {
      words[t] = bytes_to_u32_be(padded, base + t * 4)
    }
    blocks.push(words)
  }
  blocks
}

///|
pub fn rtor(data : UInt, shift : Int) -> UInt {
  (data >> shift) | (data << (32 - shift))
}

///|
pub fn lower_sigma0(word : UInt) -> UInt {
  rtor(word, 7) ^ rtor(word, 18) ^ (word >> 3)
}

///|
pub fn lower_sigma1(word : UInt) -> UInt {
  rtor(word, 17) ^ rtor(word, 19) ^ (word >> 10)
}

///|
pub fn upper_sigma0(word : UInt) -> UInt {
  rtor(word, 2) ^ rtor(word, 13) ^ rtor(word, 22)
}

///|
pub fn upper_sigma1(word : UInt) -> UInt {
  rtor(word, 6) ^ rtor(word, 11) ^ rtor(word, 25)
}

///|
pub fn ch(x : UInt, y : UInt, z : UInt) -> UInt {
  (x & y) ^ (x.lnot() & z)
}

///|
pub fn maj(x : UInt, y : UInt, z : UInt) -> UInt {
  (x & y) ^ (x & z) ^ (y & z)
}

///|
fn word_to_hex(word : UInt) -> String {
  let b0 = ((word >> 24) & 0xff).to_byte()
  let b1 = ((word >> 16) & 0xff).to_byte()
  let b2 = ((word >> 8) & 0xff).to_byte()
  let b3 = (word & 0xff).to_byte()
  b0.to_hex() + b1.to_hex() + b2.to_hex() + b3.to_hex()
}

///|
fn compute_hash(blocks : Array[Array[UInt]]) -> String {
  let ws : Array[UInt] = Array::make(64, UInt::default())
  let h : Array[UInt] = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab,
    0x5be0cd19,
  ]
  for block_index = 0
      block_index < blocks.length()
      block_index = block_index + 1 {
    let block = blocks[block_index]
    for t = 0; t < 16; t = t + 1 {
      ws[t] = block[t]
    }
    for t = 16; t < 64; t = t + 1 {
      ws[t] = lower_sigma1(ws[t - 2]) +
        ws[t - 7] +
        lower_sigma0(ws[t - 15]) +
        ws[t - 16]
    }
    let (a, b, c, d, e, f, g, h1) = loop
      (0, h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]) {
      (64, a, b, c, d, e, f, g, h1) => (a, b, c, d, e, f, g, h1)
      (i, a, b, c, d, e, f, g, h1) => {
        let t1 = h1 + upper_sigma1(e) + ch(e, f, g) + k[i] + ws[i]
        let t2 = upper_sigma0(a) + maj(a, b, c)
        continue (i + 1, t1 + t2, a, b, c, d + t1, e, f, g)
      }
    }
    h[0] = h[0] + a
    h[1] = h[1] + b
    h[2] = h[2] + c
    h[3] = h[3] + d
    h[4] = h[4] + e
    h[5] = h[5] + f
    h[6] = h[6] + g
    h[7] = h[7] + h1
  }
  for i = 0, acc = ""; i < 8; i = i + 1, acc = acc + word_to_hex(h[i]) {

  } else {
    acc
  }
}

///|
pub fn sha256(input : String) -> String {
  compute_hash(preprocess(input))
}
