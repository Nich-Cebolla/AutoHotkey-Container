
#include ..\src\Container.ahk

if A_LineFile == A_ScriptFullPath {
    test_miscExamples()
}

class test_miscExamples {
    static Call() {
        this.PushEx()
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
}
