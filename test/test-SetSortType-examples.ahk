
#include ..\src\Container.ahk

test_SetSortTypeExamples() {

    ; CONTAINER_SORTTYPE_CB_DATE
    c := Container(
        { timestamp: '20250312122930' }
      , { timestamp: '20250411122900' }
      , { timestamp: '20251015091805' }
    )
    c.SetSortType(CONTAINER_SORTTYPE_CB_DATE)
    c.SetCallbackValue((value) => value.timestamp)
    c.SetCompareDate()
    c.Sort()

    ; CONTAINER_SORTTYPE_CB_DATESTR

    c := Container(
        { date: '2025-03-12 12:29:30' }
      , { date: '2025-04-11 12:29:00' }
      , { date: '2025-10-15 09:18:05' }
    )
    c.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
    c.SetCallbackValue((value) => value.date)
    c.SetCompareDateStr('yyyy-MM-dd HH:mm:ss')
    c.Sort()

    ; CONTAINER_SORTTYPE_CB_NUMBER

    c := Container(
        { value: 298581 }
      , { value: 195801 }
      , { value: 585929 }
    )
    c.SetSortType(CONTAINER_SORTTYPE_CB_NUMBER)
    c.SetCallbackValue((value) => value.value)
    c.Sort()

    ; CONTAINER_SORTTYPE_CB_STRING

    c := Container(
        { name: 'obj4' }
      , { name: 'obj3' }
      , { name: 'obj1' }
    )
    c.SetSortType(CONTAINER_SORTTYPE_CB_STRING)
    c.SetCallbackValue((value) => value.name)
    c.SetCompareStringEx()
    c.Sort()

    ; CONTAINER_SORTTYPE_CB_STRINGPTR

    c := Container(
        SomeStruct1("obj4")
      , SomeStruct1("obj3")
      , SomeStruct1("obj1")
    )
    c.SetSortType(CONTAINER_SORTTYPE_CB_STRINGPTR)
    c.SetCallbackValue((value) => value.__pszText.Ptr)
    c.SetCompareStringEx()
    c.Sort()

    ; CONTAINER_SORTTYPE_DATE

    c := Container(
        '20250312122930'
      , '20250411122900'
      , '20251015091805'
    )
    c.SetSortType(CONTAINER_SORTTYPE_DATE)
    c.SetCompareDate()
    c.Sort()

    ; CONTAINER_SORTTYPE_DATESTR

    c := Container(
        '2025-03-12 12:29:30'
      , '2025-04-11 12:29:00'
      , '2025-10-15 09:18:05'
    )
    c.SetSortType(CONTAINER_SORTTYPE_DATESTR)
    c.SetCompareDateStr('yyyy-MM-dd HH:mm:ss')
    c.Sort()

    ; CONTAINER_SORTTYPE_MISC is skipped here.

    ; CONTAINER_SORTTYPE_NUMBER

    c := Container(
        298581
      , 195801
      , 585929
    )
    c.SetSortType(CONTAINER_SORTTYPE_NUMBER)
    c.Sort()

    ; CONTAINER_SORTTYPE_STRING

    c := Container(
        'string4'
      , 'string3'
      , 'string1'
    )
    c.SetSortType(CONTAINER_SORTTYPE_STRING)
    c.SetCompareStringEx()
    c.Sort()

    ; CONTAINER_SORTTYPE_STRINGPTR

    buf1 := StrBuf('string4')
    buf2 := StrBuf('string3')
    buf3 := StrBuf('string1')
    c := Container(
        buf1.Ptr
      , buf2.Ptr
      , buf3.Ptr
    )
    c.SetSortType(CONTAINER_SORTTYPE_STRINGPTR)
    c.SetCompareStringEx()
    c.Sort()

    StrBuf(str) {
        buf := Buffer(StrPut(str, 'cp1200'))
        StrPut(str, buf, 'cp1200')
        return buf
    }
}


class SomeStruct1 {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CbSize := 16 ; arbitrary size for example
        proto.__pszText_offset := 8 ; arbitrary offset for example
    }
    __New(pszText) {
        this.Buffer := Buffer(this.cbSize)
        this.__pszText := Buffer(StrPut(pszText, 'cp1200'))
        StrPut(pszText, this.__pszText, 'cp1200')
        NumPut('ptr', this.__pszText.Ptr, this, this.__pszText_offset)
    }
    pszText {
        Get => StrGet(this.__pszText, 'cp1200')
        Set {
            bytes := StrPut(Value, 'cp1200')
            if bytes > this.__pszText.Size {
                this.__pszText.Size := bytes
                NumPut('ptr', this.__pszText.Ptr, this, this.__pszText_offset)
            }
            StrPut(Value, this.__pszText, 'cp1200')
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
