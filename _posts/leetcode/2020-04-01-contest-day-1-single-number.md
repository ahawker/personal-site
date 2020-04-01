---
layout: post
title: Contest - Day 1 - Single Number
date: 2020-04-01 08:37:00-8000
author: me
category: leetcode
tags: [leetcode easy, leetcode covid contest, python]
keywords: [leetcode easy, leetcode covid contest, python]
---

[Leetcode](https://leetcode.com/) is running a 30 day "Covid 19" style contest for everyone on self quarantine and social distancing. Let's jump in!

## [Single Number](https://leetcode.com/problems/single-number/)

### Problem

Given a non-empty array of integers, every element appears twice except for one. Find that single one.

Note:

Your algorithm should have a linear runtime complexity. Could you implement it without using extra memory?

Examples:

```
Input: [2,2,1]
Output: 1

Input: [4,1,2,1,2]
Output: 4
```

### Thinking

This is very easy using the `collections.Counter` in python stlib. That might be _cheating_ but I'm going to allow it. Stand on the shoulders of well tested (code) giants, I say.

However, the question posits there is a way to do it without using _extra_ memory. So, storing counters is likely not the optimal solution.

This led me to thinking about truth tables. What boolean operation will indicate _once_ but not _twice_? **XOR**. For example:

```python
0 ^ 1 => 1
0 ^ 1 ^ 1 => 0.
```

If the result of our **XOR** logic is the input value, there is only one occurrence of it. If it's zero, then there was either none, or more than 1 of them.

### Corner Cases

I don't think I missed any this time.

### Improvements

I don't think I missed any this time.

### Solution

**Counting**

```python
import collections

class Solution:
    def singleNumber(self, nums: List[int]) -> int:
        counts = collections.Counter(nums)
        return counts.most_common()[-1][0]
```

**XOR**

```python
class Solution:
    def singleNumber(self, nums: List[int]) -> int:
        r = 0
        for n in nums:
            r ^= n
        return r
```

### Score

**Counting**

```
Runtime: 84 ms, faster than 85.38% of Python3 online submissions for Single Number.
Memory Usage: 16.3 MB, less than 6.56% of Python3 online submissions for Single Number.
```

**XOR**

```
Runtime: 88 ms, faster than 65.17% of Python3 online submissions for Single Number.
Memory Usage: 15.6 MB, less than 6.56% of Python3 online submissions for Single Number.
```
