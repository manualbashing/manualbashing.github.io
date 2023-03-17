---
title: Split an array into n-equal arrays in Azure Logic Apps
date: 2023-03-17
draft: false
tags:
 - LogicApps
 - PowerAutomate
---

Lets say you have an array like this:

```json
[
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10
]
```

And you would like to create slices of this array that contain maximum 3 elements:

```json
[
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 8],
  [10]
]
```

In order to solve this type of problem I have seen people to resort to JavaScript, Azure Functions or complicated contraptions within Logic Apps. The alternative is to use a surprisingly little known expression function called `chunk()`: [chunk() - Reference guide for expression functions - Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/workflow-definition-language-functions-reference#chunk)

The function takes two elements. The first is the array, that needs to be sliced and the second is the slice length.

```python
chunk('[1,2,3,4,5,6,7,8,9,10]', 3)
```

![logic apps chunk](/static/logicapps-chunk.png)

See here for a full workflow definition for this example:

{{< gist manualbashing e37e4e0670d23838eb4a636bec1f01aa >}}

[See Gist on Github](https://gist.github.com/manualbashing/e37e4e0670d23838eb4a636bec1f01aa)
