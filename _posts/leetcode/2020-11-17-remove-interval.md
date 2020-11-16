---
layout: post
title: Remove Interval
date: 2020-11-16 09:43:00-8000
author: me
category: leetcode
tags: [leetcode medium, python]
keywords: [leetcode medium, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Remove Interval](https://leetcode.com/problems/remove-interval/)

### Problem

Given a **sorted** list of disjoint `intervals`, each interval `intervals[i] = [a, b]` represents the set of real numbers `x` such that `a <= x < b`.

We remove the intersections between any interval in `intervals` and the interval `toBeRemoved`.

Return a **sorted** list of `intervals` after all such removals.

Example 1:

```
Input: intervals = [[0,2],[3,4],[5,7]], toBeRemoved = [1,6]
Output: [[0,1],[6,7]]
```

Example 2:

```
Input: intervals = [[0,5]], toBeRemoved = [2,3]
Output: [[0,2],[3,5]]
```

Example 3:

```
Input: intervals = [[-5,-4],[-3,-2],[1,2],[3,5],[8,9]], toBeRemoved = [-1,4]
Output: [[-5,-4],[-3,-2],[4,5],[8,9]]
```

Constraints:

```
1 <= intervals.length <= 10^4
-10^9 <= intervals[i][0] < intervals[i][1] <= 10^9
```


### Thinking

We're given a pre-sorted input and expected to return a sorted output, so as long as we don't mess up the order as we process, we won't have to do any sorting ourselves.

We need to make sure our checking handles `a <= x < b` correctly and not `<=` on the upper bound.

This feels like an `O(N)` traversal of the intervals to process those that overlap with the removal bounds. When they overlap, return the interval delta or "split" if the removal generates two separate intervals. Also need to consider the case when the removal overlaps the entire interval being processed so it's fully dropped.

Overlapping number ranges is a visual problem (for me) so I drew up this diagram covering the four cases I was thinking about on the back of some scratch paper.

![Scratch paper diagram showing interval overlapping](/assets/images/posts/remove-interval-drawing.jpg)

### Corner Cases

I don't think I missed any this time.

### Improvements

With some more thought, I think I can reduce the number of comparisons made as we have some duplication between
checking for any overlap and checking which it is.

### Solution

```python
class Solution:
    def removeInterval(self, intervals: List[List[int]], toBeRemoved: List[int]) -> List[List[int]]:
        def process(x1, x2, y1, y2):
            if x1 <= y1 and x2 < y2:  # Removal overlaps right side
                return ((x1, y1),)
            if y1 <= x1 and y2 < x2:  # Removal overlaps left side
                return ((y2, x2),)
            if x1 <= y1 and y2 < x2:  # Removal overlaps inside
                return ((x1, y1), (y2, x2))
            return tuple()  # Removal overlaps entire


        result = []
        rlo, rhi = toBeRemoved

        for interval in intervals:
            lo, hi = interval

            if lo <= rhi and rlo <= hi:  # Check for any overlap
                result.extend(process(lo, hi, rlo, rhi))
            else:
                result.append(interval)

        return result
```

### Score

```
Runtime: 368 ms, faster than 89.39% of Python3 online submissions for Remove Interval.
Memory Usage: 20 MB, less than 75.98% of Python3 online submissions for Remove Interval.
```