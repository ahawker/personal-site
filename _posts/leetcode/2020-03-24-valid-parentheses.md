---
layout: post
title: Valid Parentheses
date: 2020-03-24 07:21:00-8000
author: me
category: leetcode
tags: [leetcode easy, python]
keywords: [leetcode easy, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Valid Parentheses](https://leetcode.com/problems/valid-parentheses/)

### Problem

Given a string containing just the characters `'(', ')', '{', '}', '[' and ']'`, determine if the input string is valid.

An input string is valid if:

Open brackets must be closed by the same type of brackets.
Open brackets must be closed in the correct order.
Note that an empty string is also considered valid.

Example inputs:

```
Input: "()"
Output: true

Input: "()[]{}"
Output: true

Input: "(]"
Output: false

Input: "([)]"
Output: false

Input: "{[]}"
Output: true
```

### Thinking

Past experience screams [stack](https://en.wikibooks.org/wiki/Data_Structures/Stacks_and_Queues") as the data structure to use here. This immediately reminded me of writing prefix and postfix calculators in college courses.

I tried a few solutions before that, hoping that the input test cases would be simple enough that I could bypass it. This ultimately failed, as I should have expected.

In short, my thinking was this:

If the input length isn't an even number, you already know it's inbalanced.

Iterate through each character of the input, push "open" symbols `'(', '{', and '['` onto the stack and continue. When the character is a "close" symbol of `')', '}', or ']'`, pop from the stack and compare. The stack value should be a the opposite symbol that you're currently on in a correctly balanced input.

### Corner Cases

The following corner cases are what I missed in my initial solution:

* If a "close" symbol appears before any "open" symbols, the stack will be empty (nothing to pop). If empty, it's invalid input.
* If the stack still contains items after all input has been processed, it's invalid.

### Improvements

The following are things I would improve from my original solution once it passed all the tests:

* Consider checking just for "close" symbols and using "else" to capture opens. However, this would leave you open to input characters that are not symbols.
* Using `not` vs. `len() == 0`. Using `not` is more idiomatic python but `len()` check feels more explicit to the reader.

### Solution

```python
class Solution:
    open_symbols = ['(', '{', '[']
    close_symbols = [')', '}', ']']

    symbols = dict(zip(open_symbols, close_symbols))

    def __init__(self):
        self.stack = []

    def is_open(self, s: str) -> bool:
        return s in self.open_symbols

    def is_close(self, s: str) -> bool:
        return s in self.close_symbols

    def isValid(self, s: str) -> bool:
        if len(s) % 2 != 0:
            return False

        for val in s:
            if self.is_open(val):
                self.stack.append(val)
                continue
            if self.is_close(val):
                if len(self.stack) == 0:
                    return False
                prev = self.stack.pop()
                if val != self.symbols[prev]:
                    return False

        return len(self.stack) == 0
```

### Score

```
Runtime: 24 ms, faster than 90.39% of Python3 online submissions for Valid Parentheses.
Memory Usage: 13 MB, less than 98.26% of Python3 online submissions for Valid Parentheses.
```