# punyishcode

[Punycode](https://en.wikipedia.org/wiki/Punycode) decoding / encoding in Janet.

# Usage

```janet
(import punyishcode :as p)

(p/decode "de-jg4avhby1noc0d")
# =>
@"パフィーdeルンバ"

(p/encode "München-Ost")
# =>
@"Mnchen-Ost-9db"
```

Note: In the example above, the return value for `(p/decode ...)` may
show up as:

```
@"\xE3\x83\x91\xE3\x83\x95\xE3\x82\xA3\xE3\x83\xBCde\xE3\x83\xAB\xE3\x83\xB3\xE3\x83\x90"
```

By doing `(print _)` after evaluating a `p/decode` form, one is more
likely to see the result in a readable fashion.
