
# AutoHotkey-Container - v1.0.0

The last AutoHotkey (AHK) array class you will ever need.

# Table of contents

<ol type="I">
  <li><a href="#introduction">Introduction</a></li>
  <li><a href="#quick-start">Quick start</a></li>
  <ol type="A">
    <li><a href="#decide-which-sort-type-to-use">Decide which sort type to use</a></li>
    <li><a href="#set-the-sort-type">Set the sort type</a></li>
    <li><a href="#set-containerobjcallbackvalue-optional">Set `ContainerObj.CallbackValue` (optional)</a></li>
    <li><a href="#set-containerobjcallbackcompare-optional">Set `ContainerObj.CallbackCompare` (optional)</a></li>
    <li><a href="#use-the-object---part-1">Use the object - part 1</a></li>
    <li><a href="#use-the-object---part-2">Use the object - part 2</a></li>
    <li><a href="#use-the-object---the-value-parameter">Use the object - the `Value` parameter</a></li>
  </ol>
  <li><a href="#binary-search">Binary search</a></li>
  <li><a href="#sorting-date-strings">Sorting date strings</a></li>
</ol>

# Introduction

Note that in this documentation an instance of `Container` is referred to either as "a `Container`
object" or `ContainerObj`.

```ahk
class Container extends Array
```

`Container` inherits from `Array` and exposes over 50 additional methods to perform common actions
such as sorting and finding values.

The class methods can be divided into three categories:
1. Methods that sort the values in the container.
2. Methods that require the container to be sorted.
3. Methods that do not require the container to be sorted.

Categories 2 and 3 above can be further divided into two subcategories:
1. Methods that allow the container to have unset indices.
2. Methods that do not allow the container to have unset indices.

The sorting methods **always require all indices to have a value**.

# Quick start

This section provides the minimum information needed to work with the class. Note you can run the
examples in this section from file test\test-readme-examples.ahk.

## Decide which sort type to use

`Container` stands above all other classes of its kind for its sorting and [binary search](#binary-search)
methods. Using these methods requires the caller to set the property `ContainerObj.SortType` with a
valid integer. The purpose of method `Container.Prototype.SetSortType` is to give the code author a
means for bringing up information about each sort type from within their editor†.

```
c := Container(
    { Name: "obj1" }
  , { Name: "obj3" }
  , { Name: "obj2" }
  , { Name: "obj5" }
)
c.SetSortType(
```

After the open parentheses, press your keyboard shortcut for parameter hints (the action is called
"Trigger Parameter Hints" in VS Code).

† Assuming the editor supports jsdoc-style parameter hints. If your editor does not support this,
and if you are interested in trying a new editor, you should download
[Visual Studio Code](https://apps.microsoft.com/detail/xp9khm4bk9fz7q) and install thqby's
[AutoHotkey v2 Language Support](https://marketplace.visualstudio.com/items?itemName=thqby.vscode-autohotkey2-lsp)
extension.

## Set the sort type

Finish the method call using the global variable. I would recommend not to use hardcoded numbers as
it is less readable and the values are subject to change. If your editor has intellisense, you should
be able to leverage that by just typing some of the letters of the symbol name.

```
; ... continuing with our example
c.SetSortType(CONTAINER_SORTTYPE_CB_STRING)
```

## Set `ContainerObj.CallbackValue` (optional)

If your container contains references to objects, then you will need to define the callback function
that returns the value that will be used for sort and find operations. If your container does not
contain references to objects, you can still define a callback to convert the values into something
else more useful for sorting (if the values are not inherently sortable).

Skip this step if the values in the container are to be sorted as-is.

In our example above we set the sort type to `CONTAINER_SORTTYPE_CB_STRING`. The "CB" stands for
"callback", which tells the relevant methods to call the callback function for the items in the container.

```
; ... continuing with our example
c.SetCallbackValue(ContainerCallbackValue)

ContainerCallbackValue(value) {
    return value.Name
}
```

## Set `ContainerObj.CallbackCompare` (optional)

In most cases your code will need to set property `ContainerObj.CallbackCompare`. The three exceptions
are `CONTAINER_SORTTYPE_CB_NUMBER`, `CONTAINER_SORTTYPE_DATEVALUE`, and `CONTAINER_SORTTYPE_NUMBER`,
which compare values using subtraction.

1. If the values will be compared as strings, call `Container.Prototype.SetCompareStringEx`.
Your code can call it without any parameters if the default values are acceptable. A common flag
you might want to use is `LINGUISTIC_IGNORECASE`, which you can pass as the global variable.
    ```
    ; ... continuing with our example
    c.SetCompareStringEx(, LINGUISTIC_IGNORECASE)
    ```
2. If the values will be compared as date strings, call one of `Container.Prototype.SetCompareDate`,
`Container.Prototype.SetCompareDateStr`, `Container.Prototype.SetDateParser`, or
`Container.Prototype.DatePreprocess`. See the section [Sorting date strings](#sorting-date-strings)
for more information.
3. Define your own function to use custom logic.
  - Parameters:
    1. Value1 - A value from the container.
    2. Value2 - A value from the container.
  - Returns:
    - A number less than zero to indicate the first parameter is less than the second parameter.
    - Zero to indicate the two parameters are equal.
    - A number greater than zero to indicate the first parameter is greater than the second parameter.
    ```
    c.SetCallbackCompare(Comparator)

    Comparator(Value1, Value2) {
        ; custom logic
    }
    ```

## Use the object - part 1

At the top of the description of each method is a line that says "Requires a sorted container: yes/no"
and a line that says "Allows unset indices: yes/no".

Methods that require a sorted container are methods that implement a [binary search](#binary-search).
A [binary search](#binary-search) is when you split a range in half repeatedly to narrow in on an
input value, significantly reducing the amount of processing time spent finding the value (compared
to a linear search).

Methods that do not require a sorted container are methods that implement a linear search, or methods
that iterate over each item in the container sequentially. Many of these will feel analagous to
javascript array methods.

Methods that allow unset indices are designed to check whether an index has a value before performing
the action on that index. These methods typically have the word "Sparse" at the end of the method name,
e.g. `Container.Prototype.FindSparse`. If your code knows that every index in a container has a value,
your code should use the non-sparse version. However, the difference in performance will only be
noticeable over thousands of consecutive operations, and so if there is a chance a container might
be sparse, there should not be any problem with using the sparse version.

There are three sort methods available:
- `Container.Prototype.InsertionSort` - Sorts in-place and is appropriate for small containers (n <= 32).
    ```
    c.InsertionSort()
    ```
- `Container.Prototype.Sort` - Sorts in-place and is appropriate for all containers.
    ```
    c.Sort()
    ```
- `Container.Prototype.QuickSort` - Does not mutate the original container (returns a new container)
  and is about 30% faster than `Container.Prototype.Sort`, but uses up to 10x the memory. I recommend
  using `Container.Prototype.QuickSort` in any case where sorting in-place is not necessary and where
  memory is not an issue. You can return the value to the same variable:
    ```
    c := c.QuickSort()
    ```

To find the index where a value is located, you can use the "Find" methods.
```
index := c.Find("obj1")
OutputDebug(index "`n") ; 1
index := c.Find("obj4")
OutputDebug(index "`n") ; 0
index := c.Find(c[3])
OutputDebug(index "`n") ; 3
```

To insert a value in-order, use one of the "Insert" methods.
```
c.Insert({ Name: "obj4" })
index := c.Find("obj4")
OutputDebug(index "`n") ; 4
```

To delete a value and leave an unset index, use one of the "DeleteValue" methods.
```
index := c.DeleteValue("obj4")
OutputDebug(index "`n") ; 4
OutputDebug(c.Has(4) "`n") ; 0
```

To remove a value and shift values to the left to fill in the space, use one of the "Remove" methods.
```
index := c.RemoveIfSparse("obj4") ; we must use `RemoveIfSparse` because index 4 is unset.
; The value is not found because we deleted it, so nothing was removed
OutputDebug(index "`n") ; 0
; In this example we know the index is 4, but we can just call Condense
; to shift values left to fill in the unset indices.
c.Condense()
; Index 4 now has a value.
OutputDebug(c.Has(4) "`n") ; 1
```

## Use the object - part 2

Reading this section is not necessary to use the class, but provides a more advanced use case that
I believe many programmers will be interested in.

Internally, AutoHotkey's `Map` class and object property tables implement a [binary search](#binary-search).
This allows us to associate values with string names.

Though `Map` is sufficient for many cases, I often found myself wanting the best of both worlds - I
want to be able to refer to an item by name, and I also want to be able to refer to an item by index
and use operations that are dependent on the values being serialized. I wrote `Container` for this
use case.

Our example container is already set up to be used as an associative array, but let's recreate it
real quick:
```
; Items must have a property that can be used as the name / key.
c := Container(
    { Name: "obj1" }
  , { Name: "obj3" }
  , { Name: "obj2" }
  , { Name: "obj5" }
)

; Set sort type to `CONTAINER_SORTTYPE_CB_STRING`.
c.SetSortType(CONTAINER_SORTTYPE_CB_STRING)

; Set CallbackValue with a function that returns the name / key.
c.SetCallbackValue(ContainerCallbackValue)
ContainerCallbackValue(value) {
    return value.Name
}

; Call `Container.Prototype.SetCompareStringEx` with / without optional parameters.
c.SetCompareStringEx(, LINGUISTIC_IGNORECASE)

; Sort the container.
c := c.QuickSort()
```

Using the `CONTAINER_SORTTYPE_CB_STRING` sort type allows us to define an object property as the
source of the name. As long as each object in the container has the same property that returns
a string value, then we can use the container as an associative array.

The following is a list of methods that are analagous to `Map` instance methods.
- `Map.Prototype.Clear` - Use `ContainerObj.Length := 0`.
- `Map.Prototype.Clone` - Use `Array.Prototype.Clone` (i.e. call `ContainerObj.Clone()`).
- `Map.Prototype.Delete` - Use `Container.Prototype.DeleteValue`, `Container.Prototype.DeleteValueIf`,
  `Container.Prototype.DeleteValueIfSparse`, `Container.Prototype.DeleteValueSparse`,
  `Container.Prototype.Remove`, `Container.Prototype.RemoveIf`, `Container.Prototype.RemoveIfSparse`,
  or `Container.Prototype.RemoveSparse`.
- `Map.Prototype.Get` - Use `Containe.Prototype.Find`, `Container.Prototype.FindAll`,
  `Container.Prototype.FindAllSparse`, `Container.Prototype.FindInequality`,
  `Container.Prototype.FindInequalitySparse`, or `Container.Prototype.FindSparse`.
- `Map.Prototype.Has` - Use `Container.Prototype.Find` or `Container.Prototype.FindSparse`.
- `Map.Prototype.Set` - Use `Container.Prototype.DateInsert`, `Container.Prototype.DateInsertSparse`,
  `Container.Prototype.Insert`, or `Container.Prototype.InsertSparse`.

### Use the object - the `Value` parameter

You will notice that the first parameter of any method that implements a [binary search](#binary-search)
is `Value` - the value to find.

The type of value that is valid to pass to `Value` depends on the sort type, but can be appropriately
summarized as:
- If `ContainerObj.CallbackValue` has been set, `Value` can be an object as long as the `CallbackValue`
  function can be used to return the sort value.
- `Value` can also be a primitive value as long as the value is valid for the sort type.

Each of the following are valid using our example container:
```
c.Find("obj1")
```
```
val := { Name: "obj1" }
c.Find(val)
```
```
val := c[1]
c.Find(val)
```

Date values behave somewhat differently because there are two kinds of date strings that can be
recognized by `Container` - standard yyyyMMddHHmmss strings, and also strings that will be passed
to an instance of `Container_DateParser`. Furthermore, `Container.Prototype.DatePreprocess` converts
date strings to a number but also restricts what kinds of values are valid to be passed to the
`Value` parameter. See [Sorting date strings](#sorting-date-strings) for more information.

# Binary search

The following is a simple binary search written in AHK code. `Container` has many variations of
this same logic to meet any use case.

```
BinarySearch(arr, value, comparator) {
    left := 1
    rng := right := arr.Length
    stop := -1
    while rng * 0.5 ** stop > 4 {
        stop++
        i := right - Ceil((right - left) * 0.5)
        if x := comparator(value, arr[i]) {
            if x > 0 {
                left := i
            } else {
                right := i
            }
        } else {
            return i
        }
    }
    i := left
    loop right - i + 1 {
        if comparator(value, arr[i]) {
            ++i
        } else {
            return i
        }
    }
}
```

# Sorting date strings

To be added.

In the meantime, the descriptions above `Container.Prototype.DatePreprocess`,
`Container.Prototype.SetCompareDate`, and `Container.Prototype.SetCompareDateStr` will have
the information you need.

Note that there is no built-in support for dates prior to year 1, nor support for date systems other
than the modern proleptic Gregorian calendar.
