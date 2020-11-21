---
layout: post
title: String to Integer (atoi)
date: 2020-11-20 8:04:00-8000
author: me
category: leetcode
tags: [leetcode medium, python]
keywords: [leetcode medium, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [String to Integer (atoi)](https://leetcode.com/problems/string-to-integer-atoi/)

![String to integer comment screenshot](/assets/images/posts/string-to-integer-comment.jpg)

Sounds about right :/

### Problem

Implement `atoi` which converts a string to an integer.

The function first discards as many whitespace characters as necessary until the first non-whitespace character is found. Then, starting from this character takes an optional initial plus or minus sign followed by as many numerical digits as possible, and interprets them as a numerical value.

The string can contain additional characters after those that form the integral number, which are ignored and have no effect on the behavior of this function.

If the first sequence of non-whitespace characters in str is not a valid integral number, or if no such sequence exists because either str is empty or it contains only whitespace characters, no conversion is performed.

If no valid conversion could be performed, a zero value is returned.

**Note:**

* Only the space character `' '` is considered a whitespace character.
* Assume we are dealing with an environment that could only store integers within the 32-bit signed integer range: `[−2^31,  2^31 − 1]`. If the numerical value is out of the range of representable values, `2^31 − 1` or `−2^31` is returned.

Example 1:

```
Input: str = "42"
Output: 42
```

Example 2:

```
Input: str = "   -42"
Output: -42
Explanation: The first non-whitespace character is '-', which is the minus sign. Then take as many numerical digits as possible, which gets 42.
```

Example 3:

```
Input: str = "4193 with words"
Output: 4193
Explanation: Conversion stops at digit '3' as the next character is not a numerical digit.
```

Example 4:

```
Input: str = "words and 987"
Output: 0
Explanation: The first non-whitespace character is 'w', which is not a numerical digit or a +/- sign. Therefore no valid conversion could be performed.
```

Example 5:

```
Input: str = "-91283472332"
Output: -2147483648
Explanation: The number "-91283472332" is out of the range of a 32-bit signed integer. Thefore INT_MIN (−231) is returned.
```

### Thinking

It doesn't feel like there is anything exciting here in terms of algorithms or specific data structures. That's refreshing. Just read the string, capture the sign, capture the number, and convert. Converting a string to a number, without using something like `int()` is as follows:

* Read characters in reverse order
* Sum digits with `sum += digit_value * 10 ^ place`, e.g. `sum += 4 * 10^0` is equal to `4`.

### Corner Cases

I don't think I missed any this time.

### Improvements

Code could be cleaned up a bit. I think I can change the math to not read the full number and then reverse. I'd have to think of that some more, however, we know the constraints on number of digits so a reverse iteration is going to be fast.

### Solution

```python
class Solution:
    def myAtoi(self, s: str) -> int:
        # Convert the given string to a pos/neg integer.
        def str_to_i(s: str, sign: int) -> int:
            v = 0
            for i, c in enumerate(reversed(s)):
                v += (ord(c) - 48) * 10**i
                i += 1
            return v * sign

        # Return True if the str is a digit, False otherwise.
        def is_digit(s: str) -> bool:
            return 48 <= ord(s) <= 57
        
        # Empty string, no bueno.
        if not s:
            return 0
        
        N = len(s)
        i = 0
        sign = 1
        
        # Chomp whitespace.
        while i < N and s[i] == ' ':
            i += 1

        # Capture sign. If value is not +/- or digit, it's invalid.
        if i < N and s[i] == '+':
            sign = 1
            i += 1
        elif i < N and s[i] == '-':
            sign = -1
            i += 1
        elif i < N and not is_digit(s[i]):
            return 0

        # Read digits until any non digit.
        j = i
        while j < N and is_digit(s[j]):
            j += 1

        # Extract number from (i, j) slice and convert to int.
        number = str_to_i(s[i:j], sign)
        
        # Apply bounds.
        if number < -2**31:
            return -2**31
        if number > 2**31-1:
            return 2**31 - 1
        return number

```

### Score

```
Runtime: 40 ms, faster than 13.02% of Python3 online submissions for String to Integer (atoi).
Memory Usage: 14.3 MB, less than 8.38% of Python3 online submissions for String to Integer (atoi).
```