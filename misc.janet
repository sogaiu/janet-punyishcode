(import ./punyishcode :as p)

# XXX: sample data below seems to not use any unicode code point that
#      is greater than u+ffff -- i.e. there doesn't appear to be any
#      non-bmp example.
#
#      quoting the rfc:
#
#        Although the only restriction Punycode imposes on the input
#        integers is that they be nonnegative, these parameters are
#        especially designed to work well with Unicode [UNICODE] code
#        points, which are integers in the range 0..10FFFF (but not
#        D800..DFFF, which are reserved for use by the UTF-16 encoding
#        of Unicode).
#
#      so i guess the sample data is kind of misleading...

``
   (A) Arabic (Egyptian):
       u+0644 u+064A u+0647 u+0645 u+0627 u+0628 u+062A u+0643 u+0644
       u+0645 u+0648 u+0634 u+0639 u+0631 u+0628 u+064A u+061F
       Punycode: egbpdaj6bu4bxfgehfvwxn

   (B) Chinese (simplified):
       u+4ED6 u+4EEC u+4E3A u+4EC0 u+4E48 u+4E0D u+8BF4 u+4E2D u+6587
       Punycode: ihqwcrb4cv8a8dqg056pqjye

   (C) Chinese (traditional):
       u+4ED6 u+5011 u+7232 u+4EC0 u+9EBD u+4E0D u+8AAA u+4E2D u+6587
       Punycode: ihqwctvzc91f659drss3x8bo0yb

   (D) Czech: Pro<ccaron>prost<ecaron>nemluv<iacute><ccaron>esky
       U+0050 u+0072 u+006F u+010D u+0070 u+0072 u+006F u+0073 u+0074
       u+011B u+006E u+0065 u+006D u+006C u+0075 u+0076 u+00ED u+010D
       u+0065 u+0073 u+006B u+0079
       Punycode: Proprostnemluvesky-uyb24dma41a

   (E) Hebrew:
       u+05DC u+05DE u+05D4 u+05D4 u+05DD u+05E4 u+05E9 u+05D5 u+05D8
       u+05DC u+05D0 u+05DE u+05D3 u+05D1 u+05E8 u+05D9 u+05DD u+05E2
       u+05D1 u+05E8 u+05D9 u+05EA
       Punycode: 4dbcagdahymbxekheh6e0a7fei0b

   (F) Hindi (Devanagari):
       u+092F u+0939 u+0932 u+094B u+0917 u+0939 u+093F u+0928 u+094D
       u+0926 u+0940 u+0915 u+094D u+092F u+094B u+0902 u+0928 u+0939
       u+0940 u+0902 u+092C u+094B u+0932 u+0938 u+0915 u+0924 u+0947
       u+0939 u+0948 u+0902
       Punycode: i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd

   (G) Japanese (kanji and hiragana):
       u+306A u+305C u+307F u+3093 u+306A u+65E5 u+672C u+8A9E u+3092
       u+8A71 u+3057 u+3066 u+304F u+308C u+306A u+3044 u+306E u+304B
       Punycode: n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa

   (H) Korean (Hangul syllables):
       u+C138 u+ACC4 u+C758 u+BAA8 u+B4E0 u+C0AC u+B78C u+B4E4 u+C774
       u+D55C u+AD6D u+C5B4 u+B97C u+C774 u+D574 u+D55C u+B2E4 u+BA74
       u+C5BC u+B9C8 u+B098 u+C88B u+C744 u+AE4C
       Punycode: 989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5j\
                 psd879ccm6fea98c

   (I) Russian (Cyrillic):
       U+043F u+043E u+0447 u+0435 u+043C u+0443 u+0436 u+0435 u+043E
       u+043D u+0438 u+043D u+0435 u+0433 u+043E u+0432 u+043E u+0440
       u+044F u+0442 u+043F u+043E u+0440 u+0443 u+0441 u+0441 u+043A
       u+0438
       Punycode: b1abfaaepdrnnbgefbaDotcwatmq2g4l

   (J) Spanish: Porqu<eacute>nopuedensimplementehablarenEspa<ntilde>ol
       U+0050 u+006F u+0072 u+0071 u+0075 u+00E9 u+006E u+006F u+0070
       u+0075 u+0065 u+0064 u+0065 u+006E u+0073 u+0069 u+006D u+0070
       u+006C u+0065 u+006D u+0065 u+006E u+0074 u+0065 u+0068 u+0061
       u+0062 u+006C u+0061 u+0072 u+0065 u+006E U+0045 u+0073 u+0070
       u+0061 u+00F1 u+006F u+006C
       Punycode: PorqunopuedensimplementehablarenEspaol-fmd56a

   (K) Vietnamese:
       T<adotbelow>isaoh<odotbelow>kh<ocirc>ngth<ecirchookabove>ch\
       <ihookabove>n<oacute>iti<ecircacute>ngVi<ecircdotbelow>t
       U+0054 u+1EA1 u+0069 u+0073 u+0061 u+006F u+0068 u+1ECD u+006B
       u+0068 u+00F4 u+006E u+0067 u+0074 u+0068 u+1EC3 u+0063 u+0068
       u+1EC9 u+006E u+00F3 u+0069 u+0074 u+0069 u+1EBF u+006E u+0067
       U+0056 u+0069 u+1EC7 u+0074
       Punycode: TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g

   (L) 3<nen>B<gumi><kinpachi><sensei>
       u+0033 u+5E74 U+0042 u+7D44 u+91D1 u+516B u+5148 u+751F
       Punycode: 3B-ww4c5e180e575a65lsy2b

   (M) <amuro><namie>-with-SUPER-MONKEYS
       u+5B89 u+5BA4 u+5948 u+7F8E u+6075 u+002D u+0077 u+0069 u+0074
       u+0068 u+002D U+0053 U+0055 U+0050 U+0045 U+0052 u+002D U+004D
       U+004F U+004E U+004B U+0045 U+0059 U+0053
       Punycode: -with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n

   (N) Hello-Another-Way-<sorezore><no><basho>
       U+0048 u+0065 u+006C u+006C u+006F u+002D U+0041 u+006E u+006F
       u+0074 u+0068 u+0065 u+0072 u+002D U+0057 u+0061 u+0079 u+002D
       u+305D u+308C u+305E u+308C u+306E u+5834 u+6240
       Punycode: Hello-Another-Way--fc4qua05auwb3674vfr0b

   (O) <hitotsu><yane><no><shita>2
       u+3072 u+3068 u+3064 u+5C4B u+6839 u+306E u+4E0B u+0032
       Punycode: 2-u9tlzr9756bt3uc0v

   (P) Maji<de>Koi<suru>5<byou><mae>
       U+004D u+0061 u+006A u+0069 u+3067 U+004B u+006F u+0069 u+3059
       u+308B u+0035 u+79D2 u+524D
       Punycode: MajiKoi5-783gue6qz075azm5e

   (Q) <pafii>de<runba>
       u+30D1 u+30D5 u+30A3 u+30FC u+0064 u+0065 u+30EB u+30F3 u+30D0
       Punycode: de-jg4avhby1noc0d

   (R) <sono><supiido><de>
       u+305D u+306E u+30B9 u+30D4 u+30FC u+30C9 u+3067
       Punycode: d9juau41awczczp

   (S) -> $1.00 <-
       u+002D u+003E u+0020 u+0024 u+0031 u+002E u+0030 u+0030 u+0020
       u+003C u+002D
       Punycode: -> $1.00 <--
``

(comment

  # six digits
  # U+100000 - first private use code point
  #
  # https://en.wikipedia.org/wiki/Private_Use_Areas#Private_Use_Areas
  (deep= (p/cp-to-utf-8 (scan-number "0x100000"))
         @"\xF4\x80\x80\x80")
  # =>
  true

  # five digits
  # U+10900 - first phoenician code point (local font can display)
  #
  # https://en.wikibooks.org/wiki/Unicode/Character_reference/10000-10FFF
  (deep= (p/cp-to-utf-8 (scan-number "0x10900"))
         @"\xF0\x90\xA4\x80")
  # =>
  true

  # four digits
  # U+0020 - our familiar friend
  (deep= (p/cp-to-utf-8 (scan-number "0x0020"))
         @"\x20")
  # =>
  true

  )

(defn cpn-to-str
  ``
  Convert a "code point notated" string `cpn-str` to a janet string.

  `cpn-str` is a whitespace-separated string consisting of strings
  starting with 'u' or 'U' and continuing with 4 through 6 hex digits,
  e.g. U+0020, u+10900, u+100000.

  The motivation for this function was to make it easier to work with
  the notation used in the examples from RFC3492, e.g.

    u+4ED6 u+4EEC u+4E3A u+4EC0 u+4E48 u+4E0D u+8BF4 u+4E2D u+6587
  ``
  [cpn-str]
  (def a-peg
    ~{:main (sequence (some (choice :ws :cp)) -1)
      :ws (set " \n\r\t")
      :cp (cmt (sequence (set "uU") "+"
                         # 4 to 6 digits inclusive - Unicode Section A.1
                         (number (between 4 6 :h) 16))
               ,|(do
                   # XXX
                   #(pp $)
                   (p/cp-to-utf-8 $)))})
  (-?> (peg/match a-peg cpn-str)
       (string/join "")))

(comment

  # in emacs, C-x 8 <Enter> followed by code point value to enter
  # unicode

  # six digits
  # U+100000 - first private use code point
  #
  # https://en.wikipedia.org/wiki/Private_Use_Areas#Private_Use_Areas
  (= (cpn-to-str "U+100000")
     "\xF4\x80\x80\x80"
     "􀀀")
  # =>
  true

  # five digits
  # U+10900 - first phoenician code point (local font can display)
  #
  # https://en.wikibooks.org/wiki/Unicode/Character_reference/10000-10FFF
  (= (cpn-to-str "U+10900")
     "\xF0\x90\xA4\x80"
     "𐤀")
  # =>
  true

  # four digits
  # U+0020 - our familiar friend
  (= (cpn-to-str "U+0020")
     "\x20"
     " ")
  # =>
  true

  (= (cpn-to-str
       (string "u+4ED6 u+4EEC u+4E3A u+4EC0 u+4E48 u+4E0D u+8BF4 "
               "u+4E2D u+6587"))
     (string "\xE4\xBB\x96\xE4\xBB\xAC\xE4\xB8\xBA\xE4\xBB\x80\xE4\xB9"
             "\x88\xE4\xB8\x8D\xE8\xAF\xB4\xE4\xB8\xAD\xE6\x96\x87")
     "他们为什么不说中文")
  # =>
  true

  (= (cpn-to-str
       (string "u+30D1 u+30D5 u+30A3 u+30FC u+0064 u+0065 u+30EB "
               "u+30F3 u+30D0"))
     (string "\xE3\x83\x91\xE3\x83\x95\xE3\x82\xA3\xE3\x83\xBCde\xE3\x83"
             "\xAB\xE3\x83\xB3\xE3\x83\x90")
     "パフィーdeルンバ")
  # =>
  true

  (= (cpn-to-str
       "u+3072 u+3068 u+3064 u+5C4B u+6839 u+306E u+4E0B u+0032")
     "\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B\u0032"
     (string "\xE3\x81\xB2\xE3\x81\xA8\xE3\x81\xA4\xE5\xB1\x8B\xE6\xA0\xB9"
             "\xE3\x81\xAE\xE4\xB8\x8B2")
     "ひとつ屋根の下2")
  # =>
  true

  (= (cpn-to-str "u+305D u+306E u+30B9 u+30D4 u+30FC u+30C9 u+3067")
     (string "\xE3\x81\x9D\xE3\x81\xAE\xE3\x82\xB9\xE3\x83\x94\xE3\x83\xBC"
             "\xE3\x83\x89\xE3\x81\xA7")
     "そのスピードで")
  # =>
  true

  (cpn-to-str
    (string
      "  u+002D u+003E u+0020 u+0024 u+0031 u+002E u+0030 u+0030 u+0020\n"
      "  u+003C u+002D"))
  # =>
  "-> $1.00 <-"

  )

(defn round-trip
  [input]
  (p/encode (p/decode input)))

# from the rfc
(comment

  (let [in @"egbpdaj6bu4bxfgehfvwxn"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"ihqwcrb4cv8a8dqg056pqjye"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"ihqwctvzc91f659drss3x8bo0yb"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"Proprostnemluvesky-uyb24dma41a"]
    (deep= in
           (round-trip in)))
  # =>
  true

  # XXX: have fun navigating the result in your editor...
  (let [in @"4dbcagdahymbxekheh6e0a7fei0b"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in (buffer "989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5"
                   "xbh15a0dt30a5jpsd879ccm6fea98c")]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"b1abfaaepdrnnbgefbaDotcwatmq2g4l"]
    (deep= (buffer (string/ascii-lower in))
           (round-trip in)))
  # =>
  true

  (let [in @"PorqunopuedensimplementehablarenEspaol-fmd56a"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"3B-ww4c5e180e575a65lsy2b"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"Hello-Another-Way--fc4qua05auwb3674vfr0b"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"2-u9tlzr9756bt3uc0v"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"MajiKoi5-783gue6qz075azm5e"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"de-jg4avhby1noc0d"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"d9juau41awczczp"]
    (deep= in
           (round-trip in)))
  # =>
  true

  (let [in @"-> $1.00 <--"]
    (deep= in
           (round-trip in)))
  # =>
  true

  )

# scratch work for seeing what would happen to 0xd800 - 0xdfff
# (stuff that utf-8 should not be using)
(comment

  (def buf @"")

  (def cp 0xd800)

  (buffer/push buf
               (bor 2r1110_0000
                    (band 2r1111 (brshift cp 12)))
               (bor 2r1000_0000
                    (band 2r11_1111 (brshift cp 6)))
               (bor 2r1000_0000
                    (band 2r11_1111 cp)))
  # =>
  @"\xED\xA0\x80"

  2r1110_1101 2r1010_0000 2r1000_0000

  0xed 0xa0 0x80

  (def buf @"")

  (def cp 0xdbff)

  (buffer/push buf
               (bor 2r1110_0000
                    (band 2r1111 (brshift cp 12)))
               (bor 2r1000_0000
                    (band 2r11_1111 (brshift cp 6)))
               (bor 2r1000_0000
                    (band 2r11_1111 cp)))
  # =>
  @"\xED\xAF\xBF"

  (def buf @"")

  (def cp 0xdfff)

  (buffer/push buf
               (bor 2r1110_0000
                    (band 2r1111 (brshift cp 12)))
               (bor 2r1000_0000
                    (band 2r11_1111 (brshift cp 6)))
               (bor 2r1000_0000
                    (band 2r11_1111 cp)))
  # =>
  @"\xED\xBF\xBF"

  2r1110_1101 2r1011_1111 2r1011_1111

  0xed 0xbf 0xbf

  )
