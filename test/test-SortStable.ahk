
#include Container_Test.ahk
#include ..\src\Container.ahk

class test_SortStable {
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
        this.SortDate()
    }
    static SortDate() {
        c := Container_Test(CONTAINER_SORTTYPE_DATE, this.Len, false)
        clone := c.Clone()
        c.SortStable()
        CallbackCompare := c.CallbackCompare
        loop c.Length - 1 {
            if CallbackCompare(c[A_Index], c[A_Index + 1]) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index].Timestamp '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1].Timestamp)
            }
        }
        ; Check independently from CallbackCompare in case the error is propagated by CallbackCompare itself
        loop c.Length - 1 {
            if Container_Date.FromTimestamp(c[A_Index]).TotalSeconds > Container_Date.FromTimestamp(c[A_Index + 1]).TotalSeconds {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index].TotalSeconds '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1].TotalSeconds)
            }
        }
        Container_Test.ValidateValues(c, clone)
    }
    static SortNumber() {
        c := Container_Test(CONTAINER_SORTTYPE_NUMBER, this.Len, false)
        clone := c.Clone()
        c.SortStable()
        loop c.Length - 1 {
            if c[A_Index] > c[A_Index + 1] {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index] '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1])
            }
        }
        Container_Test.ValidateValues(c, clone)
    }
    static SortString() {
        c := Container_Test(CONTAINER_SORTTYPE_STRING, this.Len, false)
        clone := c.Clone()
        c.SortStable()
        CallbackCompare := c.CallbackCompare
        loop c.Length - 1 {
            if CallbackCompare(StrPtr(c[A_Index]), StrPtr(c[A_Index + 1])) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' c[A_Index] '; index2: ' A_Index + 1 '; value2: ' c[A_Index + 1])
            }
        }
        Container_Test.ValidateValues(c, clone)
    }
    static SortStringPtr() {
        c := Container_Test(CONTAINER_SORTTYPE_STRINGPTR, this.Len, false)
        clone := c.Clone()
        c.SortStable()
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
    static SortCbNumber() {
        third := (this.len - Mod(this.len, 3)) / 3
        c := Container_Test(CONTAINER_SORTTYPE_CB_NUMBER, third, false)
        c.length := third * 3
        loop third {
            c[A_Index + third] := c[A_Index].Clone()
            c[A_Index + third].index := A_Index + third
            c[A_Index + third * 2] := c[A_Index].Clone()
            c[A_Index + third * 2].index := A_Index + third * 2
            c[A_Index].index := A_Index
        }
        clone := c.Clone()
        c.SortStable()
        CallbackValue := c.CallbackValue
        loop c.Length - 1 {
            if CallbackValue(c[A_Index]) > CallbackValue(c[A_Index + 1]) {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' CallbackValue(c[A_Index]) '; index2: ' A_Index + 1 '; value2: ' CallbackValue(c[A_Index + 1]))
            }
        }
        loop third {
            i := A_Index * 3 - 2
            z1 := CallbackValue(c[i]) - CallbackValue(c[i + 1])
            z2 := CallbackValue(c[i]) - CallbackValue(c[i + 2])
            if z1 || z2 {
                throw Error('Out of order.', , 'c[' i '] = ' CallbackValue(c[i]) '; c[' (i + 1) '] = ' CallbackValue(c[i + 1]) '; c[' (i + 2) '] = ' CallbackValue(c[i + 2]))
            }
            if c[i].index > c[i + 1].index
            || c[i].index > c[i + 2].index
            || c[i + 1].index > c[i + 2].index {
                throw Error('Unstable.', , 'For objects at ' i ', ' (i + 1) ', and ' (i + 2) ', the original indices were ' c[i].index ', ' c[i + 1].index ', ' c[i + 2].index)
            }
        }
        Container_Test.ValidateValues(c, clone, CallbackValue)
    }
    static SortCbString() {
        third := (this.len - Mod(this.len, 3)) / 3
        c := Container_Test(CONTAINER_SORTTYPE_CB_STRING, third, false)
        c.length := third * 3
        loop third {
            c[A_Index + third] := c[A_Index].Clone()
            c[A_Index + third].index := A_Index + third
            c[A_Index + third * 2] := c[A_Index].Clone()
            c[A_Index + third * 2].index := A_Index + third * 2
            c[A_Index].index := A_Index
        }
        clone := c.Clone()
        c.SortStable()
        CallbackCompare := c.CallbackCompare
        CallbackValue := c.CallbackValue
        loop c.Length - 1 {
            if CallbackCompare(StrPtr(CallbackValue(c[A_Index])), StrPtr(CallbackValue(c[A_Index + 1]))) > 0 {
                throw Error('Out of order values.', -1, 'Index1: ' A_Index '; value1: ' CallbackValue(c[A_Index]) '; index2: ' A_Index + 1 '; value2: ' CallbackValue(c[A_Index + 1]))
            }
        }
        loop third {
            i := A_Index * 3 - 2
            z1 := CallbackCompare(StrPtr(CallbackValue(c[i])), StrPtr(CallbackValue(c[i + 1])))
            z2 := CallbackCompare(StrPtr(CallbackValue(c[i])), StrPtr(CallbackValue(c[i + 2])))
            if z1 || z2 {
                throw Error('Out of order.', , 'c[' i '] = ' CallbackValue(c[i]) '; c[' (i + 1) '] = ' CallbackValue(c[i + 1]) '; c[' (i + 2) '] = ' CallbackValue(c[i + 2]))
            }
            if c[i].index > c[i + 1].index
            || c[i].index > c[i + 2].index
            || c[i + 1].index > c[i + 2].index {
                throw Error('Unstable.', , 'For objects at ' i ', ' (i + 1) ', and ' (i + 2) ', the original indices were ' c[i].index ', ' c[i + 1].index ', ' c[i + 2].index)
            }
        }
        Container_Test.ValidateValues(c, clone, CallbackValue)
    }
    static SortCbStringPtr() {
        third := (this.len - Mod(this.len, 3)) / 3
        c := Container_Test(CONTAINER_SORTTYPE_CB_STRINGPTR, third, false)
        c.length := third * 3
        loop third {
            c[A_Index + third] := c[A_Index].Clone()
            c[A_Index + third].index := A_Index + third
            c[A_Index + third * 2] := c[A_Index].Clone()
            c[A_Index + third * 2].index := A_Index + third * 2
            c[A_Index].index := A_Index
        }
        clone := c.Clone()
        c.SortStable()
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
        loop third {
            i := A_Index * 3 - 2
            z1 := CallbackCompare(CallbackValue(c[i]), CallbackValue(c[i + 1]))
            z2 := CallbackCompare(CallbackValue(c[i]), CallbackValue(c[i + 2]))
            if z1 || z2 {
                throw Error('Out of order.', , 'c[' i '] = ' CallbackValue(c[i]) '; c[' (i + 1) '] = ' CallbackValue(c[i + 1]) '; c[' (i + 2) '] = ' CallbackValue(c[i + 2]))
            }
            if c[i].index > c[i + 1].index
            || c[i].index > c[i + 2].index
            || c[i + 1].index > c[i + 2].index {
                throw Error('Unstable.', , 'For objects at ' i ', ' (i + 1) ', and ' (i + 2) ', the original indices were ' c[i].index ', ' c[i + 1].index ', ' c[i + 2].index)
            }
        }
        Container_Test.ValidateValues(c, clone, (item) => StrGet(CallbackValue(item), CONTAINER_DEFAULT_ENCODING))
    }
    static SortCbMisc() {
        third := (this.len - Mod(this.len, 3)) / 3
        c := Container_Test(CONTAINER_SORTTYPE_MISC, third, false)
        c.length := third * 3
        loop third {
            c[A_Index + third] := c[A_Index].Clone()
            c[A_Index + third].index := A_Index + third
            c[A_Index + third * 2] := c[A_Index].Clone()
            c[A_Index + third * 2].index := A_Index + third * 2
            c[A_Index].index := A_Index
        }
        clone := c.Clone()
        c.SortStable()
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
        loop third {
            i := A_Index * 3 - 2
            z1 := CallbackCompare(c[i], c[i + 1])
            z2 := CallbackCompare(c[i], c[i + 2])
            if z1 || z2 {
                throw Error('Out of order.', , 'c[' i '] = ' c[i].TotalSeconds '; c[' (i + 1) '] = ' c[i + 1].TotalSeconds '; c[' (i + 2) '] = ' c[i + 2].TotalSeconds)
            }
            if c[i].index > c[i + 1].index
            || c[i].index > c[i + 2].index
            || c[i + 1].index > c[i + 2].index {
                throw Error('Unstable.', , 'For objects at ' i ', ' (i + 1) ', and ' (i + 2) ', the original indices were ' c[i].index ', ' c[i + 1].index ', ' c[i + 2].index)
            }
        }
        Container_Test.ValidateValues(c, clone, (item) => item.Timestamp)
    }
}
