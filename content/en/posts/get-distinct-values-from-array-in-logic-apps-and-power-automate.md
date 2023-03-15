---
title: Get distinct values from array in Logic Apps and Power Automate
date: 2023-03-13T12:31:45
tags:
 - LogicApps
 - PowerAutomate
---

It is a fairly common task to get only distinct values from an array. That means only those values, that are not duplicates.

Imagine you have the following array:

![distinct-values-myArray](/static/distinct-values-myArray.png)

If you want only distinct values from this array, that means you want `[ "A", "B", "C", "D"]` without the duplicate `"A"`.

As you can guess from the previous screenshot, this can be done with the `union()` function, that is available in both Logic Apps and Power Automate. The actual purpose of this function is to create a union between two arrays or objects:

> Returns a single array or object with all the elements that are in either array or object passed to this function. 
> 
> 👉 [union() - Reference guide for expression functions - Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/workflow-definition-language-functions-reference#union)

A side effect of this function is, that each element is returned only once. That means creating a union of an array either with itself or with an empty array will result in an array that contains only distinct values.

The expression in our example would be:

```pyhon
union(variables('myArray'), json('[]'))
```

The expression `json('[]')` is an easy way to create an empty array for the union.