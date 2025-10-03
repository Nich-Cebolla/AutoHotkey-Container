
#include Container_Test.ahk

if A_LineFile == A_ScriptFullPath {
    test_DatePreprocess()
}

class test_DatePreprocess {
    static __New() {
        this.DeleteProp('__New')
        this.Len := 1000
    }
    static Call() {
        _c := Container_Test(CONTAINER_SORTTYPE_CB_DATESTR, this.Len, false)
        ; We should be able to call DatePreprocess directly with no additional parameters
        ; because c.__DateParser is set and c.CallbackCompare is set
        c := _c.Clone()
        c.DatePreprocess()
        ; We should be able to sort with no extra code
        _Test(c.Clone().QuickSort())
        _Test(c.Clone().Sort())

        c := _c

        ; From the original container before calling DatePreprocess, we should be able to search
        ; for date strings
        CallbackValue := c.CallbackValue
        c := c.QuickSort()
        loop 10 {
            _FindCb(Random(1, c.Length))
        }

        ; After DatePreprocess we should still be able to search for date strings
        c.DatePreprocess()
        loop 10 {
            _FindCb(Random(1, c.Length))
        }

        ; We should be able to search just using objects
        loop 10 {
            _Find(Random(1, c.Length))
        }

        ; We should be able to search by converting date strings
        loop 10 {
            _Convert(Random(1, c.Length))
        }

        ; And we should be able to search by converting the objects to their date value
        ; (though normally we wouldn't do this because the objects have the __Container_DateValue
        ; property already)
        loop 10 {
            _ConvertCb(Random(1, c.Length))
        }

        return

        _Compare(index, expected) {
            if index != expected {
                throw Error('Invalid return index.', , 'Index: ' index '; expected: ' expected)
            }
        }
        _Convert(index) {
            _Compare(c.Find(c.DateConvert(CallbackValue(c[index]))), index)
        }
        _ConvertCb(index) {
            _Compare(c.Find(c.DateConvertCb(c[index])), index)
        }
        _Find(index) {
            _Compare(c.Find(c[index]), index)
        }
        _FindCb(index) {
            _Compare(c.Find(CallbackValue(c[index])), index)
        }
        _Test(c) {
            previous := c[1]
            loop c.Length - 1 {
                if previous.__Container_DateValue > c[A_Index + 1].__Container_DateValue {
                    throw Error('Out of order.')
                }
            }
        }
    }
}
