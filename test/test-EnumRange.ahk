
#include Container_Test.ahk

if A_LineFile == A_ScriptFullPath {
    test_EnumRange()
}

class test_EnumRange {
    static Call() {
        this.EnumRange()
        this.EnumRangeSparse()
    }
    static EnumRange() {
        len := 100
        lower := Floor(len * 0.33)
        _lower := lower - 1
        upper := Floor(len * 0.66)
        loop CONTAINER_SORTTYPE_END {
            c := Container_Test(A_Index, len, true)
            start := c[lower]
            end := c[upper]
            for value in c.EnumRange(1, start, end) {
                if value != c[_lower + A_Index] {
                    throw Error('Invalid value.')
                }
            }
            switch A_Index {
                case CONTAINER_SORTTYPE_CB_DATE
                , CONTAINER_SORTTYPE_CB_DATESTR
                , CONTAINER_SORTTYPE_CB_NUMBER
                , CONTAINER_SORTTYPE_CB_STRING
                , CONTAINER_SORTTYPE_CB_STRINGPTR
                , CONTAINER_SORTTYPE_DATEVALUE:
                    callbackValue := c.CallbackValue
                    for sortValue, value in c.EnumRange(2, start, end) {
                        if value !== c[_lower + A_Index] {
                            throw Error('Invalid value.')
                        }
                        if callbackValue(c[_lower + A_Index]) != sortValue {
                            throw Error('Invalid sort value.')
                        }
                    }
                    for index, sortValue, value in c.EnumRange(3, start, end) {
                        if index != _lower + A_Index {
                            throw Error('Invalid index.')
                        }
                        if value !== c[index] {
                            throw Error('Invalid value.')
                        }
                        if callbackValue(c[index]) != sortValue {
                            throw Error('Invalid sort value.')
                        }
                    }
                default:
                    for index, value in c.EnumRange(2, start, end) {
                        if index != _lower + A_Index {
                            throw Error('Invalid index.')
                        }
                        if value != c[index] {
                            throw Error('Invalid value.')
                        }
                    }
            }
        }
    }
    static EnumRangeSparse() {
        len := 100
        delta := 10
        lower := Floor(len * 0.33)
        _lower := lower - 1
        upper := Floor(len * 0.66)
        removed := Container.Number()
        removed.Capacity := len / delta - 1
        loop CONTAINER_SORTTYPE_END {
            c := Container_Test(A_Index, len, true)
            removed.Length := 0
            k := 5
            loop removed.Capacity {
                if k == lower || k == upper {
                    removed.Push(k + 1)
                    c.Delete(k + 1)
                } else {
                    removed.Push(k)
                    c.Delete(k)
                }
                k += delta
            }
            start := c[lower]
            end := c[upper]
            for value in c.EnumRangeSparse(1, start, end) {
                if IsSet(value) {
                    if value != c[_lower + A_Index] {
                        throw Error('Invalid value.')
                    }
                } else if !removed.Find(_lower + A_Index) {
                    throw Error('An unset value occurred at an unexpected index.')
                }
            }
            switch A_Index {
                case CONTAINER_SORTTYPE_CB_DATE
                , CONTAINER_SORTTYPE_CB_DATESTR
                , CONTAINER_SORTTYPE_CB_NUMBER
                , CONTAINER_SORTTYPE_CB_STRING
                , CONTAINER_SORTTYPE_CB_STRINGPTR
                , CONTAINER_SORTTYPE_DATEVALUE:
                    callbackValue := c.CallbackValue
                    for sortValue, value in c.EnumRangeSparse(2, start, end) {
                        if IsSet(value) {
                            if value !== c[_lower + A_Index] {
                                throw Error('Invalid value.')
                            }
                            if callbackValue(c[_lower + A_Index]) != sortValue {
                                throw Error('Invalid sort value.')
                            }
                        } else if !removed.Find(_lower + A_Index) {
                            throw Error('An unset value occurred at an unexpected index.')
                        }
                    }
                    for index, sortValue, value in c.EnumRangeSparse(3, start, end) {
                        if index != _lower + A_Index {
                            throw Error('Invalid index.')
                        }
                        if IsSet(value) {
                            if value !== c[index] {
                                throw Error('Invalid value.')
                            }
                            if callbackValue(c[index]) != sortValue {
                                throw Error('Invalid sort value.')
                            }
                        } else if !removed.Find(index) {
                            throw Error('An unset value occurred at an unexpected index.')
                        }
                    }
                default:
                    for index, value in c.EnumRangeSparse(2, start, end) {
                        if index != _lower + A_Index {
                            throw Error('Invalid index.')
                        }
                        if IsSet(value) {
                            if value != c[index] {
                                throw Error('Invalid value.')
                            }
                        } else if !removed.Find(index) {
                            throw Error('An unset value occurred at an unexpected index.')
                        }
                    }
            }
        }
    }
}
