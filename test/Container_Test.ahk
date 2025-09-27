
#include ..\src\Container.ahk

class Container_Test {
    static Call(SortType, Len, Sort := false) {
        c := Container()
        c.SortType := SortType
        list := Map()
        switch SortType, 0 {
            case CONTAINER_SORTTYPE_DATE:
                date := Container_DateObj.FromTimestamp()
                while c.Length < Len {
                    d := date.AddToNew(Random(1, CONTAINER_DATEOBJ_SECONDS_IN_YEAR) * (Random() > 0.5 ? 1 : -1), 'S')
                    if !list.Has(d.Timestamp) {
                        c.Push(d.Timestamp)
                        list.Set(d.Timestamp, 1)
                    }
                }
                C.SortType := CONTAINER_SORTTYPE_DATE
                c.SetCompareDate()
            case CONTAINER_SORTTYPE_DATESTR:
                date := Container_DateObj.FromTimestamp()
                format := 'yyyy-MM-dd HH:mm:ss'
                while c.Length < Len {
                    d := date.AddToNew(Random(1, CONTAINER_DATEOBJ_SECONDS_IN_YEAR) * (Random() > 0.5 ? 1 : -1), 'S')
                    str := d.Get(format)
                    if !list.Has(str) {
                        c.Push(str)
                        list.Set(str, 1)
                    }
                }
                C.SortType := CONTAINER_SORTTYPE_DATESTR
                c.SetCompareDateStr(format)
            case CONTAINER_SORTTYPE_CB_DATE:
                date := Container_DateObj.FromTimestamp()
                while c.Length < Len {
                    d := date.AddToNew(Random(1, CONTAINER_DATEOBJ_SECONDS_IN_YEAR) * (Random() > 0.5 ? 1 : -1), 'S')
                    if !list.Has(d.Timestamp) {
                        c.Push({ timestamp: d.Timestamp })
                        list.Set(d.Timestamp, 1)
                    }
                }
                C.SortType := CONTAINER_SORTTYPE_CB_DATE
                c.SetCompareDate()
                c.SetCallbackValue((value) => value.timestamp)
            case CONTAINER_SORTTYPE_CB_DATESTR:
                date := Container_DateObj.FromTimestamp()
                format := 'yyyy-MM-dd HH:mm:ss'
                while c.Length < Len {
                    d := date.AddToNew(Random(1, CONTAINER_DATEOBJ_SECONDS_IN_YEAR) * (Random() > 0.5 ? 1 : -1), 'S')
                    str := d.Get(format)
                    if !list.Has(str) {
                        c.Push({ time: str })
                        list.Set(str, 1)
                    }
                }
                C.SortType := CONTAINER_SORTTYPE_CB_DATESTR
                c.SetCompareDateStr(format)
                c.SetCallbackValue((value) => value.time)
            case CONTAINER_SORTTYPE_NUMBER:
                while c.Length < Len {
                    v := Random(-100000, 100000)
                    if !list.Has(v) {
                        c.Push(v)
                        list.Set(v, 1)
                    }
                }
            case CONTAINER_SORTTYPE_STRING:
                while c.Length < Len {
                    v := Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122))
                    if !list.Has(v) {
                        c.Push(v)
                        list.Set(v, 1)
                    }
                }
                c.SetCompareStringEx()
            case CONTAINER_SORTTYPE_STRINGPTR:
                arr := []
                while c.Length < Len {
                    v := Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122))
                    if !list.Has(v) {
                        arr.Push(Buffer(StrPut(v, CONTAINER_DEFAULT_ENCODING)))
                        StrPut(v, arr[-1], CONTAINER_DEFAULT_ENCODING)
                        c.Push(arr[-1].Ptr)
                        list.Set(v, 1)
                    }
                }
                c.SetCompareStringEx()
                c.arr := arr
            case CONTAINER_SORTTYPE_CB_NUMBER:
                while c.Length < Len {
                    v := Random(-100000, 100000)
                    if !list.Has(v) {
                        c.Push({ prop: v })
                        list.Set(v, 1)
                    }
                }
                c.SetCallbackValue((self) => self.prop)
            case CONTAINER_SORTTYPE_CB_STRING:
                while c.Length < Len {
                    v := Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122))
                    if !list.Has(v) {
                        c.Push({ prop: v })
                        list.Set(v, 1)
                    }
                }
                c.SetCompareStringEx()
                c.SetCallbackValue((self) => self.prop)
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                arr := []
                while c.Length < Len {
                    v := Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122)) Chr(Random(97, 122))
                    if !list.Has(v) {
                        arr.Push(Buffer(StrPut(v, CONTAINER_DEFAULT_ENCODING)))
                        StrPut(v, arr[-1], CONTAINER_DEFAULT_ENCODING)
                        c.Push({ prop: arr[-1].Ptr })
                        list.Set(v, 1)
                    }
                }
                c.SetCompareStringEx()
                c.SetCallbackValue((self) => self.prop)
                c.arr := arr
            case CONTAINER_SORTTYPE_MISC:
                date := Container_DateObj.FromTimestamp()
                while c.Length < Len {
                    d := date.AddToNew(Random(1, CONTAINER_DATEOBJ_SECONDS_IN_YEAR) * (Random() > 0.5 ? 1 : -1), 'S')
                    if !list.Has(d.Timestamp) {
                        c.Push(d)
                        list.Set(d.Timestamp, 1)
                    }
                }
                c.SetCallbackCompare((a, b) => a.Diff('S', b.Timestamp))
            case CONTAINER_SORTTYPE_DATEVALUE:
                c := this(CONTAINER_SORTTYPE_CB_DATESTR, Len, false)
                c.DatePreprocess()
        }
        if Sort {
            c.Sort()
        }
        return c
    }
    /**
     * Note that, though the purpose is similar, `CallbackValue` does not serve the exact same purpose
     * here as it does with respect to {@link Container#CallbackValue}; they are not necessarily
     * interchangeable in these two contexts.
     */
    static ValidateValues(c, clone, CallbackValue?) {
        if IsSet(CallbackValue) {
            for item in clone {
                if i := c.Find(item, &value) {
                    c.RemoveAt(i)
                } else {
                    throw Error('A value is missing from the sorted container.', -1, 'Value: ' CallbackValue(item))
                }
                if CallbackValue(item) != CallbackValue(value) {
                    throw Error('``Container.Prototype.Find`` returned a mismatched value.', -1, 'Input: ' CallbackValue(item) '; returned: ' CallbackValue(value) '; return index: ' i)
                }
            }
        } else {
            for item in clone {
                if i := c.Find(item, &value) {
                    c.RemoveAt(i)
                } else {
                    throw Error('A value is missing from the sorted container.', -1, 'Value: ' item)
                }
                if item != value {
                    throw Error('``Container.Prototype.Find`` returned a mismatched value.', -1, 'Input: ' item '; returned: ' value '; return index: ' i)
                }
            }
        }
    }
}
