
#include Container_Test.ahk

class test_InsertIfAbsent {
    static __New() {
        this.DeleteProp('__New')
        this.Len := 100
    }
    static Call() {
        loop CONTAINER_SORTTYPE_END {
            ; Container_Test always produces containers with all unique values
            c := Container_Test(A_Index, this.Len, true)
            _Proc1(1)
            _Proc2(1)
            _Proc1(2)
            _Proc2(2)
            _Proc1(50)
            _Proc2(50)
            _Proc1(99)
            _Proc2(99)
            _Proc1(100)
            _Proc2(100)
            val1 := c[1]
            val100 := c[100]
            c[1] := c[2]
            c[100] := c[99]
            _Compare(c.InsertIfAbsent(val1), 1)
            _Compare(c.InsertIfAbsent(val100), 102)
        }

        _Proc1(index) {
            _Compare(c.InsertIfAbsentSparse(c.Delete(index)), index)
        }
        _Proc2(index) {
            _Compare(c.InsertIfAbsent(c[index]), '')
            _Compare(c.InsertIfAbsentSparse(c[index]), '')
        }
        _Compare(index, expected) {
            if index != expected {
                throw Error('Invalid return index.', , 'Index: ' index '; expected: ' expected)
            }
        }
    }
}
