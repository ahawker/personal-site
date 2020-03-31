---
layout: post
title: Add Two Numbers
date: 2020-03-31 08:34:00-8000
author: me
category: leetcode
tags: [leetcode medium, python]
keywords: [leetcode medium, python]
---

I'm trying to get in a habit of starting my mornings off with coffee and a [Leetcode](https://leetcode.com/) problem before work. Ease my way into the day and get the brain juices flowing. Let's jump in!

## [Add Two Numbers](https://leetcode.com/problems/add-two-numbers/)

### Problem

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example:

```
Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.
```

### Thinking

This one took me a few swings, mainly because I didn't read that the return value was supposed to be a linked list. I had implemented the logic to sum the linked lists properly and then realized I'd have to iterate over the resulting integer to build a list. Bleh. So I started over so I could implement it in a single iteration of `O(N)` time.

The solution works as follows:

Continue looping while either of the nodes has a `next` value.

Sum digits from each list. Use zero if we've exhausted one of the lists. Track a "carry" if sum is greater than 10. Result list should only store `sum % 10` so it only stores a single digit.

If we're at the end of both lists, check to see if we still have a "carry". If so, need to append another node to result list with the value of `1`.

### Corner Cases

The following corner cases are what I missed in my initial solution:

* The final "carry" when both lists were exhausted.

### Improvements

I feel like the tracking of the head node relative to the result list moving pointer code is messy.

### Solution

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def addTwoNumbers(self, l1: ListNode, l2: ListNode) -> ListNode:
        carry = 0
        
        head = l3 = ListNode(None)
        
        while True:
            if not l1 and not l2:
                if carry:
                    l3.next = ListNode(carry)
                break

            l1_val = l1.val if l1 else 0
            l2_val = l2.val if l2 else 0

            value = l1_val + l2_val + carry
            digit = value % 10
            
            if l3.val is None:
                l3.val = digit
                head = l3
            else:
                l3.next = ListNode(digit)
                l3 = l3.next

            carry = 1 if value >= 10 else 0
            l1 = l1.next if l1 else None
            l2 = l2.next if l2 else None
        
        return head
```

### Score

```
Runtime: 68 ms, faster than 77.41% of Python3 online submissions for Add Two Numbers.
Memory Usage: 13.8 MB, less than 5.67% of Python3 online submissions for Add Two Numbers.
```
