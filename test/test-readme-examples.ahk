
#include ..\src\Container.ahk

test_ReadmeExamples() {
    c := Container(
        { Name: "obj1" }
      , { Name: "obj3" }
      , { Name: "obj2" }
      , { Name: "obj5" }
    )
    c.SetSortType(CONTAINER_SORTTYPE_CB_STRING)
    c.SetCallbackValue(ContainerCallbackValue)

    ContainerCallbackValue(value) {
        return value.Name
    }

    c.SetCompareStringEx(, LINGUISTIC_IGNORECASE)
    _c := c.Clone()
    _c.InsertionSort()
    _test(_c)
    _c := c.Clone()
    _c.Sort()
    _test(_c)
    _c := c.Clone()
    _c := _c.QuickSort()
    _test(_c)

    c := _c

    index := c.Find("obj1")
    OutputDebug(index "`n") ; 1
    _compare(index, 1)
    index := c.Find("obj4")
    OutputDebug(index "`n") ; 0
    _compare(index, 0)
    index := c.Find(c[3])
    OutputDebug(index "`n") ; 3
    _compare(index, 3)
    c.Insert({ Name: "obj4" })
    index := c.Find("obj4")
    OutputDebug(index "`n") ; 4
    _compare(index, 4)
    index := c.DeleteValue("obj4")
    OutputDebug(index "`n") ; 4
    _compare(index, 4)
    OutputDebug(c.Has(4) "`n") ; 0
    _compare(c.Has(4), 0)
    index := c.RemoveIfSparse("obj4")
    OutputDebug(index "`n") ; 0
    _compare(index, 0)
    c.Condense()
    OutputDebug(c.Has(4) "`n") ; 1
    _compare(c.Has(4), 1)

    return

    _test(c) {
        previous := c[1]
        loop c.Length - 1 {
            if SubStr(previous.Name, -1, 1) > SubStr(c[A_Index + 1].Name, -1, 1) {
                throw Error("Out of order.")
            }
            previous := c[A_Index + 1]
        }
    }
    _compare(a, b) {
        if a != b {
            throw Error("Invalid value.")
        }
    }
}
