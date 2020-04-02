---
layout: post
title: Contest - Day 2 - Happy Number
date: 2020-04-02 08:21:00-8000
author: me
category: leetcode
tags: [leetcode easy, leetcode covid contest, python]
keywords: [leetcode easy, leetcode covid contest, python]
---

[Leetcode](https://leetcode.com/) is running a 30 day "Covid 19" style contest for everyone on self quarantine and social distancing. Let's jump in!

## [Happy Number](https://leetcode.com/problems/happy-number/)

### Problem

Write an algorithm to determine if a number is "happy".

A happy number is a number defined by the following process: Starting with any positive integer, replace the number by the sum of the squares of its digits, and repeat the process until the number equals 1 (where it will stay), or it loops endlessly in a cycle which does not include 1. Those numbers for which this process ends in 1 are happy numbers.

Example: 

```
Input: 19
Output: true
Explanation: 
12 + 92 = 82
82 + 22 = 68
62 + 82 = 100
12 + 02 + 02 = 1
```

### Thinking

Once you know how to pull individual digits out of a number, these are _relatively_ straight forward. You just need to keep track of your in-progress sums vs. total sums and the total sums you've previously seen for loop detection.

To get a digit, you just mod the number by its base (`10`, assuming its `base 10`). Then you divide the original number by its base and continue. An unrolled look for the number `19` would look like:

```python
x = 19
x % 10  # => 9
x //= 10  # (x => 1)
x % 10  # => 1
x //= 10  # (x => 0)
```

### Corner Cases

I don't think I missed any this time.

### Improvements

There's possibly a way to detect loops without using a set (mathematical) to decrease memory usage but I don't know of it.

### Solution

```python
class Solution:
    def isHappy(self, n: int) -> bool:
        seen = set()
        curr = n
        prev = n

        while prev != 1:
            if prev in seen:
                break

            seen.add(prev)
            curr = prev
            prev = 0   

            while curr:
                digit = curr % 10
                curr //= 10
                prev += digit ** 2

        return prev == 1
```

### Score

```
Runtime: 36 ms, faster than 30.40% of Python3 online submissions for Happy Number.
Memory Usage: 13.9 MB, less than 5.26% of Python3 online submissions for Happy Number.
```