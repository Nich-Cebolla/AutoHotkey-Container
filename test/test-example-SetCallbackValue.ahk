
#include ..\src\Container.ahk


class SomeStruct {
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

test()

test() {
    c1 := Container(
        SomeStruct("obj4")
      , SomeStruct("obj1")
      , SomeStruct("obj3")
      , SomeStruct("obj2")
    )
    c1.SetCompareStringEx()
    c1.SetCallbackValue((value) => value.__pszText.Ptr)
    c1.SortType := CONTAINER_SORTTYPE_CB_STRINGPTR
    c1.Sort()

    c2 := Container(
        { Name: "obj4" }
      , { Name: "obj1" }
      , { Name: "obj3" }
      , { Name: "obj2" }
    )
    c2.SetCompareStringEx()
    c2.SetCallbackValue((value) => value.Name)
    c2.SortType := CONTAINER_SORTTYPE_CB_STRING
    c2.Sort()

    SomeStruct.Prototype.DefineProp('Name', { Get: (Self) => StrGet(Self.__pszText, 'cp1200') })
    i := 0
    for c in [ c1, c2 ] {
        ++i
        previous := 0
        for val in c {
            if !RegExMatch(val.Name, '\d+', &match) {
                throw Error('No match.')
            }
            if previous > match[0] {
                throw Error('Out of order.')
            }
            previous := match[0]
        }
    }
    sleep 1
}
