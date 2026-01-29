///|
test "rtor" {
  inspect(rtor(1870659584, 7), content="14614528")
  inspect(rtor(1870659584, 18), content="7136")
  inspect(rtor(219, 4), content="2952790029")
}

///|
test "sigma functions" {
  inspect(lower_sigma0(1870659584), content="221191136")
  inspect(lower_sigma0(219), content="3057041434")
  inspect(lower_sigma1(1870659584), content="1825328")
  inspect(lower_sigma1(219), content="7790592")
  inspect(upper_sigma0(1870659584), content="467893694")
  inspect(upper_sigma0(219), content="3336268854")
  inspect(upper_sigma1(1870659584), content="3249795127")
  inspect(upper_sigma1(219), content="2002808195")
}

///|
test "ch and maj" {
  inspect(ch(1359893119, 2600822924, 528734635), content="528861580")
  inspect(maj(1359893119, 2600822924, 528734635), content="453466287")
}

///|
test "sha256 vectors" {
  inspect(
    sha256_hexdigest(b""),
    content="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
  inspect(
    sha256_hexdigest(b"hello"),
    content="2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824",
  )
  inspect(
    sha256_hexdigest(b"test"),
    content="9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
  )
  // 120 bytes of 'a' (0x61)
  let long = Bytes::make(120, b'a')
  inspect(
    sha256_hexdigest(long),
    content="2f3d335432c70b580af0e8e1b3674a7c020d683aa5f73aaaedfdc55af904c21c",
  )
}
