# https://www.rfc-editor.org/rfc/rfc3492.txt

# great article (in japanese):
#
#   https://qiita.com/msmania/items/dc0e2b8c2c5de0707435

(def base 36)

(def tmin 1)

(def tmax 26)

(def skew 38)

(def damp 700)

(def initial-bias 72)

# first code point beyond ASCII
# sort of a boundary between basic and extended code points
(def initial-n 0x80)

(def delimiter "-")

# 3.4 Bias adaptation
#
# ...
#
# The motivation for this procedure is that the current delta
# provides a hint about the likely size of the next delta, and so
# t(j) is set to tmax for the more significant digits starting with
# the one expected to be last, tmin for the less significant digits
# up through the one expected to be third-last, and somewhere
# between tmin and tmax for the digit expected to be second-last
# (balancing the hope of the expected-last digit being unnecessary
# against the danger of it being insufficient).
(defn adapt
  ``
  RFC 3492 bias adaptation function.

  See section 3.4 of RFC 3492 for more details.
  ``
  [delta num-points first-time]
  ``
    1. Delta is scaled in order to avoid overflow in the next step:

         let delta = delta div 2

       But when this is the very first delta, the divisor is not 2, but
       instead a constant called damp.  This compensates for the fact
       that the second delta is usually much smaller than the first.
  ``
  (var delta
    (if first-time
      (div delta damp)
      (div delta 2)))
  ``
    2. Delta is increased to compensate for the fact that the next delta
       will be inserting into a longer string:

         let delta = delta + (delta div numpoints)

       numpoints is the total number of code points encoded/decoded so
       far (including the one corresponding to this delta itself, and
       including the basic code points).
  ``
  (+= delta (div delta num-points))
  ``
    3. Delta is repeatedly divided until it falls within a threshold, to
       predict the minimum number of digits needed to represent the next
       delta:

         while delta > ((base - tmin) * tmax) div 2
         do let delta = delta div (base - tmin)
  ``
  (var n-divs 0)
  (while (> delta
            (div (* (- base tmin) tmax)
                 2))
    (set delta (div delta (- base tmin)))
    (++ n-divs))
  ``
    4. The bias is set:

         let bias =
           (base * the number of divisions performed in step 3) +
           (((base - tmin + 1) * delta) div (delta + skew))
  ``
  (+ (* base n-divs)
     (div (* (+ (- base tmin) 1) delta)
          (+ delta skew))))

(defn cp-to-digit
  ``
  Given a code point `cp`, return a corresponding "digit".

  `cp` should be a numeric value representing one of
  the ASCII characters from [0, 9], [A, Z], [a, z].

  This represents the map:

    A-Z  ->   0-25
    a-z  ->   0-25
    0-9  ->  26-35

  See `digit-to-cp`.
  ``
  [cp]
  (cond
    (<= (chr "0") cp (chr "9"))
    (- cp (- (chr "0") 26))
    #
    (<= (chr "A") cp (chr "Z"))
    (- cp (chr "A"))
    #
    (<= (chr "a") cp (chr "z"))
    (- cp (chr "a"))
    #
    (errorf "unexpected code point: %n" cp)))

(comment

  (cp-to-digit (get "A" 0))
  # =>
  0

  (cp-to-digit (get "J" 0))
  # =>
  9

  (cp-to-digit (get "h" 0))
  # =>
  7

  (cp-to-digit (get "z" 0))
  # =>
  25

  (cp-to-digit (get "3" 0))
  # =>
  29

  (cp-to-digit (get "9" 0))
  # =>
  35

  )

(defn digit-to-cp
  ``
  Given `digit`, return a corresponding basic code point.

  `digit` should be in the range [0, 35].

  This represents the map:

     0-25  ->  a-z
    26-35  ->  0-9

  See `cp-to-digit`.
  ``
  [digit]
  (+ digit (- (chr "0") 26)
     # 0-25 needs additional offset
     (if (< digit 26) 0x4b 0)))

(comment

  (digit-to-cp 0)
  # =>
  (chr "a")

  (digit-to-cp 9)
  # =>
  (chr "j")

  (digit-to-cp 25)
  # =>
  (chr "z")

  (digit-to-cp 29)
  # =>
  (chr "3")

  (digit-to-cp 35)
  # =>
  (chr "9")

  )

(defn calc-threshold
  [bias j]
  (let [k (* base (inc j))]
    (cond
      (<= k (+ bias tmin))
      tmin
      #
      (>= k (+ bias tmax))
      tmax
      #
      (- k bias))))

(comment

  (calc-threshold 72 0)
  # =>
  1

  (calc-threshold 72 1)
  # =>
  1

  (calc-threshold 72 2)
  # =>
  26

  (calc-threshold 72 71)
  # =>
  26

  )

## decoding

# 6.2 Decoding procedure
#
#    let n = initial_n
#    let i = 0
#    let bias = initial_bias
#    let output = an empty string indexed from 0
#    consume all code points before the last delimiter (if there is one)
#      and copy them to output, fail on any non-basic code point
#    if more than zero code points were consumed then consume one more
#      (which will be the last delimiter)
#    while the input is not exhausted do begin
#      let oldi = i
#      let w = 1
#      for k = base to infinity in steps of base do begin
#        consume a code point, or fail if there was none to consume
#        let digit = the code point's digit-value, fail if it has none
#        let i = i + digit * w, fail on overflow
#        let t = tmin if k <= bias {+ tmin}, or
#                tmax if k >= bias + tmax, or k - bias otherwise
#        if digit < t then break
#        let w = w * (base - t), fail on overflow
#      end
#      let bias = adapt(i - oldi, length(output) + 1, test oldi is 0?)
#      let n = n + i div (length(output) + 1), fail on overflow
#      let i = i mod (length(output) + 1)
#      {if n is a basic code point then fail}
#      insert n into output at position i
#      increment i
#    end

# 3.2 Insertion unsort coding
#
# ...
#
# The deltas are a run-length encoding of this sequence of events:
# they are the lengths of the runs of non-insertion states preceeding
# the insertion states.

(defn decode*
  [input]
  (var i 0)
  (var curr-cp initial-n)
  (var bias initial-bias)
  #
  (def last-delim-idx (last (string/find-all delimiter input)))
  # copy all basic code points that appear before the last delimiter
  (def output
    (if last-delim-idx
      (filter |(< $ initial-n)
              (slice input 0 last-delim-idx))
      @[]))
  # process input
  (var in-idx
    (if last-delim-idx
      (inc last-delim-idx)
      0))
  (def in-len (length input))
  (while (< in-idx in-len)
    (var delta 0)
    (var weight 1)
    (var digit-idx 0)
    (while true
      (when (not (get input in-idx))
        (break))
      (def digit (cp-to-digit (get input in-idx)))
      (++ in-idx)
      # XXX: no overflow check
      (+= delta (* weight digit))
      (def thr (calc-threshold bias digit-idx))
      (when (< digit thr)
        (break))
      # XXX: no overflow check
      (*= weight (- base thr))
      (++ digit-idx))
    # number of potential character inserts for output
    (def n-pot-insrts (inc (length output)))
    (set bias
         (adapt delta n-pot-insrts (zero? i)))
    # XXX: no overflow check
    (+= curr-cp (div (+ delta i) n-pot-insrts))
    (set i (mod (+ delta i) n-pot-insrts))
    (assert (>= curr-cp initial-n)
            (string/format "unexpected basic code point: %n" curr-cp))
    (array/insert output i curr-cp)
    (++ i))
  #
  output)

# First code point  Last code point  Byte 1    Byte 2    Byte 3    Byte 4
# ----------------  ---------------  ------    ------    ------    ------
# U+0000            U+007F           0xxxxxxx
# U+0080            U+07FF           110xxxxx  10xxxxxx
# U+0800            U+FFFF           1110xxxx  10xxxxxx  10xxxxxx
# U+10000           U+10FFFF         11110xxx  10xxxxxx  10xxxxxx  10xxxxxx
#
# https://en.wikipedia.org/wiki/UTF-8
(defn cp-to-utf-8
  ``
  Given a code point `cp`, return a corresponding UTF-8 byte
  sequence in a buffer.

  `cp` should be in the range [0x0, 0x10ffff], but not in either of
  [0xd800, 0xdbff] or [0xdc00, 0xdfff].  (The latter two excluded
  ranges are used by UTF-16's surrogate pairs and are intentionally
  unused in UTF-8.)
  ``
  [cp]
  (def buf @"")
  (cond
    (< cp 0)
    (errorf "negative code point: %n" cp)
    #
    (<= cp 0x7f)
    (buffer/push buf cp)
    #
    (<= cp 0x7ff)
    (buffer/push buf
                 (bor 2r1100_0000
                      (band 2r1_1111 (brshift cp 6)))
                 (bor 2r1000_0000
                      (band 2r11_1111 cp)))
    #
    (<= 0xd800 cp 0xdbff)
    (errorf "unexpected high surrogate: %n" cp)
    #
    (<= 0xdc00 cp 0xdfff)
    (errorf "unexpected low surrogate: %n" cp)
    #
    (<= cp 0xffff)
    (buffer/push buf
                 (bor 2r1110_0000
                      (band 2r1111 (brshift cp 12)))
                 (bor 2r1000_0000
                      (band 2r11_1111 (brshift cp 6)))
                 (bor 2r1000_0000
                      (band 2r11_1111 cp)))
    #
    (<= cp 0x10ffff)
    (buffer/push buf
                 (bor 2r1111_0000
                      (band 2r111 (brshift cp 18)))
                 (bor 2r1000_0000
                      (band 2r11_1111 (brshift cp 12)))
                 (bor 2r1000_0000
                      (band 2r11_1111 (brshift cp 6)))
                 (bor 2r1000_0000
                      (band 2r11_1111 cp)))
    #
    (errorf "code point out of range: %n" cp))
  #
  buf)

(defn decode
  ``
  Decode punycode-encoded `input` into a buffer.

  If `buf` (buffer) is supplied, append the result to `buf`.
  Otherwise, append to a new buffer.
  ``
  [input &opt buf]
  (default buf @"")
  (->> (decode* input)
       (map cp-to-utf-8)
       splice
       (buffer/push buf)))

# from the rfc
(comment

  # XXX: have fun navigating the result in your editor...
  (decode "egbpdaj6bu4bxfgehfvwxn")
  # =>
  @"ليهمابتكلموشعربي؟"

  (decode "ihqwcrb4cv8a8dqg056pqjye")
  # =>
  @"他们为什么不说中文"

  (decode "ihqwctvzc91f659drss3x8bo0yb")
  # =>
  @"他們爲什麽不說中文"

  (decode "Proprostnemluvesky-uyb24dma41a")
  # =>
  @"Pročprostěnemluvíčesky"

  # XXX: have fun navigating the result in your editor...
  (decode "4dbcagdahymbxekheh6e0a7fei0b")
  # =>
  @"למההםפשוטלאמדבריםעברית"

  (decode "i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd")
  # =>
  @"यहलोगहिन्दीक्योंनहींबोलसकतेहैं"

  (decode "n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa")
  # =>
  @"なぜみんな日本語を話してくれないのか"

  (decode (string "989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5"
                  "xbh15a0dt30a5jpsd879ccm6fea98c"))
  # =>
  @"세계의모든사람들이한국어를이해한다면얼마나좋을까"

  (decode "b1abfaaepdrnnbgefbaDotcwatmq2g4l")
  # =>
  @"почемужеонинеговорятпорусски"

  (decode "PorqunopuedensimplementehablarenEspaol-fmd56a")
  # =>
  @"PorquénopuedensimplementehablarenEspañol"

  (decode "TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g")
  # =>
  @"TạisaohọkhôngthểchỉnóitiếngViệt"

  (decode "3B-ww4c5e180e575a65lsy2b")
  # =>
  @"3年B組金八先生"

  (decode "-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n")
  # =>
  @"安室奈美恵-with-SUPER-MONKEYS"

  (decode "Hello-Another-Way--fc4qua05auwb3674vfr0b")
  # =>
  @"Hello-Another-Way-それぞれの場所"

  (decode "2-u9tlzr9756bt3uc0v")
  # =>
  @"ひとつ屋根の下2"

  (decode "MajiKoi5-783gue6qz075azm5e")
  # =>
  @"MajiでKoiする5秒前"

  (decode "de-jg4avhby1noc0d")
  # =>
  @"パフィーdeルンバ"

  (decode "d9juau41awczczp")
  # =>
  @"そのスピードで"

  (decode "-> $1.00 <--")
  # =>
  @"-> $1.00 <-"

  )

# from https://en.wikipedia.org/wiki/Punycode
(comment

  (decode "bcher-kva")
  # =>
  @"bücher"

  (decode "Mnchen-0st-9db")
  # =>
  @"M\xC3\xBCnchen-0st"

  (decode "hq1bm8jm9l")
  # =>
  @"도메인"

  )

## encoding

# 6.3 Encoding procedure
#
#    let n = initial_n
#    let delta = 0
#    let bias = initial_bias
#    let h = b = the number of basic code points in the input
#    copy them to the output in order, followed by a delimiter if b > 0
#    {if the input contains a non-basic code point < n then fail}
#    while h < length(input) do begin
#      let m = the minimum {non-basic} code point >= n in the input
#      let delta = delta + (m - n) * (h + 1), fail on overflow
#      let n = m
#      for each code point c in the input (in order) do begin
#        if c < n {or c is basic} then increment delta, fail on overflow
#        if c == n then begin
#          let q = delta
#          for k = base to infinity in steps of base do begin
#            let t = tmin if k <= bias {+ tmin}, or
#                    tmax if k >= bias + tmax, or k - bias otherwise
#            if q < t then break
#            output the code point for digit t + ((q - t) mod (base - t))
#            let q = (q - t) div (base - t)
#          end
#          output the code point for digit q
#          let bias = adapt(delta, h + 1, test h equals b?)
#          let delta = 0
#          increment h
#        end
#      end
#      increment delta and n
#    end

(defn find-min-less-than
  [n input]
  (var res nil)
  (each elt input
    (when (<= initial-n n elt)
      (if (nil? res)
        (set res elt)
        (when (< elt res)
          (set res elt)))))
  #
  res)

(defn encode*
  [input-cps]
  (var n initial-n)
  (var delta 0)
  (var bias initial-bias)
  # copy any basic code points to output
  (def output
    (filter |(< $ initial-n) input-cps))
  # number of basic code points in input-cps
  (def b (length output))
  # add a delimiter to the output if there were any basic code points
  (when (pos? b)
    (array/push output (get delimiter 0)))
  (def in-len (length input-cps))
  (var h b)
  (while (< h in-len)
    (def m (find-min-less-than n input-cps))
    #(printf "m: %n" m)
    (+= delta
        (* (- m n) (inc h)))
    #(printf "delta: %n" delta)
    (set n m)
    (each cp input-cps
      (when (or (< cp n)
                (< cp initial-n))
        # XXX: not checking for overflow
        (++ delta))
      (when (= cp n)
        (var q delta)
        (var digit-idx 0)
        (while true
          (def thr (calc-threshold bias digit-idx))
          (when (< q thr)
            (break))
          (array/push output
                      (digit-to-cp (+ thr
                                      (mod (- q thr) (- base thr)))))
          (set q (div (- q thr)
                      (- base thr)))
          (++ digit-idx))
        (array/push output (digit-to-cp q))
        #(printf "bias before: %n" bias)
        (set bias
             (adapt delta (inc h) (= h b)))
        #(printf "bias after: %n" bias)
        (set delta 0)
        (++ h)))
    (++ delta)
    (++ n))
  #
  output)

(defn parse-code-point
  [bytes i]
  # https://stackoverflow.com/questions/9356169/utf-8-continuation-bytes
  (defn cont-byte?
    [byte]
    (= 2r1000_0000 (band 2r1100_0000 byte)))
  #
  (def byte-1 (get bytes i))
  (cond
    # 1-byte sequence
    (<= byte-1 2r0111_1111)
    [byte-1 1]
    # leading bytes should not be of the form 10xx_xxxx
    (<= # 2r1000_0000
        byte-1 2r1011_1111)
    (errorf "unexpected leading byte: %n at index: %d" byte-1 i)
    # 2-byte sequence - starts with 110x_xxxx
    (<= # 2r1100_0000
        byte-1 2r1101_1111)
    (do
      (assert (< (+ i 1) (length bytes))
              (string/format "truncated 2-byte utf-8 seq at index: %d" i))
      (def byte-2 (get bytes (+ i 1)))
      (assert (cont-byte? byte-2)
              (string/format "not continuation byte at index: %d" (+ i 1)))
      [(+ (blshift (band 2r01_1111 byte-1) 6)
          (band 2r11_1111 byte-2))
       2])
    #
    # if the surrogate pair ranges [0xd800, 0xdbff] and [0xdc00, 0xdfff]
    # got turned into utf-8 byte sequences (which they shouldn't),
    # they would occupy (see misc.janet):
    #
    #   [0xEDA080, 0xEDAFBF]
    #   [0xEDAFC0, 0xEDBFBF]
    #
    # but there are "legit" things that use a leading byte of 0xED, so
    # would need to examine later bytes to tell if there is an error...
    #
    # 3-byte sequence - starts with 1110_xxxx
    (<= # 2r1110_0000
        byte-1 2r1110_1111)
    (do
      (assert (< (+ i 2) (length bytes))
              (string/format "truncated 3-byte utf-8 seq near index: %d" i))
      (def byte-2 (get bytes (+ i 1)))
      (assert (cont-byte? byte-2)
              (string/format "not continuation byte at index: %d" (+ i 1)))
      (def byte-3 (get bytes (+ i 2)))
      (assert (cont-byte? byte-3)
              (string/format "not continuation byte at index: %d" (+ i 2)))
      [(+ (blshift (band 2r00_1111 byte-1) 12)
          (blshift (band 2r11_1111 byte-2) 6)
          (band 2r11_1111 byte-3))
       3])
    # 4-byte sequence - starts with 1111_0xxx
    (<= # 2r1111_0000
        byte-1 2r1111_0111)
    (do
      (assert (< (+ i 3) (length bytes))
              (string/format "truncated 4-byte utf-8 seq near index: %d" i))
      (def byte-2 (get bytes (+ i 1)))
      (assert (cont-byte? byte-2)
              (string/format "not continuation byte at index: %d" (+ i 1)))
      (def byte-3 (get bytes (+ i 2)))
      (assert (cont-byte? byte-3)
              (string/format "not continuation byte at index: %d" (+ i 2)))
      (def byte-4 (get bytes (+ i 3)))
      (assert (cont-byte? byte-4)
              (string/format "not continuation byte at index: %d" (+ i 3)))
      [(+ (blshift (band 2r00_0111 byte-1) 18)
          (blshift (band 2r11_1111 byte-2) 12)
          (blshift (band 2r11_1111 byte-3) 6)
          (band 2r11_1111 byte-4))
       4])
    #
    (errorf "invalid byte: %n at index: %d" byte-1 i)))

(defn encode
  ``
  Given `input`, return a punycode-encoded result as a buffer.

  If `buf` (buffer) is supplied, append the result to `buf`.
  Otherwise, append to a new buffer.
  ``
  [input &opt buf]
  (default buf @"")
  (def input-cps @[])
  (var i 0)
  (while (< i (length input))
    (let [[cp j] (parse-code-point input i)]
      (array/push input-cps cp)
      (+= i j)))
  (def output (encode* input-cps))
  #
  (buffer/push buf ;output))

(comment

  (encode* [97])
  # =>
  @[97 45]

  (encode "a")
  # =>
  @"a-"

  (encode* [0x0033 0x5E74 0x0042 0x7D44 0x91D1 0x516B 0x5148 0x751F])
  # =>
  @[51 66 45 119 119 52 99 53 101 49 56 48 101 53 55 53 97 54 53
    108 115 121 50 98]

  (encode "3年B組金八先生")
  # =>
  @"3B-ww4c5e180e575a65lsy2b"

  (encode* @[77 252 110 99 104 101 110 45 79 115 116])
  # =>
  @[77 110 99 104 101 110 45 79 115 116 45 57 100 98]

  (encode "München-Ost")
  # =>
  @"Mnchen-Ost-9db"

  )
