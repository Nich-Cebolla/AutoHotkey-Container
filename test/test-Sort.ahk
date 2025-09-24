
#include Container_Test.ahk
#include ..\src\Container.ahk

class test_Sort {
    static __New() {
        this.DeleteProp('__New')
        this.Len := 1000
    }
    static Call() {
        this.SortNumber()
        this.SortString()
        this.SortStringPtr()
        this.SortCbNumber()
        this.SortCbString()
        this.SortCbStringPtr()
        this.SortCbMisc()

        this.SortNumber(1)
        this.SortString(1)
        this.SortStringPtr(1)
        this.SortCbNumber(1)
        this.SortCbString(1)
        this.SortCbStringPtr(1)
        this.SortCbMisc(1)
    }
    static SortNumber(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_NUMBER, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        loop c.Length - 1 {
            if c[A_Index] > c[A_Index + 1] {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index] '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1])
            }
        }
        Container_Test.ValidateValues(c, clone)
    }
    static SortString(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_STRING, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        CallbackCompare := c.CallbackCompare
        loop c.Length - 1 {
            if CallbackCompare(StrPtr(c[A_Index]), StrPtr(c[A_Index + 1])) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index] '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1])
            }
        }
        Container_Test.ValidateValues(c, clone)
    }
    static SortStringPtr(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_STRINGPTR, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        arr := []
        for item in c {
            arr.Push(StrGet(item, CONTAINER_DEFAULT_ENCODING))
        }
        CallbackCompare := c.CallbackCompare
        loop c.Length - 1 {
            if CallbackCompare(c[A_Index], c[A_Index + 1]) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' StrGet(c[A_Index], CONTAINER_DEFAULT_ENCODING) '; index2: ' A_Index + 1 '; value2: ' StrGet(c[A_Index + 1], CONTAINER_DEFAULT_ENCODING))
            }
        }
        loop arr.Length - 1 {
            if CallbackCompare(StrPtr(arr[A_Index]), StrPtr(arr[A_Index + 1])) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' arr[A_Index] '; index2: ' A_Index + 1 '; value2: ' arr[A_Index + 1])
            }
        }
        Container_Test.ValidateValues(c, clone, (item) => StrGet(item, CONTAINER_DEFAULT_ENCODING))
    }
    static SortCbNumber(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_CB_NUMBER, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        CallbackValue := c.CallbackValue
        loop c.Length - 1 {
            if CallbackValue(c[A_Index]) > CallbackValue(c[A_Index + 1]) {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' CallbackValue(c[A_Index]) '; index2: ' A_Index + 1 '; value2: ' CallbackValue(c[A_Index + 1]))
            }
        }
        Container_Test.ValidateValues(c, clone, CallbackValue)
    }
    static SortCbString(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_CB_STRING, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        CallbackCompare := c.CallbackCompare
        CallbackValue := c.CallbackValue
        loop c.Length - 1 {
            if CallbackCompare(StrPtr(CallbackValue(c[A_Index])), StrPtr(CallbackValue(c[A_Index + 1]))) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' CallbackValue(c[A_Index]) '; index2: ' A_Index + 1 '; value2: ' CallbackValue(c[A_Index + 1]))
            }
        }
        Container_Test.ValidateValues(c, clone, CallbackValue)
    }
    static SortCbStringPtr(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_CB_STRINGPTR, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        CallbackCompare := c.CallbackCompare
        CallbackValue := c.CallbackValue
        arr := []
        for item in c {
            arr.Push(StrGet(CallbackValue(item), CONTAINER_DEFAULT_ENCODING))
        }
        loop c.Length - 1 {
            if CallbackCompare(CallbackValue(c[A_Index]), CallbackValue(c[A_Index + 1])) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' StrGet(CallbackValue(c[A_Index]), CONTAINER_DEFAULT_ENCODING) '; index2: ' A_Index + 1 '; value2: ' StrGet(CallbackValue(c[A_Index + 1]), CONTAINER_DEFAULT_ENCODING))
            }
        }
        loop arr.Length - 1 {
            if CallbackCompare(StrPtr(arr[A_Index]), StrPtr(arr[A_Index + 1])) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' arr[A_Index] '; index2: ' A_Index + 1 '; value2: ' arr[A_Index + 1])
            }
        }
        Container_Test.ValidateValues(c, clone, (item) => StrGet(CallbackValue(item), CONTAINER_DEFAULT_ENCODING))
    }
    static SortCbMisc(Quick := false) {
        c := Container_Test(CONTAINER_SORTTYPE_CB_MISC, this.Len, false)
        clone := c.Clone()
        if Quick {
            c := c.QuickSort()
        } else {
            c.Sort()
        }
        if c.Length != clone.Length {
            throw Error('Mismatched lengths.', -1, 'c.Length = ' c.Length '; clone.Length = ' clone.Length)
        }
        CallbackCompare := c.CallbackCompare
        loop c.Length - 1 {
            if CallbackCompare(c[A_Index], c[A_Index + 1]) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index].Timestamp '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1].Timestamp)
            }
        }
        ; Check independently from CallbackCompare in case the error is propagated by CallbackCompare itself
        loop c.Length - 1 {
            if c[A_Index].TotalSeconds > c[A_Index + 1].TotalSeconds {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index].TotalSeconds '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1].TotalSeconds)
            }
        }
        Container_Test.ValidateValues(c, clone, (item) => item.Timestamp)
    }
}
