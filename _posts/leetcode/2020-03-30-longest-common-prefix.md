---
layout: post
title: Longest Common Prefix
date: 2020-03-30 08:44:00-8000
author: me
category: leetcode
tags: [leetcode easy, python]
keywords: [leetcode easy, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Longest Common Prefix](https://leetcode.com/problems/longest-common-prefix/)

### Problem

Write a function to find the longest common prefix string amongst an array of strings.

If there is no common prefix, return an empty string "".

All given inputs are in lowercase letters a-z.

Example inputs:

```
Input: ["flower","flow","flight"]
Output: "fl"

Input: ["dog","racecar","car"]
Output: ""
Explanation: There is no common prefix among the input strings.
```

### Thinking

This one seems pretty straight forward.

Maintain an index and loop through each string, checking the current character to see if it is the same. If it's not, or we run out of characters in one of the strings, we're done.

With that index, just slice the string to get the prefix.

### Corner Cases

The following corner cases are what I missed in my initial solution:

* Handling the zero/empty string case.

### Improvements

Inlining the `is_equal_at_index` function inside of the loop will likely increase runtime speed here at the cost of readability.

### Solution

```python
class Solution:
    def is_equal_at_index(self, strs: List[str], i: int) -> bool:
        char = strs[0][i]
        for j in range(1, len(strs)):
            if char != strs[j][i]:
                return False
        return True

    def longestCommonPrefix(self, strs: List[str]) -> str:
        i = 0

        while True:
            try:
                if not self.is_equal_at_index(strs, i):
                    break
            except IndexError:
                break
            else:
                i += 1

        return strs[0][0:i] if i > 0 else ''

```

### Score

```
Runtime: 32 ms, faster than 66.42% of Python3 online submissions for Longest Common Prefix.
Memory Usage: 13.9 MB, less than 6.67% of Python3 online submissions for Longest Common Prefix.
```
