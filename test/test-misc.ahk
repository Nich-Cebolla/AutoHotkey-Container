
#include Container_Test.ahk

if !A_IsCompiled && A_LineFile == A_ScriptFullPath {
    test_misc()
}

class test_misc {
    static __New() {
        this.DeleteProp('__New')
        this.Len := 100
    }
    static Call() {
        this.Compare()
        this.DeepClone()
        this.Insert()
        this.InsertSparse()
    }
    static Compare() {
        c := Container_Test(CONTAINER_SORTTYPE_NUMBER, this.Len, true)
        n := c[1] - 1
        index := c.Find(n)
        if !index {
            ; Since it didn't return an index, we know `MyValue` is outside of the range of the container.
            ; To place the value in order, we must know if it should be placed at the beginning or end.
            if c.Compare(n, 1) < 0 {
                c.InsertAt(1, n)
            } else {
                c.Push(n)
            }
        }
    }
    static DeepClone() {
        c1 := Container_Test(CONTAINER_SORTTYPE_CB_DATESTR, this.Len, true)
        c2 := c1.DeepClone()
        for prop in c1.OwnProps() {
            if !c2.HasOwnProp(prop) {
                throw PropertyError('Missing property.', , prop)
            }
        }
        callbackValue := c1.CallbackValue
        for value in c1 {
            if callbackValue(value) != callbackValue(c2[A_Index]) {
                throw Error('Values out of order.', , 'Index: ' A_Index)
            }
            if ObjPtr(value) = ObjPtr(c2[A_Index]) {
                throw Error('The objects are the same.', , 'Index: ' A_Index)
            }
        }
    }
    static Insert() {
        c := Container_Test(CONTAINER_SORTTYPE_NUMBER, this.Len, true)
        n := c[1] - 1
        c.Insert(n)
        if c[1] != n {
            throw Error('Mismatched values.')
        }
        n := c[-1] + 1
        c.Insert(n)
        if c[-1] != n {
            throw Error('Mismatched values.')
        }
        i := floor(c.length / 2)
        n := c[i] + 1
        c.Insert(n)
        if c[i + 1] != n {
            throw Error('Mismatched values.')
        }
    }
    static InsertSparse() {
        c := Container_Test(CONTAINER_SORTTYPE_NUMBER, this.Len, true)
        n := c[1] - 1
        c.Delete(1)
        c.InsertSparse(n)
        if c[1] != n {
            throw Error('Mismatched values.')
        }
        if c.Length != this.Len {
            throw Error('An item was added to the container when it should have replaced an unset index.')
        }
        n := c[-1] + 1
        c.Delete(-1)
        c.InsertSparse(n)
        if c[-1] != n {
            throw Error('Mismatched values.')
        }
        if c.Length != this.Len {
            throw Error('An item was added to the container when it should have replaced an unset index.')
        }
        i := Floor(c.length / 2)
        n := c[i] + 1
        c.Delete(i)
        c.Delete(i - 1)
        c.InsertSparse(n)
        if c[i] != n {
            throw Error('Mismatched values.')
        }
        if c.Length != this.Len {
            throw Error('An item was added to the container when it should have replaced an unset index.')
        }
    }
}
