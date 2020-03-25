---
layout: post
title: Reverse Vowels of a String
date: 2020-03-25 06:42:00-8000
author: me
category: leetcode
tags: [leetcode easy, python]
keywords: [leetcode easy, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Reverse Vowels of a String](https://leetcode.com/problems/reverse-vowels-of-a-string/)

### Problem

Write a function that takes a string as input and reverse only the vowels of a string.

The vowels does not include the letter `"y"`.

Example inputs:

```
Input: "hello"
Output: "holle"

Input: "leetcode"
Output: "leotcede"
```

### Thinking

Initial thought was a [queue](https://en.wikibooks.org/wiki/Data_Structures/Stacks_and_Queues") as the data structure to use here. However, [stack](https://en.wikibooks.org/wiki/Data_Structures/Stacks_and_Queues") is what I wanted, I was just tired and messed up my ordering.

I spent some more time thinking about this and it can be solved with a double pointer iteration as well. This is likely the optimal implementation as it does not require double iteration, `O(2n)`.

In short, my thinking for a naive soltuion was this:

Iterate over the string once, storing all vowels in the stack.

Iterate over it again to build the result string, use consonants when you find them. When you find a vowel, pop from the stack instead and continue.

### Corner Cases

The following corner cases are what I missed in my initial solution:

* I forgot to include capital letters in my frozenset for determine vowel vs. consonant. :facepalm:

### Improvements

As mentioned above, a double pointer (head/tail) iteration would be faster and use less memory.

### Solution

```python
class Solution:
    vowel_chars = frozenset(['a', 'A', 'e', 'E', 'i', 'I', 'o', 'O', 'u', 'U'])

    def __init__(self):
        self.vowels = []

    def is_vowel(self, c):
        return c in self.vowel_chars

    def is_consonant(self, c):
        return not self.is_vowel(c)

    def reverseVowels(self, s: str) -> str:
        result = ''

        for c in s:
            if self.is_vowel(c):
                self.vowels.append(c)
            else:
                continue

        for c in s:
            if self.is_vowel(c):
                result += self.vowels.pop()
            else:
                result += c

        return result
```

### Score

```
Runtime: 84 ms, faster than 16.99% of Python3 online submissions for Reverse Vowels of a String.
Memory Usage: 14.1 MB, less than 93.33% of Python3 online submissions for Reverse Vowels of a String.
```