---
layout: post
title: Longest Substring Without Repeating Characters
date: 2020-03-27 07:11:00-8000
author: me
category: leetcode
tags: [leetcode medium, python]
keywords: [leetcode medium, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/)

### Problem

Given a string, find the length of the longest substring without repeating characters.

Example inputs:

```
Input: "abcabcbb"
Output: 3
Explanation: The answer is "abc", with the length of 3.

Input: "bbbbb"
Output: 1
Explanation: The answer is "b", with the length of 1.

Input: "pwwkew"
Output: 3
Explanation: The answer is "wke", with the length of 3.
             Note that the answer must be a substring, "pwke" is a subsequence and not a substring.
```

### Thinking

I spent some time thinking about this but couldn't come up with anything faster than `O(N^2)` although I can almost guarantee there is a way.

In any case, the thought is iterate through the permutations and use a set to track the characters seen. When we run into a character we've seen, capture the length (if the max), and reset on next initial character.

### Corner Cases

The following corner cases are what I missed in my initial solution:

* If iteration completes w/o running into a character it hasn't seen.

### Improvements

There is probably a way to cleanup the logic so the seen & fallthrough code can be merged instead of copied.

There is probably a faster solution than `O(N^2)`.

### Solution

```python
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        if not s:
            return 0

        seen = set()
        max_len = -1

        for i in range(0, len(s)):
            seen.add(s[i])

            for j in range(i+1 , len(s)):
                if s[j] in seen:
                    max_len = max(max_len, len(seen))
                    seen.clear()
                    break
                else:
                    seen.add(s[j])
            else:
                max_len = max(max_len, len(seen))
                seen.clear()

        return max_len
```

### Score

```
Runtime: 508 ms, faster than 15.12% of Python3 online submissions for Longest Substring Without Repeating Characters.
Memory Usage: 13.9 MB, less than 5.10% of Python3 online submissions for Longest Substring Without Repeating Characters.
```
