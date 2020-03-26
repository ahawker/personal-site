---
layout: post
title: Isomorphic Strings
date: 2020-03-26 09:24:00-8000
author: me
category: leetcode
tags: [leetcode easy, python]
keywords: [leetcode easy, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Isomorphic Strings](https://leetcode.com/problems/isomorphic-strings/)

### Problem

Given two strings `s` and `t`, determine if they are isomorphic.

Two strings are isomorphic if the characters in `s` can be replaced to get `t`.

All occurrences of a character must be replaced with another character while preserving the order of characters. No two characters may map to the same character but a character may map to itself.

You may assume both `s` and `t` have the same length.

Example inputs:

```
Input: s = "egg", t = "add"
Output: true

Input: s = "foo", t = "bar"
Output: false

Input: s = "paper", t = "title"
Output: true
```

### Thinking

This one took me longer than it should have. It was a case of me not reading the problem statement correctly and just hammering my head on it before going back, reading carefully, and continuing forward. A mistake I make often, unfortunately.

Initial thought was to just to group by and count characters for each string. If they were different, the input strings were of a different "pattern", thus false. This works for _most_ test cases but eventually you run into the cases where they try and remap the input character multiple times and it breaks. Luckly, there isn't much to change to support that.

In short, my solution does this:

* Loop through all chars in the strings
* Store mapping of char at index `i` in string `s` to char at index `i` in string `t`
* If this was already mapped and they don't match, it's not isomorphic
* Bump counts for the characters in string `s` and string `t`
* If the counts aren't equal, we have inconsistent "patterns" between the strings, so not isomorphic

### Corner Cases

The following corner cases are what I missed in my initial solution:

* Empty input strings. Originally considered them false, although two empty strings _are_ identical.
* Completely messed the character re-mapping rules in the problem statement. **READ SLOWLY**

### Improvements

You can do this without using counters by doing a current/previous iteration and doing a few comparisons but this code feels a bit more idiomatic. My intuition says that it'll be slightly slower in runtime but use less memory.

### Solution

```python
import collections

class Solution:
    def isIsomorphic(self, s: str, t: str) -> bool:
        if not s and not t:
            return True
        if len(s) != len(t):
            return False
        
        s_counts = collections.Counter()
        t_counts = collections.Counter()
        charmap = {}

        for i in range(0, len(s)):
            s_char = s[i]
            t_char = t[i]
            
            r_char = charmap.setdefault(s_char, t_char)
            if r_char != t_char:
                return False

            s_counts[s_char] += 1
            t_counts[t_char] += 1

            if s_counts[s_char] != t_counts[t_char]:
                return False

        return True
```

### Score

```
Runtime: 64 ms, faster than 11.29% of Python3 online submissions for Isomorphic Strings.
Memory Usage: 13 MB, less than 100.00% of Python3 online submissions for Isomorphic Strings.
```
