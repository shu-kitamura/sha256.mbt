# sha256.mbt

MoonBit implementation of the SHA-256 hash algorithm.

## Installation

```bash
moon add shu-kitamura/sha256
```

## Usage

```moonbit
///|
fn main {
  let digest_bytes = @sha256.sha256(b"hello")
  // => Bytes (32 bytes)

  let digest_hex = @sha256.sha256_hexdigest(b"hello")
  // => String (64 hex chars)
}
```

## License

Apache-2.0
