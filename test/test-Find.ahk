
#include ..\src\Container.ahk
#include Container_Test.ahk

class test_Find {
    static __New() {
        this.DeleteProp('__New')
        this.Len := 1000
    }
    static Call() {
        this.FindNumber()
        this.FindString()
        this.FindStringPtr()
        this.FindCbNumber()
        this.FindCbString()
        this.FindCbMisc()
    }
    static FindNumber() {
        c := Container_Test(CONTAINER_SORTTYPE_NUMBER, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if v != value || c[r] != c[i] {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' v '; output index: ' r '; output value: ' value)
            }
        }
    }
    static FindString() {
        c := Container_Test(CONTAINER_SORTTYPE_STRING, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if v != value || c[r] != c[i] {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' v '; output index: ' r '; output value: ' value)
            }
        }
    }
    static FindStringPtr() {
        c := Container_Test(CONTAINER_SORTTYPE_STRINGPTR, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if StrGet(v, CONTAINER_DEFAULT_ENCODING) != StrGet(value, CONTAINER_DEFAULT_ENCODING) || StrGet(c[r], CONTAINER_DEFAULT_ENCODING) != StrGet(c[i], CONTAINER_DEFAULT_ENCODING) {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' StrGet(v, CONTAINER_DEFAULT_ENCODING) '; output index: ' r '; output value: ' StrGet(value, CONTAINER_DEFAULT_ENCODING))
            }
        }
    }
    static FindCbNumber() {
        c := Container_Test(CONTAINER_SORTTYPE_CB_NUMBER, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        CallbackValue := c.CallbackValue
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if CallbackValue(v) != CallbackValue(value) || CallbackValue(c[r]) != CallbackValue(c[i]) {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' CallbackValue(v) '; output index: ' r '; output value: ' CallbackValue(value))
            }
        }
    }
    static FindCbString() {
        c := Container_Test(CONTAINER_SORTTYPE_CB_STRING, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        CallbackValue := c.CallbackValue
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if CallbackValue(v) != CallbackValue(value) || CallbackValue(c[r]) != CallbackValue(c[i]) {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' CallbackValue(v) '; output index: ' r '; output value: ' CallbackValue(value))
            }
        }
    }
    static FindCbStringPtr() {
        c := Container_Test(CONTAINER_SORTTYPE_CB_STRINGPTR, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        CallbackValue := c.CallbackValue
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if r != i {
                throw Error('Mismatched indices.', -1, 'Input: c[' i '] = ' StrGet(CallbackValue(v), CONTAINER_DEFAULT_ENCODING) '; output index: ' r '; output value: ' StrGet(CallbackValue(value), CONTAINER_DEFAULT_ENCODING))
            }
            if StrGet(CallbackValue(v), CONTAINER_DEFAULT_ENCODING) != StrGet(CallbackValue(value), CONTAINER_DEFAULT_ENCODING)
            || StrGet(CallbackValue(c[i]), CONTAINER_DEFAULT_ENCODING) != StrGet(CallbackValue(c[r]), CONTAINER_DEFAULT_ENCODING) {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' StrGet(CallbackValue(v), CONTAINER_DEFAULT_ENCODING) '; output index: ' r '; output value: ' StrGet(CallbackValue(value), CONTAINER_DEFAULT_ENCODING))
            }
        }
    }
    static FindCbMisc() {
        c := Container_Test(CONTAINER_SORTTYPE_MISC, this.Len, true)
        index := []
        loop this.Len / 10 {
            index.Push(Random(1, this.Len))
        }
        CallbackValue := (item) => item.Timestamp
        for i in index {
            v := c[i]
            r := c.Find(v, &value)
            if r != i {
                throw Error('Mismatched indices.', -1, 'Input: c[' i '] = ' CallbackValue(v) '; output index: ' r '; output value: ' CallbackValue(value))
            }
            if CallbackValue(v) != CallbackValue(value) {
                throw Error('Mismatched values.', -1, 'Input: c[' i '] = ' CallbackValue(v) '; output index: ' r '; output value: ' CallbackValue(value))
            }
        }
    }
}
