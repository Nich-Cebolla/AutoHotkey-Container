
#include ..\src\Container.ahk

if A_LineFile == A_ScriptFullPath {
    test_ReadmeExamples()
}

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

    ; Insertion sort
    _c.InsertionSort()
    _test(_c)

    ; Sort
    _c := c.Clone()
    _c.Sort()
    _test(_c)

    ; QuickSort
    _c := c.Clone()
    _c := _c.QuickSort()
    _test(_c)

    c := _c

    ; To find the index where a value is located, you can use the "Find" methods.
    index := c.Find("obj1")
    OutputDebug(index "`n") ; 1
    _compare(index, 1)

    index := c.Find("obj4")
    OutputDebug(index "`n") ; 0
    _compare(index, 0)

    index := c.Find(c[3])
    OutputDebug(index "`n") ; 3
    _compare(index, 3)

    ; To get a value as a return value, use "GetValue" or "GetValueSparse".
    if ObjPtr(c.GetValue("obj2")) == ObjPtr(c[2]) {
        OutputDebug("obj2 is in the correct position.`n")
    }
    _compare(ObjPtr(c.GetValue("obj2")), ObjPtr(c[2]))

    ; To insert a value in-order, use one of the "Insert" methods.
    c.Insert({ Name: "obj4" })
    index := c.Find("obj4")
    OutputDebug(index "`n") ; 4
    _compare(index, 4)

    ; To delete a value and leave an unset index, use one of the "DeleteValue" methods.
    index := c.DeleteValue("obj4")
    OutputDebug(index "`n") ; 4
    _compare(index, 4)
    OutputDebug(c.Has(4) "`n") ; 0
    _compare(c.Has(4), 0)

    ; To remove a value and shift values to the left to fill in the space, use one of the "Remove" methods.
    index := c.Remove("obj3")
    OutputDebug(index "`n") ; 3
    _compare(index, 3)
    ; The empty index from deleting "obj4" is now at index 3
    OutputDebug(c.Has(3) "`n") ; 0
    _compare(c.Has(3), 0)
    ; "obj5" is now at index 4
    OutputDebug(c[4].Name "`n") ; obj5
    _compare(c[4].Name , "obj5")

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
