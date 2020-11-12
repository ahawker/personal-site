---
layout: post
title: ULID's in Python
date: 2019-11-05 17:53:00-8000
author: me
category: writings
tags: [ulid, ulid-py, tutorial]
keywords: [ulid, ulid-py]
---

ULID stands for Universally Unique Lexicographically Sortable Identifier.

In short, their goal is to provide an alternative to [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) values where sortability is required while still maintaining similar uniqueness guarantees. This is achieved by storing the creation time of the identifier, at millisecond precision, within the value itself at the cost of reduced entropy.

Check out the full [specification](https://github.com/ulid/spec) for more technical details.

### Goal

This post is a deeper dive into ULID's to examine their anatomy using python and the [ulid-py](https://github.com/ahawker/ulid) package. For additional examples, check out the [official docs](https://ulid.readthedocs.io/en/latest/?badge=latest) or [ulid-py](https://github.com/ahawker/ulid) repository on GitHub.

### Getting started

Install the [ulid-py](https://github.com/ahawker/ulid) package from [pypi](https://pypi.org/project/ulid-py/) using [pip](https://pypi.org/project/pip/).

```bash
$ pip install ulid-py
$ python
>>> import ulid
```

### Structure

A ULID is a 128 bit/16 byte/26 character value with the [most significant bit](https://en.wikipedia.org/wiki/Bit_numbering#Most_significant_bit) first. [^1]

[^1]: Big endian/network byte order <https://en.wikipedia.org/wiki/Endianness>

The [ULID](https://ulid.readthedocs.io/en/latest/ulid.html#ulid.ulid.ULID) type supports a number of different representations.

```python
>>> value = ulid.new()
>>> value
<ULID('01DSEY8C4PD630AZR8T2V2DPZ9')>
>>> str(value)
'01DSEY8C4PD630AZR8T2V2DPZ9'
>>> value.str
'01DSEY8C4PD630AZR8T2V2DPZ9'
>>> value.int
1902284993375057434767769928441715689
>>> value.bytes
b'\x01n]\xe40\x96i\x86\x05\x7f\x08\xd0\xb6&\xdb\xe9'
>>> value.uuid
UUID('016e5de4-3096-6986-057f-08d0b626dbe9')
```

A ULID value is composed of two parts: [timestamp](./#timestamp) and [randomness](./#randomness).

```
 01DSEY8C4P    D630AZR8T2V2DPZ9
|----------|  |----------------|
 Timestamp        Randomness
```

### Timestamp

The timestamp value is stored in the first 48 bits/6 bytes/10 characters. It is a Unix timestamp in milliseconds. [^2]

[^2]: Unix time <https://en.wikipedia.org/wiki/Unix_time>

The [Timestamp](https://ulid.readthedocs.io/en/latest/ulid.html#ulid.ulid.Timestamp) type supports a number of different representations.

```python
>>> ts = value.timestamp()
>>> ts
<Timestamp('01DSEY8C4P')>
>>> str(ts)
'01DSEY8C4P'
>>> ts.str
'01DSEY8C4P'
>>> ts.int
1573533266070
>>> ts.bytes
b'\x01n]\xe40\x96'
>>> ts.datetime
datetime.datetime(2019, 11, 12, 4, 34, 26, 70000)
>>> ts.timestamp
1573533266.07
```

### Randomness

The randomness value is stored in the remaining 80 bits/8 bytes/16 characters. It is a cryptographically secure random value. [^3]

[^3]: Pseudorandom number generators (PRNG) <https://en.wikipedia.org/wiki/Pseudorandom_number_generator>

The [Randomess](https://ulid.readthedocs.io/en/latest/ulid.html#ulid.ulid.Randomness) type supports a number of different representations.

```python
>>> rnd = value.randomness()
>>> rnd
<Randomness('D630AZR8T2V2DPZ9')>
>>> str(rnd)
'D630AZR8T2V2DPZ9'
>>> rnd.str
'D630AZR8T2V2DPZ9'
>>> rnd.int
498320740452174561467369
>>> rnd.bytes
b'i\x86\x05\x7f\x08\xd0\xb6&\xdb\xe9'
```



### Crockford's Base32

When represented as a string, ULID's use Crockford's Base32 encoding. This encoding uses 5 bits per character, gaining an extra bit per character over hexadecimal (Base16). Crockford's implementation excludes the letters "I", "L", and "O" to avoid visual confusion with digits "0" and "1". It also excludes the letter "U" to reduce likelyhood of obsenities.[^4]

[^4]: Crockford's Base32 <https://en.wikipedia.org/wiki/Base32#Crockford's_Base32>

```python
>>> ulid.base32.ENCODING
'0123456789ABCDEFGHJKMNPQRSTVWXYZ'
```

Crockford's Base32 is case insensitive and only encodes uppercase characters, e.g. "a" and "A" both encode to the letter "A". Upper and lowercase letters decode to the same value, e.g. "a" and "A" both to the numeric value of 10.

```python
>>> ulid.base32.DECODING[ord('a')]
10
>>> ulid.base32.DECODING[ord('A')]
10
```

The [base32](https://ulid.readthedocs.io/en/latest/base32.html) module supports a number of encoding/decoding functions. When the exact part of data you're dealing with is known, use the `encode_{part}` or `decode_{part}` functions for optimal performance. If unsure, use the `encode` and `decode` functions as they will try and determine it. Choosing between these is just a minor performance optimization.

```python
>>> value.bytes
b'\x01n]\xe40\x96i\x86\x05\x7f\x08\xd0\xb6&\xdb\xe9'
>>> value.timestamp().bytes
b'\x01n]\xe40\x96'
>>> value.randomness().bytes
b'i\x86\x05\x7f\x08\xd0\xb6&\xdb\xe9'

>>> ulid.base32.encode_ulid(value.bytes)
'01DSEY8C4PD630AZR8T2V2DPZ9'
>>> ulid.base32.encode_timestamp(value.timestamp().bytes)
'01DSEY8C4P'
>>> ulid.base32.encode_randomness(value.randomness().bytes)
'D630AZR8T2V2DPZ9'

>>> ulid.base32.encode(value.bytes)
'01DSEY8C4PD630AZR8T2V2DPZ9'
>>> ulid.base32.encode(value.timestamp().bytes)
'01DSEY8C4P'
>>> ulid.base32.encode(value.randomness().bytes)
'D630AZR8T2V2DPZ9'
```

### Sorting

Since the [timestamp](./#timestamp) value is the first 48 bits/6 bytes/10 characters of a ULID value, they can be lexicographically sorted with millisecond precision. The ulid spec also defines support for monotonically[^5] increasing randomness values to maintain sort order within the same millisecond. However, due to some questions/concerns/discussion[^6] around the implementation, it is not _yet_ supported by the `ulid-py` package.

**Update (11/10/2020):** As of Sept. 2020, in the `1.1.0` release, the `ulid-py` package has monotonic support. It has implementations using a lock protected counter or using microsecond precision clocks.

[^5]: Follow issue [#11](https://github.com/ulid/spec/issues/11) on the ULID spec repository for more information about problems with supporting sub-millisecond sorting.
[^6]: Follow issue [#306](https://github.com/ulid/spec/issues/11) on the `ulid-py` repository for more information.

```python
>>> u1 = ulid.new()
>>> u1
<ULID('01DSM8753B0P968WJPXRS90SWW')>
>>> u2 = ulid.new()
>>> u2
<ULID('01DSM87EBMQXB12TA1VK4APBD9')>
>>> u3 = ulid.from_timestamp(2678249158)
>>> u3
<ULID('02DYA1DXBGE7BT0XGJ64G7KWFA')>
>>> u3.timestamp().datetime
datetime.datetime(2054, 11, 14, 6, 5, 58)
>>> u1 < u2 < u3
True
```

## Pros/Cons

ULID's aren't the panacea of identifiers but definitely have their place.

Consider them when:

* Sortability is necessary
* Identifier length is important
* No means for additional metadata retrieval such as creation time

Avoid them when:

* Sortability must be sub-millisecond (at least until issues resolved)
* Exposing the creation time in the identifier is considered information leakage
* Compatibility with many languages/platforms/architectures is required

In general, ULID's provide a nice alternative to [UUID's](https://en.wikipedia.org/wiki/Universally_unique_identifier) in cases where sortability and visual appeal of the identifier takes priority over the loss of entropy and universal language/platform support.

## To be continued...

The next blog post in this series will discuss using ULID's with the Django web framework. Stay tuned!

---
