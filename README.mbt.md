# shu-kitamura/sha256

SHA-256 ハッシュアルゴリズムの MoonBit 実装です。

## インストール

```bash
moon add shu-kitamura/sha256
```

## 使い方

```moonbit
///|
fn main {
  let hash = @sha256.sha256_hexdigest(b"hello")
  println(hash)
  // => 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
}
```

### API

- `sha256(input : Bytes) -> Bytes` - 入力バイト列の SHA-256 ハッシュ値をバイト列で返します
- `sha256_hexdigest(input : Bytes) -> String` - 入力バイト列の SHA-256 ハッシュ値を16進数文字列で返します
