
#include Container_Test.ahk

if A_LineFile == A_ScriptFullPath {
    test_miscExamples()
}

class test_miscExamples {
    static Call() {
        this.PushEx()
        this.Enum()
        this.EnumRange()
        this.EnumRangeSparse()
        this.EnumRangeDate()
    }
    static PushEx() {
        c := Container(1, 2, 3)
        c2 := Container(4, 5, 6)
        c3 := Container(7, 8, 9)
        c.PushEx(c2.PushEx(c3.PushEx([10, 11, 12])))
        str := c.Join()
        if str != '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12' {
            throw Error('Invalid return value.', , str)
        }
        OutputDebug(str '`n')
    }
    static Enum() {
        CallbackValue(value) {
            return value.name
        }
        c := Container.CbString(CallbackValue)
        c.InsertList([
            { name: "obj3" }
          , { name: "obj2" }
          , { name: "obj4" }
        ])

        for name, obj in c {
            OutputDebug(name " - " Type(obj) "`n")
            if name != "obj" (A_Index + 1) {
                throw Error('Invalid name in ``for`` loop.', , name)
            }
            if Type(obj) != 'Object' {
                throw Error('Invalid object type in ``for`` loop.', , Type(obj))
            }
        }

        for index, name, obj in c {
            OutputDebug(index ": " name " - " Type(obj) "`n")
            if name != "obj" (A_Index + 1) {
                throw Error('Invalid name in ``for`` loop.', , name)
            }
            if index != A_Index {
                throw Error('Invalid index in ``for`` loop.', , index)
            }
            if Type(obj) != 'Object' {
                throw Error('Invalid object type in ``for`` loop.', , Type(obj))
            }
        }
    }
    static EnumRange() {
        CallbackValue(value) {
            return value.name
        }
        c := Container.CbString(CallbackValue)
        c.InsertList([
            { name: "obj3" }
          , { name: "obj2" }
          , { name: "obj4" }
          , { name: "obj1" }
          , { name: "obj5" }
        ])

        for index, name, obj in c.EnumRange(3, "obj2", "obj4") {
            OutputDebug(index ": " name " - " Type(obj) "`n")
            if name != "obj" (A_Index + 1) {
                throw Error('Invalid name in ``for`` loop.', , name)
            }
            if index != A_Index + 1 {
                throw Error('Invalid index in ``for`` loop.', , index)
            }
            if Type(obj) != 'Object' {
                throw Error('Invalid object type in ``for`` loop.', , Type(obj))
            }
            if A_Index > 3 {
                throw Error('Too many iterations.')
            }
        }
    }
    static EnumRangeSparse() {
        CallbackValue(value) {
            return value.name
        }
        c := Container.CbString(CallbackValue)
        c.InsertListSparse([
            { name: "obj3" }
          , { name: "obj2" }
          , { name: "obj4" }
          , { name: "obj1" }
          , { name: "obj5" }
        ])
        c.DeleteValue("obj4")

        for index, name, obj in c.EnumRangeSparse(3, "obj2", "obj5") {
            if A_Index == 3 {
                if IsSet(name) || IsSet(obj) {
                    throw Error('Expected unset values.')
                }
                OutputDebug(index ": unset`n")
            } else {
                OutputDebug(index ": " name " - " Type(obj) "`n")
                if name != "obj" (A_Index + 1) {
                    throw Error('Invalid name in ``for`` loop.', , name)
                }
                if index != A_Index + 1 {
                    throw Error('Invalid index in ``for`` loop.', , index)
                }
                if Type(obj) != 'Object' {
                    throw Error('Invalid object type in ``for`` loop.', , Type(obj))
                }
            }
            if A_Index > 4 {
                throw Error('Too many iterations.')
            }
        }
    }
    static EnumRangeDate() {
        CallbackValue(value) {
            return value.date
        }
        c := Container.CbDateStr(CallbackValue, "yyyy-MM-dd")
        c.InsertList([
            { date: "2025-05-02" }
          , { date: "2025-05-06" }
          , { date: "2025-04-19" }
          , { date: "2025-05-19" }
          , { date: "2025-04-30" }
          , { date: "2025-06-02" }
        ])
        for index, date, obj in c.EnumRange(3, "2025-05-01", "2025-05-31") {
            OutputDebug(index ": " date " - " Type(obj) "`n")
            switch A_Index {
                case 1: _date := "2025-05-02"
                case 2: _date := "2025-05-06"
                case 3: _date := "2025-05-19"
                default: throw Error('Unexpected index.')
            }
            if _date != date || _date != obj.date {
                throw Error('Unexpected value.')
            }
        }
    }
}
