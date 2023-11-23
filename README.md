# punyishcode

Punycode decoding / encoding in Janet.

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

