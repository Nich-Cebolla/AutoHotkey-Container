
#include ..\src\Container.ahk

/**

This file explains the purpose and usage of the parameter named `ThisArg`.

`ThisArg` refers to the "first (hidden) parameter" described
{@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_Classes_method in the AHK documentation for class methods}.

The following {@link Container} methods have a parameter `ThisArg`:
- {@link Container.Prototype.Every}
- {@link Container.Prototype.ForEachSparse}
- {@link Container.Prototype.Map}

To use these effectively, you should understand AutoHokey's implementation of `this`, when `ThisArg`
should be used with these methods, and when it should be excluded. Here is the main considerations,
and some examples.

The following examples use {@link Container.Prototype.ForEachSparse} for demonstration, but the same
principles apply to {@link Container.Prototype.Map} and {@link Container.Prototype.Every}.

When to leave `ThisArg` unset:
- If using a callback that is NOT a class method.
- If using a callback that is a BoundFunc created using `ObjBindMethod`.
- If using a callback that is a BoundFunc that binds a value to the hidden `this` parameter.

Your code must set `ThisArg` any time it uses a callback that is a unbound class method. The following
are some considerations when deciding what value your code should pass to `ThisArg`:
- If the callback is a static class method, the class object.
- If the callback is an instance method, an instance object.
- If the callback does not refer to `this` at all, pass any value to `ThisArg`; 0 is fine.
- If you want to modify what `this` refers to within the function's scope (for example, during
  testing), pass an object to `ThisArg` that has the same properties as the object that is referenced
  within the function. This allows you to test different values without modifying the class object or
  making other changes. See example 7 for an example of this usage.
*/

; Example 1: Standard usage.

; We leave `ThisArg` unset because function objects do not have a "this" parameter.

MyFunc(Item?, *) {
    OutputDebug(A_LineNumber ': Item: ' (Item ?? 'No item!') '`n')
}
c := Container(1,2,,4,,6,,,9)
Callback := MyFunc
c.ForEachSparse(Callback) ; Leave `ThisArg` unset.

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Example 2: Using an anonymous function.

; For anonymous functions, also leave `ThisArg` unset.

c := Container(1,2,,4,,6,,,9)
c.ForEachSparse((Item?, index?, *) => OutputDebug(A_LineNumber ': Index: ' index '; Item: ' (Item ?? 'No item!') '`n'))

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Example 3: Using `ObjBindMethod` on a class object.

; `ObjBindMethod` is a function that just binds the object to its own hidden `this` parameter.
; If we pass the return value from `ObjBindMethod` to `Container.Prototype.ForEachSparse`, we must leave
; `ThisArg` unset because that parameter is consumed by the bound value.

class Test3 {
    static Call(Item?, *) {
        OutputDebug(A_LineNumber ': Item * 2: ' (IsSet(Item) ? Item * 2 : 'No item!') '`n')
    }
}

c := Container(1,2,,4,,6,,,9)
Callback := ObjBindMethod(Test3, 'Call')
c.ForEachSparse(Callback) ; Leave `ThisArg` unset because it is already bound to the function object.

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Example 4: Using a class method that is not bound, and the method does not refer to `this`.

; `ThisArg` requires a value because the first parameter in a class method is the hidden `this`, so
; when `Container.Prototype.ForEachSparse` calls the function object, the first parameter which it passes
; to the callback is going to be consumed by `this`. A good way to visualize this is to open this
; in a debugger and see which values are passed to `Test.Call`. Try one without the 0 in the
; `ThisArg` parameter, and see how it works. What you will see is that the first parameter
; is consumed by `this`, which in a typical function call, you wouldn't notice this, but within an
; external function call, it becomes apparent.

class Test4 {
    static Call(Item?, Index?, ContainerObj?) {
        OutputDebug(A_LineNumber ': Item: ' (Item ?? 'No item!') '; Index: ' Index '; ``this``: ' this '`n')
    }
}

c := Container('a', 'b', 'c', 'd', 'e')
Callback := Test4.Call
c.ForEachSparse(Callback, 0)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Example 5: Using a class method that is not bound, and the method refers to `this`, and `this`
; refers to the class.

; We must pass the object `Test6` because `this` is referenced within the function, and that
; reference is intended to refer to `Test6`.

class Test5 {
    static Call(Item?, *) {
        OutputDebug(A_LineNumber ': Item * this.factor: ' (IsSet(Item) ? Item * this.factor : 'No item!') '`n')
    }
    static factor := 2
}

c := Container(1,2,,4,,6,,,9)
Callback := Test5.Call
c.ForEachSparse(Callback, Test5)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Example 6: Using a class method with a value that we want to override within our callback function.

; The below example demonstrates how to use `ThisArg` to override the value referenced by `this`.
; Even though the `this` parameter is normally hidden from us, you should think about it just like
; any other parameter. What we refer to as a "class method" is actually just a function that passes
; its parent object to its own first parameter.

; In the below example, we pass `Multiplier` to `ThisArg` to modify what `this` refers to within the
; function. This allows us to test a new value against the function, without needing to modify our
; class object or make other changes, simplifying the testing process.

; Note how the value we pass to `ThisArg` must also have a property "factor", or else we would see
; a PropertyError.

class Test6 {
    static Call(Item?, *) {
        OutputDebug(A_LineNumber ': Item * this.factor: ' (IsSet(Item) ? Item * this.factor : 'No item!') '`n')
    }
    static factor := 2
}

Multiplier := { factor: 3 }
c := Container(1,2,,4,,6,,,9)
Callback  := Test6.Call
c.ForEachSparse(Callback, Multiplier)


; Further explanation:

; It can be helpful to see how this plays out from the opposite direction. Let's say I want to define
; a method on an object dynamically. If one set of conditions is true I want to define function A,
; if another set of conditions is true I want to define function B. How do we make this work?

; Define our two functions

FunctionA(Self, Key, Value) {
    Self.Push({ Key: Key, Value: Value })
}

FunctionB(Self, Key, Value) {
    Self.Set(Key, Value)
}

; Since we are defining these as global functions (as opposed to class methods), we have to include
; the `this` parameter ourselves. The name doesn't matter, and so I always use the name "Self" to
; avoid conflicting with "this" since the AHK interpreter considers "this" a keyword.

; Let's define a function that handles defining the methods.

AddCustomMethod(Obj) {
    if Obj is Array {
        Obj.DefineProp('Add', { Call: FunctionA })
    } else if Obj is Map {
        Obj.DefineProp('Add', { Call: FunctionB })
    } else {
        throw TypeError('Invalid object.', -1, Type(Obj))
    }
}

; Let's test it out

c := Container()
m := Map()

AddCustomMethod(c) ; `Container` inherits from `Array`, so `Obj is Array` returns 1.
c.Add('Some key', 'Some value')
OutputDebug(A_LineNumber ': Key: ' c[1].Key '; Value: ' c[1].Value '`n')

AddCustomMethod(m)
m.Add('Some key', 'Some value')
for k, v in m {
    OutputDebug(A_LineNumber ': Key: ' k '; Value: ' v '`n')
}
