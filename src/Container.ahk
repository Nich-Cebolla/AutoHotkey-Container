
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
#include <LibraryManager>

; https://github.com/Nich-Cebolla/AutoHotkey-DateObj/blob/main/DateObj.ahk
; Only needed if using sort type CONTAINER_SORTTYPE_DATESTR or CONTAINER_SORTTYPE_CB_DATESTR
#include *i <DateObj>

; Only needed if using the class.
#include *i NlsVersionInfo.ahk

#include lib.ahk


class Container extends Array {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CallbackCompare := proto.CallbackValue := proto.CompareDateCentury :=
        proto.CallbackCompareValue := proto.CompareStringVersionInformation :=
        proto.CompareStringLocaleName := proto.__DateParser :=
        ''
        proto.SortType := 0
        if !IsSet(CONTAINER_SORTTYPE_NUMBER) {
            Container_SetConstants()
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Compares the input value with a value in the container.
     * @example
     *  if index := c.Find(MyValue) {
     *      ; do something
     *  } else {
     *      ; Since it didn't return an index, we know `MyValue` is outside of the range of the container.
     *      ; To place the value in order, we must know if it should be placed at the beginning or end.
     *      if c.Compare(MyValue, 1) < 0 {
     *          c.InsertAt(1, MyValue)
     *      } else {
     *          c.Push(MyValue)
     *      }
     *  }
     * @
     * @param {*} Value - Any value to compare to one of the values in the container.
     * @param {Integer} Index - The index of the value to compare with `Value`.
     */
    Compare(Value, Index) {
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                return Value - this[Index]
            case CONTAINER_SORTTYPE_STRING:
                if IsNumber(Value) {
                    return this.CallbackCompare.Call(Value, StrPtr(this[Index]))
                } else {
                    return this.CallbackCompare.Call(StrPtr(Value), StrPtr(this[Index]))
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                if IsNumber(Value) {
                    return this.CallbackCompare.Call(Value, this[Index])
                } else {
                    return this.CallbackCompare.Call(StrPtr(Value), this[Index])
                }
            case CONTAINER_SORTTYPE_DATE:
                return this.CallbackCompare.Call(Value, this[Index])
            case CONTAINER_SORTTYPE_DATESTR:
                if IsNumber(Value) {
                    return this.CallbackCompareValue.Call(DateObj.FromTimestamp(Value), this[Index])
                } else {
                    return this.CallbackCompare.Call(Value, this[Index])
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                if IsNumber(Value) {
                    return Value - this.CallbackValue.Call(this[Index])
                } else {
                    return this.CallbackValue.Call(Value) - this.CallbackValue.Call(this[Index])
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                if IsNumber(Value) {
                    return this.CallbackCompare.Call(Value, StrPtr(this.CallbackValue.Call(this[Index])))
                } else if IsObject(Value) {
                    return this.CallbackCompare.Call(StrPtr(this.CallbackValue.Call(Value)), StrPtr(this.CallbackValue.Call(this[Index])))
                } else {
                    return this.CallbackCompare.Call(StrPtr(Value), StrPtr(this.CallbackValue.Call(this[Index])))
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                if IsNumber(Value) {
                    return this.CallbackCompare.Call(Value, this.CallbackValue.Call(this[Index]))
                } else if IsObject(Value) {
                    return this.CallbackCompare.Call(this.CallbackValue.Call(Value), this.CallbackValue.Call(this[Index]))
                } else {
                    return this.CallbackCompare.Call(StrPtr(Value), this.CallbackValue.Call(this[Index]))
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                if IsNumber(Value) {
                    return this.CallbackCompare.Call(Value, this.CallbackValue.Call(this[Index]))
                } else {
                    return this.CallbackCompare.Call(this.CallbackValue.Call(Value), this.CallbackValue.Call(this[Index]))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                date1 := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date1 := DateObj.FromTimestamp(Value)
                    } else {
                        date1 := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date1 {
                    return this.CallbackCompareValue.Call(date1, this.CallbackValue.Call(this[Index]))
                } else {
                    return this.CallbackCompare.Call(this.CallbackValue.Call(Value), this.CallbackValue.Call(this[Index]))
                }
            case CONTAINER_SORTTYPE_CB_MISC:
                return this.CallbackCompare.Call(Value, this[Index])
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Creates a new {@link Container}, copying the values of any own properties of this object.
     */
    Copy() {
        c := Container()
        for prop, val in this.OwnProps() {
            c.%prop% := this.%prop%
        }
        return c
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Calls {@link Container.Prototype.Find} to find a value in the container. If the
     * value is found, deletes the valu. If the value is not found, throws an error.
     *
     * @param {*} Value - The value to find and delete.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the found value.
     *
     * @returns {Integer} - If the value is found, the index the value was located.
     *
     * @throws {UnsetItemError} - "Value not found."
     */
    DeleteValue(Value, &OutValue?) {
        if index := this.Find(Value, &OutValue) {
            this.Delete(index)
            return index
        } else {
            throw UnsetItemError('Value not found.', -1, IsObject(Value) ? '{ ' Type(Value) ' }' : Value)
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Calls {@link Container.Prototype.FindSparse} to find a value in the container. If the
     * value is found, deletes the value, leaving the index unset.
     *
     * @param {*} Value - The value to find and delete.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the found value.
     *
     * @returns {Integer} - If the value is found, the index the value was located. Else, 0.
     */
    DeleteValueIf(Value, &OutValue?) {
        if index := this.Find(Value, &OutValue) {
            this.Delete(index)
            return index
        } else {
            return 0
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * Calls {@link Container.Prototype.FindSparse} to find a value in the container. If the
     * value is found, deletes the value, leaving the index unset.
     *
     * @param {*} Value - The value to find and delete.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the found value.
     *
     * @returns {Integer} - If the value is found, the index the value was located. Else, 0.
     */
    DeleteValueIfSparse(Value, &OutValue?) {
        if index := this.FindSparse(Value, &OutValue) {
            this.Delete(index)
            return index
        } else {
            return 0
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * Calls {@link Container.Prototype.FindSparse} to find a value in the container. If the
     * value is found, deletes the valu. If the value is not found, throws an error.
     *
     * @param {*} Value - The value to find and delete.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the found value.
     *
     * @returns {Integer} - If the value is found, the index the value was located.
     *
     * @throws {UnsetItemError} - "Value not found."
     */
    DeleteValueSparse(Value, &OutValue?) {
        if index := this.FindSparse(Value, &OutValue) {
            this.Delete(index)
            return index
        } else {
            throw UnsetItemError('Value not found.', -1, IsObject(Value) ? '{ ' Type(Value) ' }' : Value)
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Iterates the values in the container, passing each value to a callback function. If the callback
     * function returns nonzero, {@link Container.Prototype.Every} will return 1 immediately.
     * If the callback function always returns 0 or an empty string, {@link Container.Prototype.Every}
     * will return 0 after processing every value.
     *
     * @param {*} Callback - If `ThisArg` is set, the function can accept two to four parameters.
     *
     * Parameters:
     * - `ThisArg` - the hidden `this` parameter.
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * If `ThisArg` is unset, the function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: zero or an empty string to continue the process; a nonzero value to end the process
     * and direct {@link Container.Prototype.Every} to return 1.
     *
     * @param {*} [ThisArg] - The value to pass to the hidden `this` parameter when executing the
     * callback. See the file "test\ThisArg-example.ahk" for working examples.
     *
     * @returns {Integer} - If the callback returns a nonzero value, 1. Else, 0.
     */
    Every(Callback, ThisArg?) {
        if IsSet(ThisArg) {
            loop this.Length {
                if Callback(ThisArg, this[A_Index], A_Index, this) {
                    return 1
                }
            }
        } else {
            loop this.Length {
                if Callback(this[A_Index], A_Index, this) {
                    return 1
                }
            }
        }
        return 0
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Iterates the values in the container, passing each value to a callback function. If the callback
     * function returns nonzero, {@link Container.Prototype.EverySparse} will return 1 immediately.
     * If the callback function always returns 0 or an empty string, {@link Container.Prototype.EverySparse}
     * will return 0 after processing every value.
     *
     * @param {*} Callback - If `ThisArg` is set the function can accept two to four parameters.
     * Parameters 2-4 must be optional.
     *
     * Parameters:
     * - `ThisArg` - the hidden `this` parameter.
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * If `ThisArg` is unset, the function can accept one to three parameters. Parameters 1-3 must be
     * optional.
     *
     * Parameters:
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: zero or an empty string to continue the process; a nonzero value to end the process
     * and direct {@link Container.Prototype.EverySparse} to return 1.
     *
     * @param {*} [ThisArg] - The value to pass to the hidden `this` parameter when executing the
     * callback. See the file "test\ThisArg-example.ahk" for working examples.
     *
     * @returns {Integer} - If the callback returns a nonzero value, 1. Else, 0.
     */
    EverySparse(Callback, ThisArg?) {
        if IsSet(ThisArg) {
            loop this.Length {
                if this.Has(A_Index) {
                    if Callback(ThisArg, this[A_Index], A_Index, this) {
                        return 1
                    }
                } else if Callback(ThisArg, , A_Index, this) {
                    return 1
                }
            }
        } else {
            loop this.Length {
                if this.Has(A_Index) {
                    if Callback(this[A_Index], A_Index, this) {
                        return 1
                    }
                } else if Callback(, A_Index, this) {
                    return 1
                }
            }
        }
        return 0
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * This version of the function does not search for multiple indices; it only finds
     * the first index from left-to-right that contains the input value.
     *
     * @param {*} Value - The value to find.
     *
     * @param {Number} [IndexStart = 1] - The index to start the search at.
     *
     * @param {Number} [IndexEnd = this.Length] - The index to end the search at.
     *
     * @returns {Integer} - If the value is found, the first index containing the value from left
     * to right. Else, 0.
     */
    Find(Value, &OutValue?, IndexStart := 1, IndexEnd := this.Length) {
        if IndexEnd < IndexStart {
            throw Error('The end index is less than the start index.'
            , -1, 'IndexEnd: ' IndexEnd '; IndexStart: ' IndexStart)
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare := _CompareNumber
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareString
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare := _CompareCbNumber
                if !IsNumber(Value) {
                    Value := CallbackValue(Value)
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbString
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        _value := CallbackValue(Value)
                        Value := StrPtr(_value)
                    } else {
                        _value := Value
                        Value := StrPtr(Value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbStringPtr
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := DateObj.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := DateObj.FromTimestamp(Value)
                    } else {
                        date := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date {
                    Value := date
                } else {
                    Value := this.CallbackValue.Call(Value)
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        stop := 0
        R := IndexEnd - IndexStart + 1
        while R * 0.5 ** (stop + 1) * 14 > 27 {
            stop++
            i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
            if x := Compare() {
                if x > 0 {
                    IndexStart := i
                } else {
                    IndexEnd := i
                }
            } else {
                loop i - IndexStart {
                    --i
                    if Compare() {
                        OutValue := this[i + 1]
                        return i + 1
                    }
                }
                return i
            }
        }
        i := IndexStart
        loop IndexEnd - i + 1 {
            if Compare() {
                ++i
            } else {
                OutValue := this[i]
                return i
            }
        }

        return 0

        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbStringPtr() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue() => CallbackCompare(Value, this[i])
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * @description - Performs a binary search on an array to find one or more indices that contain
     * the input value. If there are multiple indices with the input value, the index returned by
     * the function will be the lowest index, and the index assigned to `OutLastIndex` will be the
     * highest index.
     *
     * @param {*} Value - The value to search for. This value may be an object as long as its
     * numeric/string value can be returned by {@link Container#CallbackCompare}.
     *
     * @param {Vthisef} [OutLastIndex] - If there are multiple indices containing the input value,
     * `OutLastIndex` is set with the greatest index which contains the input value. If there is one
     * index containing the input value, `OutLastIndex` will be the same as the return value.
     *
     * @param {Number} [IndexStart = 1] - The index to start the search at.
     *
     * @param {Number} [IndexEnd = this.Length] - The index to end the search at.
     *
     * @returns {Integer} - If the value is found, the first index containing the value. Else, 0.
     */
    FindAll(Value, &OutLastIndex?, IndexStart := 1, IndexEnd := this.Length) {
        if IndexEnd < IndexStart {
            throw Error('The end index is less than the start index.'
            , -1, 'IndexEnd: ' IndexEnd '; IndexStart: ' IndexStart)
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare := _CompareNumber
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareString
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare := _CompareCbNumber
                if !IsNumber(Value) {
                    Value := CallbackValue(Value)
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbString
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        _value := CallbackValue(Value)
                        Value := StrPtr(_value)
                    } else {
                        _value := Value
                        Value := StrPtr(Value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbStringPtr
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := DateObj.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := DateObj.FromTimestamp(Value)
                    } else {
                        date := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date {
                    Value := date
                } else {
                    Value := this.CallbackValue.Call(Value)
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        stop := 0
        R := IndexEnd - IndexStart + 1
        while R * 0.5 ** (stop + 1) * 14 > 27 {
            stop++
            i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
            if x := Compare() {
                if x > 0 {
                    IndexStart := i
                } else {
                    IndexEnd := i
                }
            } else {
                Start := i
                --i
                loop i - IndexStart + 1 {
                    if Compare() {
                        break
                    } else {
                        --i
                    }
                }
                Result := i + 1
                i := Start + 1
                loop IndexEnd - i + 1 {
                    if Compare() {
                        break
                    } else {
                        ++i
                    }
                }
                OutLastIndex := i - 1
                return Result
            }
        }
        i := IndexStart
        loop IndexEnd - i + 1 {
            if Compare() {
                ++i
            } else {
                Result := i
                break
            }
        }
        ; Value was not found
        if !IsSet(Result) {
            return 0
        }
        ++i
        loop IndexEnd - i + 1 {
            if Compare() {
                break
            } else {
                ++i
            }
        }
        OutLastIndex := i - 1
        return Result

        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbStringPtr() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue() => CallbackCompare(Value, this[i])
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * @description - Performs a binary search on an array to find one or more indices that contain
     * the input value. {@link Container.Prototype.FindSparse} allows for unset indices, but
     * every set index must be sorted in order.
     *
     * @param {*} Value - The value to search for. This value may be an object as long
     * as its numerical value can be returned by the `ValueCallback` function.
     *
     * @param {Vthisef} [OutLastIndex] - If there are multiple indices containing the input value,
     * `OutLastIndex` is set with the greatest index which contains the input value. If there is one
     * index containing the input value, `OutLastIndex` will be the same as the return value.
     *
     * @param {Number} [IndexStart = 1] - The index to start the search at.
     *
     * @param {Number} [IndexEnd = this.Length] - The index to end the search at.
     *
     * @returns {Integer} - The index of the first value that satisfies the condition.
     */
    FindAllSparse(Value, &OutLastIndex?, IndexStart := 1, IndexEnd := this.Length) {
        if IndexEnd < IndexStart {
            throw Error('The end index is less than the start index.'
            , -1, 'IndexEnd: ' IndexEnd '; IndexStart: ' IndexStart)
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare := _CompareNumber
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareString
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare := _CompareCbNumber
                if !IsNumber(Value) {
                    Value := CallbackValue(Value)
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbString
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        _value := CallbackValue(Value)
                        Value := StrPtr(_value)
                    } else {
                        _value := Value
                        Value := StrPtr(Value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbStringPtr
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := DateObj.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := DateObj.FromTimestamp(Value)
                    } else {
                        date := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date {
                    Value := date
                } else {
                    Value := this.CallbackValue.Call(Value)
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        stop := 0
        R := IndexEnd - IndexStart + 1
        while R * 0.5 ** (stop + 1) * 14 > 27 {
            stop++
            if !this.Has(i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)) {
                if !_GetNearest() {
                    return 0
                }
            }
            if x := Compare() {
                if x > 0 {
                    IndexStart := i
                } else {
                    IndexEnd := i
                }
            } else {
                Start := Result := OutLastIndex := i
                loop i - IndexStart {
                    if this.Has(--i) {
                        if Compare() {
                            break
                        } else {
                            Result := i
                        }
                    }
                }
                i := Start
                loop IndexEnd - i {
                    if this.Has(++i) {
                        if Compare() {
                            break
                        } else {
                            OutLastIndex := i
                        }
                    }
                }
                return Result
            }
        }
        i := IndexStart - 1
        loop IndexEnd - i {
            if this.Has(++i) {
                if !Compare() {
                    Result := OutLastIndex := i
                    break
                }
            }
        }
        ; Value was not found
        if !IsSet(Result) {
            return 0
        }
        OutLastIndex := Result
        loop IndexEnd - i {
            if this.Has(++i) {
                if Compare() {
                    break
                } else {
                    OutLastIndex := i
                }
            }
        }
        return Result

        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbStringPtr() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue() => CallbackCompare(Value, this[i])
        _GetNearest() {
            Start := i
            loop IndexEnd - i {
                if this.Has(++i) {
                    return 1
                }
            }
            i := Start
            loop i - IndexStart {
                if this.Has(--i) {
                    return 1
                }
            }
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Searches the for the index which contains the first value that satisfies the condition.
     *
     * @param {*} Value - The value to search for. `Value` may be an object as long as its
     * numeric value can be returned by {@link Container#CallbackCompare}.
     *
     * @param {Vthisef} [OutValue] - A variable that will receive the raw value at the found index.
     *
     * @param {String} [Condition='>='] - The inequality symbol indicating what condition satisfies
     * the search. Valid values are:
     * - ">": `QuickFind` returns the index of the first value greater than the input value.
     * - ">=": `QuickFind` returns the index of the first value greater than or equal to the input value.
     * - "<": `QuickFind` returns the index of the first value less than the input value.
     * - "<=": `QuickFind` returns the index of the first value less than or equal to the input value.
     *
     * @param {Number} [IndexStart = 1] - The index to start the search at.
     *
     * @param {Number} [IndexEnd = this.Length] - The index to end the search at.
     *
     * @returns {Integer} - The index of the first value that satisfies the condition.
     */
    FindInequality(Value, &OutValue?, Condition := '>=', IndexStart := 1, IndexEnd := this.Length) {
        if IndexEnd < IndexStart {
            throw Error('The end index is less than the start index.'
            , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare1 := _CompareNumber1
                Compare2 := _CompareNumber2
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareString1
                Compare2 := _CompareString2
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackCompareValue := this.CallbackCompareValue
                Compare1 := _CompareDate1
                Compare2 := _CompareValue2
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbNumber1
                Compare2 := _CompareCbNumber2
                if !IsNumber(Value) {
                    Value := CallbackValue(Value)
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbString1
                Compare2 := _CompareCbString2
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        _value := CallbackValue(Value)
                        Value := StrPtr(_value)
                    } else {
                        _value := Value
                        Value := StrPtr(Value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
                if !IsNumber(Value) {
                    Value := this.CallbackValue.Call(Value)
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackCompareValue := this.CallbackCompareValue
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbDate1
                Compare2 := _CompareCbValue2
                date := ''
                if IsObject(Value) {
                    Value := this.CallbackValue.Call(Value)
                }
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := DateObj.FromTimestamp(Value)
                    } else {
                        date := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date {
                    Value := date
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }

        ;@region 1 Unique val
        ; This block handles conditions where there is only one unique value between `IndexStart`
        ; and `IndexEnd`.
        x := Compare2(IndexStart, IndexEnd)
        if !x {
            ; First, we validate `Value`. We might be able to skip the whole process if `Value` is
            ; out of range. We can also prepare the return value so we don't need to re-check
            ; `Condition`. The return value will be a function of the sort direction.
            i := IndexStart
            x := Compare1()
            switch Condition {
                case '>':
                    if x >= 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? IndexEnd : IndexStart
                case '>=':
                    if x > 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? IndexEnd : IndexStart
                case '<':
                    if x <= 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? IndexStart : IndexEnd
                case '<=':
                    if x < 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? IndexStart : IndexEnd
            }
            ; `Value` satisfies the condition at this point. If `IndexEnd == IndexStart`, then there is only
            ; one set index and we can return that.
            if IndexEnd == IndexStart {
                OutValue := this[IndexStart]
                return IndexStart
            }
            ; At this point, we know `Value` is valid and there are multiple indices with `Value`.
            ; Therefore, we must know the sort direction so we know whether to return `IndexStart` or
            ; `IndexEnd`.
            x := Compare2(1, this.Length)
            if x = 0 {
                ; Default to `IndexStart` because there is no sort direction.
                OutValue := this[IndexStart]
                return IndexStart
            } else if x < 0 {
                OutValue := this[Result(-1)]
                return Result(-1)
            } else {
                OutValue := this[Result(1)]
                return Result(1)
            }
        }
        ;@endregion

        ;@region Condition
        switch Condition {

            ;@region case >=
            case '>=':
                Condition := _Compare_GTE
                AltCondition := _Compare_LT
                HandleEqualValues := _HandleEqualValues_EQ
                EQ := true
                ; If the value at IndexEnd is > the value at IndexStart
                if x < 0 {
                    i := IndexEnd
                    ; If the input value is greater than the value at IndexEnd
                    if Compare1() > 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_GT_A_2
                    Sequence_LT := _Sequence_GT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := IndexStart
                    ; If the input value is greater than the value at IndexStart
                    if Compare1() > 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_GT_D_2
                    Sequence_LT := _Sequence_GT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            ;@region case >
            case '>':
                Condition := _Compare_GT
                AltCondition := _Compare_LTE
                HandleEqualValues := _HandleEqualValues_NEQ
                EQ := false
                ; If the value at IndexEnd is > the value at IndexStart
                if x < 0 {
                    i := IndexEnd
                    ; If the input value is greater than or equal to the value at IndexEnd
                    if Compare1() >= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_GT_A_2
                    Sequence_LT := _Sequence_GT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := IndexStart
                    ; If the input value is greater than or equal to the value at IndexStart
                    if Compare1() >= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_GT_D_2
                    Sequence_LT := _Sequence_GT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            ;@region case <=
            case '<=':
                Condition := _Compare_LTE
                AltCondition := _Compare_GT
                HandleEqualValues := _HandleEqualValues_EQ
                EQ := true
                ; If the value at IndexEnd is > the value at IndexStart
                if x < 0 {
                    i := IndexStart
                    ; If the input value is less than the value at IndexStart
                    if Compare1() < 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_LT_A_2
                    Sequence_LT := _Sequence_LT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := IndexEnd
                    ; If the input value is less than the value at IndexEnd
                    if Compare1() < 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_LT_D_2
                    Sequence_LT := _Sequence_LT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            ;@region case <
            case '<':
                Condition := _Compare_LT
                AltCondition := _Compare_GTE
                HandleEqualValues := _HandleEqualValues_NEQ
                EQ := false
                ; If the value at IndexEnd is > the value at IndexStart
                if x < 0 {
                    i := IndexStart
                    ; If the input value is less than or equal to the value at IndexStart
                    if Compare1() <= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_LT_A_2
                    Sequence_LT := _Sequence_LT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := IndexEnd
                    ; If the input value is less than or equal to the value at IndexEnd
                    if Compare1() <= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_LT_D_2
                    Sequence_LT := _Sequence_LT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            default: throw ValueError('Invalid condition.', -1, Condition)
        }
        ;@endregion

        stop := 0
        R := IndexEnd - IndexStart + 1
        ;@region Process
        while R * 0.5 ** (stop + 1) * 14 > 27 {
            stop++
            i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
            x := Compare1()
            if x = 0 {
                return HandleEqualValues()
            } else if Compare_Loop() {
                IndexStart := i
            } else {
                IndexEnd := i
            }
        }
        ; If we go the entire loop without landing on an equal value, then we search sequentially
        ; from `i`.
        x := Compare1()
        if x = 0 {
            return HandleEqualValues()
        } else if _CompareSimple_GT() {
            return Sequence_GT()
        } else {
            return Sequence_LT()
        }
        ;@endregion

        ;@region Compare1
        _Compare_GT() => Compare1() < 0
        _Compare_GTE() => Compare1() <= 0
        _Compare_LT() => Compare1() > 0
        _Compare_LTE() => Compare1() >= 0
        _Compare_EQ() => Compare1() = 0

        _CompareSimple_GT() => x < 0
        _CompareSimple_GTE() => x <= 0
        _CompareSimple_LT() => x > 0
        _CompareSimple_LTE() => x >= 0
        _CompareSimple_EQ() => x = 0

        _CompareNumber1() => Value - this[i]
        _CompareString1() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber1() => Value - CallbackValue(this[i])
        _CompareCbString1() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue1() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue1() => CallbackCompare(Value, this[i])
        _CompareDate1() => CallbackCompareValue(Value, this[i])
        _CompareCbDate1() => CallbackCompareValue(Value, CallbackValue(this[i]))

        _CompareNumber2(a, b) => this[a] - this[b]
        _CompareString2(a, b) => CallbackCompare(StrPtr(this[a]), StrPtr(this[b]))
        _CompareCbNumber2(a, b) => CallbackValue(this[a]) - CallbackValue(this[b])
        _CompareCbString2(a, b) => CallbackCompare(StrPtr(CallbackValue(this[a])), StrPtr(CallbackValue(this[b])))
        _CompareCbValue2(a, b) => CallbackCompare(CallbackValue(this[a]), CallbackValue(this[b]))
        _CompareValue2(a, b) => CallbackCompare(this[a], this[b])
        ;@endregion

        ;@region Sequence
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == 1
         * - > or >=
         */
        _Sequence_GT_A_1() {
            ; If `Value` > <current value>, and if GT, then we must search toward `Value`
            ; until we hit an equal or greater value. If we hit an equal value and if ET, we return
            ; that. If not ET, then we keep going until we find a greater value. Since we have
            ; already set `Condition` to check for the correct condition, we just need to check
            ; `Condition`.
            loop IndexEnd - i {
                ++i
                if Condition() {
                    OutValue := this[i]
                    return i
                }
            }
            OutValue := this[i]
            return i
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == -1
         * - > or >=
         */
        _Sequence_GT_D_1() {
            ; Same as above but in the opposite direction.
            loop i - IndexStart {
                --i
                if Condition() {
                    OutValue := this[i]
                    return i
                }
            }
            OutValue := this[i]
            return i
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == 1
         * - > or >=
         */
        _Sequence_GT_A_2() {
            ; If `Value` < <current value> and if GT, then we are already at an index that
            ; satisfies the condition, but we do not know for sure that it is the first index.
            ; So we must search toward `Value` until finding an index that does not
            ; satisfy the condition. In this case we search agains the direction of ascent.
            Previous := i
            loop i - IndexStart {
                --i
                if AltCondition() {
                    if EQ && _Compare_EQ() {
                        return HandleEqualValues()
                    } else {
                        OutValue := this[Previous]
                        return Previous
                    }
                } else {
                    Previous := i
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == -1
         * - > or >=
         */
        _Sequence_GT_D_2() {
            ; Same as above but opposite direction.
            Previous := i
            loop IndexEnd - i {
                ++i
                if AltCondition() {
                    if EQ && _Compare_EQ() {
                        return HandleEqualValues()
                    } else {
                        OutValue := this[Previous]
                        return Previous
                    }
                } else {
                    Previous := i
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == 1
         * - < or <=
         */
        _Sequence_LT_A_1() {
            ; If `Value` > <current value> and if not GT, then we are already at an index that
            ; satisfies the condition, but we do not know for sure that it is the first index.
            ; So we must search toward `Value` until finding an index that does not
            ; satisfy the condition. If we run into an equal value, and if EQ, then we can
            ; pass control over to `HandleEqualValues` because it will do the rest. If not EQ,
            ; then we can ignore equality because we just need `AltCondition` to return true.
            Previous := i
            loop IndexEnd - i {
                ++i
                if AltCondition() {
                    if EQ && _Compare_EQ() {
                        return HandleEqualValues()
                    } else {
                        OutValue := this[Previous]
                        return Previous
                    }
                } else {
                    Previous := i
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == -1
         * - < or <=
         */
        _Sequence_LT_D_1() {
            ; Same as above but opposite direction.
            Previous := i
            loop i - IndexStart {
                --i
                if AltCondition() {
                    if EQ && _Compare_EQ() {
                        return HandleEqualValues()
                    } else {
                        OutValue := this[Previous]
                        return Previous
                    }
                } else {
                    Previous := i
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == 1
         * - < or <=
         */
        _Sequence_LT_A_2() {
            ; If `Value` < <current value>, and if not GT, then we must go opposite of the
            ; direction of ascent until `Condition` returns true.
            loop i - IndexStart {
                --i
                if Condition() {
                    OutValue := this[i]
                    return i
                }
            }
            OutValue := this[i]
            return i
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == -1
         * - < or <=
         */
        _Sequence_LT_D_2() {
            ; Same as above but opposite direction.
            loop IndexEnd - i {
                ++i
                if Condition() {
                    OutValue := this[i]
                    return i
                }
            }
            OutValue := this[i]
            return i
        }
        ;@endregion

        ;@region Helpers
        ; This function is used when equality is included in the condition.
        _HandleEqualValues_EQ() {
            ; We are able to prepare for this function beforehand by understanding what direction
            ; we must search in order to find the correct index to return. Since equality is included,
            ; we must search in the opposite direction we otherwise would have, then return the
            ; index that is previous to the first index which contains a value that is NOT equivalent
            ; to `Value`.
            ; Consider an array:
            ; -500 -499 -498 -497 -497 -497 -496 -495 -494
            ; `Value := -497`
            ; If GT, then the correct index is 4 because it is the first index to contain a value
            ; that meets the condition in the search direction, so to find it we must search
            ; <DirectionofAscent> * -1 (-1 in the example) then return 4 when we get to 3.
            ; If LT, then the correct index is 6, so we must do the opposite. Specifically,
            ; we must search <DirectionofAscent> (1 in the example) then return 6 when we get to 7.
            /**
             * @example
             *  if GT {
             *      HEV_Direction := BaseDirection == 1 ? -1 : 1
             *  } else {
             *      HEV_Direction := BaseDirection == 1 ? 1 : -1
             *  }
             * @
             */
            if HEV_Direction > 0 {
                i--
                LoopCount := IndexEnd - i
            } else {
                i++
                LoopCount := i - IndexStart
            }
            loop LoopCount {
                i += HEV_Direction
                if !_Compare_EQ() {
                    break
                }
                Previous := i
            }
            OutValue := this[Previous]
            return Previous
        }
        ; This function is used when equality is not included in the condition.
        _HandleEqualValues_NEQ() {
            ; When equality is not included, the process is different. When GT, we no longer invert
            ; the direction of ascent. We are interested in the first index that contains a value
            ; which meets the condition in the same direction as the direction of ascent. When LT,
            ; we are interested in the first index that contains a value which meets the condition
            ; in the opposite direction of the direction of ascent.
            ; Consider an array:
            ; -500 -499 -498 -497 -497 -497 -496 -495 -494
            ; `Value := -497`
            ; If GT, then the correct index is 7 because it is the first index to contain a value
            ; that meets the condition in the search direction, so to find it we must search
            ; <DirectionofAscent> (1 in the example) then return 7 when we get to 7.
            ; If LT, then the correct index is 3, so we must do the opposite. Specifically,
            ; we must search <DirectionofAscent> * -1 (-1 in the example) then return 3 when we get to 3.
            /**
             * @example
             *  if GT {
             *      HEV_Direction := BaseDirection == 1 ? 1 : -1
             *  } else {
             *      HEV_Direction := BaseDirection == 1 ? -1 : 1
             *  }
             * @
             */
            loop HEV_Direction > 0 ? IndexEnd - i + 1 : i {
                i += HEV_Direction
                if !_Compare_EQ() {
                    break
                }
            }
            OutValue := this[i]
            return i
        }
        ;@endregion
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * earches the for the index which contains the first value that satisfies the condition.
     *
     * @param {*} Value - The value to search for. `Value` may be an object as long as its
     * numeric value can be returned by {@link Container#CallbackCompare}.
     *
     * @param {Vthisef} [OutValue] - A variable that will receive the raw value at the found index.
     *
     * @param {String} [Condition='>='] - The inequality symbol indicating what condition satisfies
     * the search. Valid values are:
     * - ">": `QuickFind` returns the index of the first value greater than the input value.
     * - ">=": `QuickFind` returns the index of the first value greater than or equal to the input value.
     * - "<": `QuickFind` returns the index of the first value less than the input value.
     * - "<=": `QuickFind` returns the index of the first value less than or equal to the input value.
     *
     * @param {Number} [IndexStart = 1] - The index to start the search at.
     *
     * @param {Number} [IndexEnd = this.Length] - The index to end the search at.
     *
     * @returns {Integer} - The index of the first value that satisfies the condition.
     */
    FindInequalitySparse(Value, &OutValue?, Condition := '>=', IndexStart := 1, IndexEnd := this.Length) {
        if IndexEnd < IndexStart {
            throw Error('The end index is less than the start index.'
            , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare1 := _CompareNumber1
                Compare2 := _CompareNumber2
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareString1
                Compare2 := _CompareString2
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackCompareValue := this.CallbackCompareValue
                Compare1 := _CompareDate1
                Compare2 := _CompareValue2
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbNumber1
                Compare2 := _CompareCbNumber2
                if !IsNumber(Value) {
                    Value := CallbackValue(Value)
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbString1
                Compare2 := _CompareCbString2
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        _value := CallbackValue(Value)
                        Value := StrPtr(_value)
                    } else {
                        _value := Value
                        Value := StrPtr(Value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
                if !IsNumber(Value) {
                    Value := this.CallbackValue.Call(Value)
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackCompareValue := this.CallbackCompareValue
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbDate1
                Compare2 := _CompareCbValue2
                date := ''
                if IsObject(Value) {
                    Value := this.CallbackValue.Call(Value)
                }
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := DateObj.FromTimestamp(Value)
                    } else {
                        date := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date {
                    Value := date
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }

        ;@region Get left-right
        ; This block starts to identify the sort direction, and also sets `left` and `right` in the
        ; process.
        i := IndexStart
        ; No return value indicates the array had no set indices between IndexStart and IndexEnd.
        if !_GetNearest_L2R() {
            throw Error('The indices within the input range are all unset.', -1)
        }
        left := i
        i := IndexEnd
        ; This will always return 1 because we know that there is at least one value in the input range.
        _GetNearest_R2L()
        right := i
        ;@endregion

        ;@region 1 Unique val
        ; This block handles conditions where there is only one unique value between `IndexStart`
        ; and `IndexEnd`.
        x := Compare2(left, right)
        if !x {
            ; First, we validate `Value`. We might be able to skip the whole process if `Value` is
            ; out of range. We can also prepare the return value so we don't need to re-check
            ; `Condition`. The return value will be a function of the sort direction.
            i := left
            x := Compare1()
            switch Condition {
                case '>':
                    if x >= 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? right : left
                case '>=':
                    if x > 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? right : left
                case '<':
                    if x <= 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? left : right
                case '<=':
                    if x < 0 {
                        return 0
                    }
                    Result := (BaseDirection) => BaseDirection == 1 ? left : right
            }
            ; `Value` satisfies the condition at this point. If `right == left`, then there is only
            ; one set index and we can return that.
            if right == left {
                OutValue := this[left]
                return left
            }
            ; At this point, we know `Value` is valid and there are multiple indices with `Value`.
            ; Therefore, we must know the sort direction so we know whether to return `left` or
            ; `right`.
            i := 0
            while !this.Has(++i) {
                continue
            }
            _left := i
            i := this.Length + 1
            while !this.Has(--i) {
                continue
            }
            _right := i
            x := Compare2(_left, _right)
            if x = 0 {
                ; Default to `left` because there is no sort direction.
                OutValue := this[left]
                return left
            } else if x < 0 {
                OutValue := this[Result(-1)]
                return Result(-1)
            } else {
                OutValue := this[Result(1)]
                return Result(1)
            }
        }
        ;@endregion

        ;@region Condition
        switch Condition {

            ;@region case >=
            case '>=':
                Condition := _Compare_GTE
                AltCondition := _Compare_LT
                HandleEqualValues := _HandleEqualValues_EQ
                EQ := true
                if x < 0 {
                    i := right
                    if Compare1() > 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_GT_A_2
                    Sequence_LT := _Sequence_GT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := left
                    if Compare1() > 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_GT_D_2
                    Sequence_LT := _Sequence_GT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            ;@region case >
            case '>':
                Condition := _Compare_GT
                AltCondition := _Compare_LTE
                HandleEqualValues := _HandleEqualValues_NEQ
                EQ := false
                if x < 0 {
                    i := right
                    if Compare1() >= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_GT_A_2
                    Sequence_LT := _Sequence_GT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := left
                    if Compare1() >= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_GT_D_2
                    Sequence_LT := _Sequence_GT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            ;@region case <=
            case '<=':
                Condition := _Compare_LTE
                AltCondition := _Compare_GT
                HandleEqualValues := _HandleEqualValues_EQ
                EQ := true
                if x < 0 {
                    i := left
                    if Compare1() < 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_LT_A_2
                    Sequence_LT := _Sequence_LT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := right
                    if Compare1() < 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_LT_D_2
                    Sequence_LT := _Sequence_LT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            ;@region case <
            case '<':
                Condition := _Compare_LT
                AltCondition := _Compare_GTE
                HandleEqualValues := _HandleEqualValues_NEQ
                EQ := false
                if x < 0 {
                    i := left
                    if Compare1() <= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := -1
                    Sequence_GT := _Sequence_LT_A_2
                    Sequence_LT := _Sequence_LT_A_1
                    Compare_Loop := _CompareSimple_LT
                } else {
                    i := right
                    if Compare1() <= 0 {
                        ; `Value` is out of range.
                        return 0
                    }
                    HEV_Direction := 1
                    Sequence_GT := _Sequence_LT_D_2
                    Sequence_LT := _Sequence_LT_D_1
                    Compare_Loop := _CompareSimple_GT
                }
            ;@endregion

            default: throw ValueError('Invalid condition.', -1, Condition)
        }
        ;@endregion

        stop := 0
        R := IndexEnd - IndexStart + 1
        ;@region Process
        while R * 0.5 ** (stop + 1) * 14 > 27 {
            stop++
            i := right - Ceil((right - left) * 0.5)
            while !this.Has(i) {
                if i + 1 > IndexEnd {
                    while !this.Has(--i) {
                        continue
                    }
                    if _Compare_GT() {
                        return Sequence_GT()
                    } else {
                        return Sequence_LT()
                    }
                } else {
                    i++
                }
            }
            x := Compare1()
            if x = 0 {
                return HandleEqualValues()
            } else if Compare_Loop() {
                left := i
            } else {
                right := i
            }
        }
        ; If we go the entire loop without landing on an equal value, then we search sequentially
        ; from `i`.
        x := Compare1()
        if x = 0 {
            return HandleEqualValues()
        } else if _CompareSimple_GT() {
            return Sequence_GT()
        } else {
            return Sequence_LT()
        }
        ;@endregion

        ;@region Compare1
        _Compare_GT() => Compare1() < 0
        _Compare_GTE() => Compare1() <= 0
        _Compare_LT() => Compare1() > 0
        _Compare_LTE() => Compare1() >= 0
        _Compare_EQ() => Compare1() = 0

        _CompareSimple_GT() => x < 0
        _CompareSimple_GTE() => x <= 0
        _CompareSimple_LT() => x > 0
        _CompareSimple_LTE() => x >= 0
        _CompareSimple_EQ() => x = 0

        _CompareNumber1() => Value - this[i]
        _CompareString1() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber1() => Value - CallbackValue(this[i])
        _CompareCbString1() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue1() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue1() => CallbackCompare(Value, this[i])
        _CompareDate1() => CallbackCompareValue(Value, this[i])
        _CompareCbDate1() => CallbackCompareValue(Value, CallbackValue(this[i]))

        _CompareNumber2(a, b) => this[a] - this[b]
        _CompareString2(a, b) => CallbackCompare(StrPtr(this[a]), StrPtr(this[b]))
        _CompareCbNumber2(a, b) => CallbackValue(this[a]) - CallbackValue(this[b])
        _CompareCbString2(a, b) => CallbackCompare(StrPtr(CallbackValue(this[a])), StrPtr(CallbackValue(this[b])))
        _CompareCbValue2(a, b) => CallbackCompare(CallbackValue(this[a]), CallbackValue(this[b]))
        _CompareValue2(a, b) => CallbackCompare(this[a], this[b])
        ;@endregion

        ;@region Sequence
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == 1
         * - > or >=
         */
        _Sequence_GT_A_1() {
            ; If `Value` > <current value>, and if GT, then we must search toward `Value`
            ; until we hit an equal or greater value. If we hit an equal value and if ET, we return
            ; that. If not ET, then we keep going until we find a greater value. Since we have
            ; already set `Condition` to check for the correct condition, we just need to check
            ; `Condition`.
            loop IndexEnd - i {
                if this.Has(++i) {
                    if Condition() {
                        OutValue := this[i]
                        return i
                    }
                }
            }
            OutValue := this[i]
            return i
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == -1
         * - > or >=
         */
        _Sequence_GT_D_1() {
            ; Same as above but in the opposite direction.
            loop i - IndexStart {
                if this.Has(--i) {
                    if Condition() {
                        OutValue := this[i]
                        return i
                    }
                }
            }
            OutValue := this[i]
            return i
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == 1
         * - > or >=
         */
        _Sequence_GT_A_2() {
            ; If `Value` < <current value> and if GT, then we are already at an index that
            ; satisfies the condition, but we do not know for sure that it is the first index.
            ; So we must search toward `Value` until finding an index that does not
            ; satisfy the condition. In this case we search agains the direction of ascent.
            Previous := i
            loop i - IndexStart {
                if this.Has(--i) {
                    if AltCondition() {
                        if EQ && _Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := this[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == -1
         * - > or >=
         */
        _Sequence_GT_D_2() {
            ; Same as above but opposite direction.
            Previous := i
            loop IndexEnd - i {
                if this.Has(++i) {
                    if AltCondition() {
                        if EQ && _Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := this[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == 1
         * - < or <=
         */
        _Sequence_LT_A_1() {
            ; If `Value` > <current value> and if not GT, then we are already at an index that
            ; satisfies the condition, but we do not know for sure that it is the first index.
            ; So we must search toward `Value` until finding an index that does not
            ; satisfy the condition. If we run into an equal value, and if EQ, then we can
            ; pass control over to `HandleEqualValues` because it will do the rest. If not EQ,
            ; then we can ignore equality because we just need `AltCondition` to return true.
            Previous := i
            loop IndexEnd - i {
                if this.Has(++i) {
                    if AltCondition() {
                        if EQ && _Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := this[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == -1
         * - < or <=
         */
        _Sequence_LT_D_1() {
            ; Same as above but opposite direction.
            Previous := i
            loop i - IndexStart {
                if this.Has(--i) {
                    if AltCondition() {
                        if EQ && _Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := this[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == 1
         * - < or <=
         */
        _Sequence_LT_A_2() {
            ; If `Value` < <current value>, and if not GT, then we must go opposite of the
            ; direction of ascent until `Condition` returns true.
            loop i - IndexStart {
                if this.Has(--i) {
                    if Condition() {
                        OutValue := this[i]
                        return i
                    }
                }
            }
            OutValue := this[i]
            return i
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == -1
         * - < or <=
         */
        _Sequence_LT_D_2() {
            ; Same as above but opposite direction.
            loop IndexEnd - i {
                if this.Has(++i) {
                    if Condition() {
                        OutValue := this[i]
                        return i
                    }
                }
            }
            OutValue := this[i]
            return i
        }
        ;@endregion

        ;@region Helpers
        ; This function is used when equality is included in the condition.
        _HandleEqualValues_EQ() {
            ; We are able to prepare for this function beforehand by understanding what direction
            ; we must search in order to find the correct index to return. Since equality is included,
            ; we must search in the opposite direction we otherwise would have, then return the
            ; index that is previous to the first index which contains a value that is NOT equivalent
            ; to `Value`.
            ; Consider an array:
            ; -500 -499 -498 -497 -497 -497 -496 -495 -494
            ; `Value := -497`
            ; If GT, then the correct index is 4 because it is the first index to contain a value
            ; that meets the condition in the search direction, so to find it we must search
            ; <DirectionofAscent> * -1 (-1 in the example) then return 4 when we get to 3.
            ; If LT, then the correct index is 6, so we must do the opposite. Specifically,
            ; we must search <DirectionofAscent> (1 in the example) then return 6 when we get to 7.
            /**
             * @example
             *  if GT {
             *      HEV_Direction := BaseDirection == 1 ? -1 : 1
             *  } else {
             *      HEV_Direction := BaseDirection == 1 ? 1 : -1
             *  }
             * @
             */
            if HEV_Direction > 0 {
                i--
                LoopCount := IndexEnd - i
            } else {
                i++
                LoopCount := i - IndexStart
            }
            loop LoopCount {
                i += HEV_Direction
                if this.Has(i) {
                    if !_Compare_EQ() {
                        break
                    }
                    Previous := i
                }
            }
            OutValue := this[Previous]
            return Previous
        }
        ; This function is used when equality is not included in the condition.
        _HandleEqualValues_NEQ() {
            ; When equality is not included, the process is different. When GT, we no longer invert
            ; the direction of ascent. We are interested in the first index that contains a value
            ; which meets the condition in the same direction as the direction of ascent. When LT,
            ; we are interested in the first index that contains a value which meets the condition
            ; in the opposite direction of the direction of ascent.
            ; Consider an array:
            ; -500 -499 -498 -497 -497 -497 -496 -495 -494
            ; `Value := -497`
            ; If GT, then the correct index is 7 because it is the first index to contain a value
            ; that meets the condition in the search direction, so to find it we must search
            ; <DirectionofAscent> (1 in the example) then return 7 when we get to 7.
            ; If LT, then the correct index is 3, so we must do the opposite. Specifically,
            ; we must search <DirectionofAscent> * -1 (-1 in the example) then return 3 when we get to 3.
            /**
             * @example
             *  if GT {
             *      HEV_Direction := BaseDirection == 1 ? 1 : -1
             *  } else {
             *      HEV_Direction := BaseDirection == 1 ? -1 : 1
             *  }
             * @
             */
            loop HEV_Direction > 0 ? IndexEnd - i + 1 : i {
                i += HEV_Direction
                if this.Has(i) {
                    if !_Compare_EQ() {
                        break
                    }
                }
            }
            if this.Has(i) {
                OutValue := this[i]
                return i
            }
        }
        _GetNearest_L2R() {
            loop IndexEnd - i + 1 {
                if this.Has(i) {
                    return 1
                }
                i++
            }
        }
        _GetNearest_R2L() {
            loop i - IndexStart + 1 {
                if this.Has(i) {
                    return 1
                }
                i--
            }
        }
        ;@endregion
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * This version of the function does not search for multiple indices; it only finds
     * the first index from left-to-right that contains the input value.
     *
     * @param {*} Value - The value to find.
     *
     * @param {Number} [IndexStart = 1] - The index to start the search at.
     *
     * @param {Number} [IndexEnd = this.Length] - The index to end the search at.
     *
     * @returns {Integer} - If the value is found, the first index containing the value from left
     * to right. Else, 0.
     */
    FindSparse(Value, &OutValue?, IndexStart := 1, IndexEnd := this.Length) {
        if IndexEnd < IndexStart {
            throw Error('The end index is less than the start index.'
            , -1, 'IndexEnd: ' IndexEnd '; IndexStart: ' IndexStart)
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare := _CompareNumber
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareString
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
                if !IsNumber(Value) {
                    _value := Value
                    Value := StrPtr(_value)
                }
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare := _CompareCbNumber
                if !IsNumber(Value) {
                    Value := CallbackValue(Value)
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbString
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        _value := CallbackValue(Value)
                        Value := StrPtr(_value)
                    } else {
                        _value := Value
                        Value := StrPtr(Value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare := _CompareCbStringPtr
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := DateObj.FromTimestamp(Value)
                } else {
                    Value := DateObj.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := DateObj.FromTimestamp(Value)
                    } else {
                        date := this.DateParser.Call(
                            Value
                          , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                        )
                    }
                }
                if date {
                    Value := date
                } else {
                    Value := this.CallbackValue.Call(Value)
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        stop := 0
        R := IndexEnd - IndexStart + 1
        while R * 0.5 ** (stop + 1) * 14 > 27 {
            stop++
            if !this.Has(i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)) {
                if !_GetNearest() {
                    return 0
                }
            }
            if x := Compare() {
                if x > 0 {
                    IndexStart := i
                } else {
                    IndexEnd := i
                }
            } else {
                loop i - IndexStart {
                    --i
                    if Compare() {
                        OutValue := this[i + 1]
                        return i + 1
                    }
                }
                return i
            }
        }
        i := IndexStart
        loop IndexEnd - i + 1 {
            if Compare() {
                ++i
            } else {
                OutValue := this[i]
                return i
            }
        }

        return 0

        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbStringPtr() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue() => CallbackCompare(Value, this[i])
        _GetNearest() {
            Start := i
            loop IndexEnd - i {
                if this.Has(++i) {
                    return 1
                }
            }
            i := Start
            loop i - IndexStart {
                if this.Has(--i) {
                    return 1
                }
            }
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no. Unset indices are skipped; all indices in the output container are
     * set.
     *
     * Creates a new {@link Container} by calling {@link Container.Prototype.Copy} on this container,
     * then iterates the values of this {@link Container}. For each
     * value that inherits from array (including {@link Container}), the values are recursively
     * "flattened", i.e., the values of the nested array/container are added directly to the end of
     * the output container.
     *
     * @param {Integer} [MaxDepth = 0] - If a positive integer, the maximum depth to recurse into
     * nested arrays. A value less than or equal to 0 indicates to maximum.
     *
     * @returns {Container} - A new container containing the flattened values.
     */
    Flat(MaxDepth := 0) {
        result := this.Copy()
        result.Capacity := this.Length * 2
        stack := [ this, 0 ]
        stack.Capacity := 16
        if MaxDepth > 0 {
            loop {
                c := stack[-1][1]
                i := stack[-1][2]
                loop {
                    if ++i > c.Length {
                        stack.Pop()
                        if stack.Length {
                            continue 2
                        } else {
                            return result
                        }
                    }
                    if c.Has(i) {
                        if c[i] is Array && stack.Length < MaxDepth {
                            stack[-1][2] := i
                            stack.Push([ c[i], 0 ])
                            continue 2
                        } else {
                            result.Push(c[i])
                        }
                    }
                }
            }
        } else {
            loop {
                c := stack[-1][1]
                i := stack[-1][2]
                loop {
                    if ++i > c.Length {
                        stack.Pop()
                        if stack.Length {
                            continue 2
                        } else {
                            return result
                        }
                    }
                    if c.Has(i) {
                        if c[i] is Array {
                            stack[-1][2] := i
                            stack.Push([ c[i], 0 ])
                            continue 2
                        } else {
                            result.Push(c[i])
                        }
                    }
                }
            }
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Iterates the values in the container, passing each value to a callback function. The callback's
     * return value is ignored.
     *
     * @param {*} Callback - If `ThisArg` is set, the function can accept two to four parameters.
     *
     * Parameters:
     * - `ThisArg` - the hidden `this` parameter.
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * If `ThisArg` is unset, the function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * @param {*} [ThisArg] - The value to pass to the hidden `this` parameter when executing the
     * callback. See the file "test\ThisArg-example.ahk" for working examples.
     */
    ForEach(Callback, ThisArg?) {
        if IsSet(ThisArg) {
            loop this.Length {
                Callback(ThisArg, this[A_Index], A_Index, this)
            }
        } else {
            loop this.Length {
                Callback(this[A_Index], A_Index, this)
            }
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Iterates the values in the container, passing each value to a callback function. The callback's
     * return value is ignored.
     *
     * @param {*} Callback - If `ThisArg` is set, the function can accept two to four parameters.
     * Parameters 2-4 must be optional.
     *
     * Parameters:
     * - `ThisArg` - the hidden `this` parameter.
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * If `ThisArg` is unset, the function can accept one to three parameters. Parameters 1-3 must
     * be optional.
     *
     * Parameters:
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * @param {*} [ThisArg] - The value to pass to the hidden `this` parameter when executing the
     * callback. See the file "test\ThisArg-example.ahk" for working examples.
     */
    ForEachSparse(Callback, ThisArg?) {
        if IsSet(ThisArg) {
            loop this.Length {
                if this.Has(A_Index) {
                    Callback(ThisArg, this[A_Index], A_Index, this)
                } else {
                    Callback(ThisArg, , A_Index, this)
                }
            }
        } else {
            loop this.Length {
                if this.Has(A_Index) {
                    Callback(this[A_Index], A_Index, this)
                } else {
                    Callback(, A_Index, this)
                }
            }
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts an value in order.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    Insert(Value) {
        if index := this.FindInequality(Value, , '>') {
            this.InsertAt(index, Value)
            return index
        } else if this.Compare(Value, 1) < 0 {
            this.InsertAt(1, Value)
            return 1
        } else {
            this.Push(Value)
            return this.Length
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts an value in order.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    InsertSparse(Value) {
        if index := this.FindInequalitySparse(Value, , '>') {
            i := index
            ; Fill in an unset index if there are any nearby
            while !this.Has(--i) && i > 0 {
                continue
            }
            i++
            if i = index {
                this.InsertAt(index, Value)
                return index
            } else {
                this[i] := Value
                return i
            }
        } else {
            i := 1
            while !this.Has(i) && i < this.Length {
                ++i
            }
            if !this.Has(i) {
                throw UnsetItemError('The container is empty.', -1)
            }
            if this.Compare(Value, i) < 0 {
                if i > 1 {
                    this[i - 1] := Value
                    return i - 1
                } else {
                    this.InsertAt(1, Value)
                    return 1
                }
            } else {
                i := this.Length
                while !this.Has(i) && i > 0 {
                    --i
                }
                if i < this.Length {
                    this[i + 1] := Value
                    return i + 1
                } else {
                    this.Push(Value)
                    return this.Length
                }
            }
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Sorts in-place using insertion sort method. This method is appropriate for small container
     * sizes (n <= 32).
     */
    InsertionSort() {
        if !this.Length {
            throw Error('The ``Container`` is empty.', -1)
        }
        if this.Length == 1 {
            return this
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare1 := _CompareNumber1
                Compare2 := _CompareNumber2
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareString1
                Compare2 := _CompareString2
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbNumber1
                Compare2 := _CompareCbNumber2
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbString1
                Compare2 := _CompareCbString2
            case CONTAINER_SORTTYPE_CB_STRINGPTR
            , CONTAINER_SORTTYPE_CB_DATE
            , CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        if this.Length == 2 {
            if Compare1(this[1], this[2]) > 0 {
                t := this[1]
                this[1] := this[2]
                this[2] := t
            }
            return this
        } else if this.Length > 2 {
            i := 1
            loop this.Length - 1 {
                j := i
                b := this[++i]
                loop j {
                    if Compare2(this[j]) < 0 {
                        break
                    }
                    this[j + 1] := this[j--]
                }
                this[j + 1] := b
            }
        }

        return this

        _CompareNumber1(a, b) => a - b
        _CompareString1(a, b) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber1(a, b) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString1(a, b) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue1(a, b) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue1(a, b) => Callbackcompare(a, b)
        _CompareNumber2(a) => a - b
        _CompareString2(a) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber2(a) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString2(a) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue2(a) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue2(a) => Callbackcompare(a, b)
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Joins all values into a string.
     * - The container may not have unset indices.
     * - Objects are represented as `"{" Type(value) "}"`.
     *
     * @param {String} [Delimiter = ", "] - The string to separate each value of the array.
     *
     * @returns {String} - The string.
     */
    Join(Delimiter := ', ') {
        s := ''
        VarSetStrCapacity(&s, this.Length * 5)
        loop this.Length {
            if IsObject(this[A_Index]) {
                s .= '{' Type(this[A_Index]) '}' Delimiter
            } else {
                s .= this[A_Index] Delimiter
            }
        }
        return s ? SubStr(s, 1, -1 * StrLen(Delimiter)) : ''
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Joins all values into a string.
     * - The container may not have unset indices.
     * - Objects are represented as "{" Type(value) "}".
     *
     * @param {String} [Delimiter = ", "] - The string to separate each value of the array.
     *
     * @param {String} [UnsetItem = "`"`""] - The string to represent unset indices. To skip
     * unset indices entirely (and not have them represented in the output), set `UnsetItem` with
     * zero or an empty string.
     *
     * @param {*} [CallbackObject = (value) => "{" Type(value) "}"] - A `Func` or callable object
     * which accepts the object as an argument and returns the string to add to the result string.
     *
     * @returns {String} - The string.
     */
    JoinEx(Delimiter := ', ', UnsetItem := '""', CallbackObject := (value) => '{' Type(value) '}') {
        s := ''
        VarSetStrCapacity(&s, this.Length * 5)
        if UnsetItem {
            loop this.Length {
                if this.Has(A_Index) {
                    if IsObject(this[A_Index]) {
                        s .= CallbackObject(this[A_Index]) Delimiter
                    } else {
                        s .= this[A_Index] Delimiter
                    }
                } else {
                    s .= UnsetItem Delimiter
                }
            }
        } else {
            loop this.Length {
                if this.Has(A_Index) {
                    if IsObject(this[A_Index]) {
                        s .= CallbackObject(this[A_Index]) Delimiter
                    } else {
                        s .= this[A_Index] Delimiter
                    }
                }
            }
        }
        return s ? SubStr(s, 1, -1 * StrLen(Delimiter)) : ''
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Creates a new output container, then iterates the values in this container passing each value
     * to a callback function. The return values from the callback function are added to the output
     * container at the same index.
     *
     * @param {*} Callback - If `ThisArg` is set, the function can accept two to four parameters.
     *
     * Parameters:
     * - `ThisArg` - the hidden `this` parameter.
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * If `ThisArg` is unset, the function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: The value to add to the output container.
     *
     * @param {*} [ThisArg] - The value to pass to the hidden `this` parameter when executing the
     * callback. See the file "test\ThisArg-example.ahk" for working examples.
     *
     * @returns {Container} - A new container containing the values returned by the callback function.
     */
    Map(Callback, ThisArg?) {
        Result := Container()
        Result.Capacity := this.Length
        if IsSet(ThisArg) {
            loop this.Length {
                Result.Push(Callback(ThisArg, this[A_Index], A_Index, this))
            }
        } else {
            loop this.Length {
                Result.Push(Callback(this[A_Index], A_Index, this))
            }
        }
        return Result
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Creates a new output container, then iterates the values in this container passing each value
     * to a callback function. The return values from the callback function are added to the output
     * container at the same index.
     *
     * @param {*} Callback - If `ThisArg` is set, the function can accept two to four parameters.
     * Parameters 2-4 must be optional.
     *
     * Parameters:
     * - `ThisArg` - the hidden `this` parameter.
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * If `ThisArg` is unset, the function can accept one to three parameters. Parameters 1-3 must be optional.
     *
     * Parameters:
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: The value to add to the output container.
     *
     * @param {*} [ThisArg] - The value to pass to the hidden `this` parameter when executing the
     * callback. See the file "test\ThisArg-example.ahk" for working examples.
     *
     * @returns {Container} - A new container containing the values returned by the callback function.
     */
    MapSparse(Callback, ThisArg?) {
        Result := Container()
        Result.Length := this.Length
        if IsSet(ThisArg) {
            loop this.Length {
                if this.Has(A_Index) {
                    Result[A_Index] := Callback(ThisArg, this[A_Index], A_Index, this)
                }
            }
        } else {
            loop this.Length {
                if this.Has(A_Index) {
                    Result[A_Index] := Callback(this[A_Index], A_Index, this)
                }
            }
        }
        return Result
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Iterates the values in the container, passing each value to a callback function. If the
     * callback function returns nonzero, the value is removed from the container.
     *
     * This mutates the original container.
     *
     * @param {*} Callback -  The function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: Nonzero if {@link Container.Prototype.Purge} should remove the value from the
     * container; zero or an empty string if the value should not be removed.
     *
     * @returns {Container} - The purged container.
     */
    Purge(Callback) {
        indices := []
        indices.Capacity := this.Length
        loop this.Length {
            if Callback(this[A_Index], A_Index, this) {
                indices.Push(A_Index)
            }
        }
        n := 0
        for i in indices {
            this.RemoveAt(i - n)
            n++
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Iterates the values in the container, passing each value to a callback function. If the
     * callback function returns nonzero, the value is removed from the container.
     *
     * This mutates the original container.
     *
     * @param {*} Callback -  The function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: Nonzero if {@link Container.Prototype.Purge} should remove the value from the
     * container; zero or an empty string if the value should not be removed.
     *
     * @param {Boolean} [FillUnsetIndices = true] - If true, the values in the container are shifted
     * to the left for each unset index until all unset indices are filled. If false, unset indices
     * are skipped.
     *
     * @returns {Container} - The purged container.
     */
    PurgeSparse(Callback, FillUnsetIndices := true) {
        indices := []
        indices.Capacity := this.Length
        if FillUnsetIndices {
            loop this.Length {
                if !this.Has(A_Index) || Callback(this[A_Index], A_Index, this) {
                    indices.Push(A_Index)
                }
            }
        } else {
            loop this.Length {
                if this.Has(A_Index) && Callback(this[A_Index], A_Index, this) {
                    indices.Push(A_Index)
                }
            }
        }
        n := 0
        for i in indices {
            this.RemoveAt(i - n)
            n++
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * This is the same as `Array.Prototype.Push`, except it also returns the array, allowing this
     * method to be chained with others.
     *
     * @param {...*} Value - The values to add to the container.
     */
    PushEx(Value*) {
        this.Push(Value*)
        return this
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Characteristics of {@link Quicksort}:
     * - Does not mutate the input array.
     * - Unstable (does not preserve original order of equal values).
     * - Can sort either ascending or descending - adjust the comparator appropriately.
     * - There's a built-in cutoff to use insertion sort for small arrays (16).
     * - Makes liberal usage of system memory.
     *
     * If you need a comparable function that sorts in-place, see
     * {@link Container.Prototype.Sort}.
     *
     * @param {array} arr - The array to be sorted.
     *
     * @param {*} [compare = (a, b) => a - b] - A `Func` or callable object that compares two values.
     *
     * @param {Integer} [arrSizeThreshold = 8] - Sets a threshold at which insertion sort is used to
     * sort the array instead of the core procedure. The default value of 8 was determine by testing
     * various distributions of numbers. `arrSizeThreshold` generally should be left at 8.
     *
     * @returns {array} - The sorted array.
     */
    QuickSort(arrSizeThreshold := 8) {
        if !this.Length {
            throw Error('The ``Container`` is empty.', -1)
        }
        if this.Length == 1 {
            return this.Clone()
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare1 := _CompareNumber1
                Compare2 := _CompareNumber2
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareString1
                Compare2 := _CompareString2
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbNumber1
                Compare2 := _CompareCbNumber2
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbString1
                Compare2 := _CompareCbString2
            case CONTAINER_SORTTYPE_CB_STRINGPTR
            , CONTAINER_SORTTYPE_CB_DATE
            , CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        n := this.Length
        if n == 2 {
            if Compare1(this[1], this[2]) > 0 {
                return _MakeResult([this[2], this[1]])
            } else {
                return this.Clone()
            }
        } else if n <= CONTAINER_INSERTIONSORT_THRESHOLD {
            c := this.Clone()
            i := 1
            loop n - 1 {
                j := i
                b := c[++i]
                loop j {
                    if Compare2(c[j]) < 0 {
                        break
                    }
                    c[j + 1] := c[j--]
                }
                c[j + 1] := b
            }
            return c
        }

        candidates := []
        candidates.Length := 3
        stack := []
        loop 3 {
            candidates[A_Index] := this[Random(1, this.Length)]
        }
        i := 1
        loop 2 {
            j := i
            b := candidates[++i]
            loop j {
                if Compare2(candidates[j]) < 0 {
                    break
                }
                candidates[j + 1] := candidates[j--]
            }
            candidates[j + 1] := b
        }
        b := candidates[2]
        left := []
        right := []
        left.Capacity := right.Capacity := this.Length
        for item in this {
            if Compare2(item) < 0 {
                left.Push(item)
            } else {
                right.Push(item)
            }
        }
        stack.Push([ left, right, 1 ])
        c := stack[-1][stack[-1][3]]
        loop {
            if c.Length <= arrSizeThreshold {
                if c.Length == 2 {
                    if Compare1(c[1], c[2]) > 0 {
                        stack[-1][stack[-1][3]] := [c[2], c[1]]
                    }
                } else if c.Length > 1 {
                    ; Insertion sort.
                    i := 1
                    loop c.Length - 1 {
                        j := i
                        b := c[++i]
                        loop j {
                            if Compare2(c[j]) < 0 {
                                break
                            }
                            c[j + 1] := c[j--]
                        }
                        c[j + 1] := b
                    }
                }
                while stack[-1][3] == 2 {
                    complete := stack.Pop()
                    complete[1].Push(complete[2]*)
                    if !stack.Length {
                        return _MakeResult(complete[1])
                    }
                    stack[-1][stack[-1][3]] := complete[1]
                }
                stack[-1][3]++
                c := stack[-1][2]
                continue
            }

            loop 3 {
                candidates[A_Index] := c[Random(1, c.Length)]
            }
            i := 1
            loop 2 {
                j := i
                b := candidates[++i]
                loop j {
                    if Compare2(candidates[j]) < 0 {
                        break
                    }
                    candidates[j + 1] := candidates[j--]
                }
                candidates[j + 1] := b
            }
            b := candidates[2]
            left := []
            right := []
            left.Capacity := right.Capacity := c.Length
            for item in c {
                if Compare2(item) < 0 {
                    left.Push(item)
                } else {
                    right.Push(item)
                }
            }
            if left.Length {
                c := left
                if right.Length {
                    stack.Push([ left, right, 1 ])
                    continue
                }
            } else if right.Length {
                c := right
            }
            if c.Length == 2 {
                if Compare1(c[1], c[2]) > 0 {
                    stack[-1][stack[-1][3]] := [c[2], c[1]]
                }
            } else if c.Length > 1 {
                ; Insertion sort.
                i := 1
                loop c.Length - 1 {
                    j := i
                    b := c[++i]
                    loop j {
                        if Compare2(c[j]) < 0 {
                            break
                        }
                        c[j + 1] := c[j--]
                    }
                    c[j + 1] := b
                }
            }
            stack[-1][stack[-1][3]] := c
            while stack[-1][3] == 2 {
                complete := stack.Pop()
                complete[1].Push(complete[2]*)
                if !stack.Length {
                    return _MakeResult(complete[1])
                }
                stack[-1][stack[-1][3]] := complete[1]
            }
            stack[-1][3]++
            c := stack[-1][2]
        }

        _CompareNumber1(a, b) => a - b
        _CompareString1(a, b) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber1(a, b) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString1(a, b) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue1(a, b) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue1(a, b) => Callbackcompare(a, b)
        _CompareNumber2(a) => a - b
        _CompareString2(a) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber2(a) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString2(a) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue2(a) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue2(a) => Callbackcompare(a, b)
        _MakeResult(c) {
            ObjSetBase(c, Container.Prototype)
            c.SortType := this.SortType
            if IsObject(this.CallbackValue) {
                c.CallbackValue := this.CallbackValue
            }
            if IsObject(this.CallbackCompare) {
                c.CallbackCompare := this.CallbackCompare
            }
            return c
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Iterates the values in the container, using a VarRef parameter to generate a cumulative result.
     *
     * @param {*} Callback -  The function can accept two to four parameters.
     *
     * Parameters:
     * - The accumulator (as VarRef).
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: The function should return zero or an empty string to continue processing. The
     * function should return a nonzero value to stop processing.
     *
     * @param {VarRef} [Accumulator] - The VarRef that will be passed to each function call and
     * returned at the end of the process.
     *
     * @returns {*} - The value of `Accumulator`.
    */
    Reduce(Callback, &Accumulator) {
        loop this.Length {
            if Callback(&Accumulator, this[A_Index], A_Index, this) {
                break
            }
        }
        return Accumulator
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Iterates the values in the container, using a VarRef parameter to generate a cumulative result.
     *
     * @param {*} Callback -  The function can accept two to four parameters. Parameters 2-4 must
     * be optional.
     *
     * Parameters:
     * - The accumulator (as VarRef).
     * - The current value. If there is no value, this parameter will be unset (the parameter should be optional).
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: The function should return zero or an empty string to continue processing. The
     * function should return a nonzero value to stop processing.
     *
     * @param {VarRef} [Accumulator] - The VarRef that will be passed to each function call and
     * returned at the end of the process.
     *
     * @returns {*} - The value of `Accumulator`.
    */
    ReduceSparse(Callback, &Accumulator) {
        loop this.Length {
            if this.Has(A_Index) {
                if Callback(&Accumulator, this[A_Index], A_Index, this) {
                    break
                }
            } else if Callback(&Accumulator, , A_Index, this) {
                break
            }
        }
        return Accumulator
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Finds a value in the container using {@link Container.Prototype.Find}, then removes it and
     * returns the index at which it was located. Throws an error if not found.
     *
     * @param {*} Value - The value to find.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the value that was found.
     *
     * @returns {Integer} - The index of the found value.
     *
     * @throws {UnsetItemError} - "Value not found."
     */
    Remove(Value, &OutValue?) {
        if index := this.Find(Value, &OutValue) {
            this.RemoveAt(index)
            return index
        } else {
            throw UnsetItemError('Value not found.', -1, IsObject(Value) ? '{ ' Type(Value) ' }' : Value)
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Finds a value in the container using {@link Container.Prototype.Find}, then removes it and
     * returns the index at which it was located. Throws an error if not found.
     *
     * @param {*} Value - The value to find.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the value that was found.
     *
     * @returns {Integer} - The index of the found value, or 0 if the value was not found.
     */
    RemoveIf(Value, &OutValue?) {
        if index := this.Find(Value, &OutValue) {
            this.RemoveAt(index)
            return index
        } else {
            return 0
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * Finds a value in the container using {@link Container.Prototype.FindSparse}, then removes it and
     * returns the index at which it was located. Throws an error if not found.
     *
     * @param {*} Value - The value to find.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the value that was found.
     *
     * @returns {Integer} - The index of the found value, or 0 if the value was not found.
     */
    RemoveIfSparse(Value, &OutValue?) {
        if index := this.FindSparse(Value, &OutValue) {
            this.RemoveAt(index)
            return index
        } else {
            return 0
        }
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: yes.
     *
     * Finds a value in the container using {@link Container.Prototype.FindSparse}, then removes it and
     * returns the index at which it was located. Throws an error if not found.
     *
     * @param {*} Value - The value to find.
     *
     * @param {VarRef} [OutValue] - A variable that will receive the value that was found.
     *
     * @returns {Integer} - The index of the found value.
     *
     * @throws {UnsetItemError} - "Value not found."
     */
    RemoveSparse(Value, &OutValue?) {
        if index := this.FindSparse(Value, &OutValue) {
            this.RemoveAt(index)
            return index
        } else {
            throw UnsetItemError('Value not found.', -1, IsObject(Value) ? '{ ' Type(Value) ' }' : Value)
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Creates a new {@link Container} by calling {@link Container.Prototype.Copy} on this container,
     * and fills it with the values from this container in reverse order.
     *
     * @returns {Container}
     */
    Reverse() {
        result := this.Copy()
        len := result.Capacity := this.Length
        loop len {
            result.Push(this[-1 * A_Index])
        }
        return Result
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Creates a new {@link Container} by calling {@link Container.Prototype.Copy} on this container,
     * and fills it with the values from this container in reverse
     *
     * @returns {Container}
     */
    ReverseSparse() {
        result := this.Copy()
        len := result.Length := this.Length
        loop len {
            if this.Has(-1 * A_Index) {
                result[A_Index] := this[-1 * A_Index]
            }
        }
        return Result
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * Iterates the values in the container, passing each value to a callback function. If the
     * callback function returns a nonzero value, {@link Container.Prototype.Search} returns the
     * current index. If the callback function never returns a nonzero value,
     * {@link Container.Prototype.Search} returns 0.
     *
     * @param {*} Callback - The function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: Nonzero to direct {@link Container.Prototype.Search} to return the current index.
     * Zero or an empty string to direct {@link Container.Prototype.Search} to continue processing.
     *
     * @param {VarRef} [OutValue] - If the callback returns nonzero, this variable will receive the
     * value that was passed to the function when it returned nonzero.
     *
     * @returns {Integer} - If the callback returns nonzero, the index of the value that was passed
     * to the function when it returned nonzero. If the callback never returns nonzero, 0.
     */
    Search(Callback, &OutValue?) {
        loop this.Length {
            if Callback(this[A_Index], A_Index, this) {
                OutValue := this[A_Index]
                return A_Index
            }
        }
        return 0
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: no.
     *
     * A new {@link Container} is created as the output container. {@link Container.Prototype.SearchAll}
     * iterates the values in the container, passing each value to a callback function. If the
     * callback function returns a nonzero value, the value or index is added to the output
     * container (depending on the value of parameter `ReturnIndices`). The {@link Container} is
     * returned when all values have been processed.
     *
     * @param {*} Callback -  The function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: Nonzero if {@link Container.Prototype.SearchAll} should add the value or index to the
     * output container; zero or an empty string if the item should not be added to the output container.
     *
     * @param {Boolean} [ReturnIndices = false] - If true, the index of each value that causes
     * the callback to return nonzero will be added to the output {@link Container}. If false, the
     * values themselves will be added to the output {@link Container}.
     *
     * @returns {Container} - A {@link Container} containing the items or indices, depending on the
     * value of `ReturnIndices`.
     */
    SearchAll(Callback, ReturnIndices := false) {
        if ReturnIndices {
            result := Container()
            result.Capacity := this.Length
            loop this.Length {
                if Callback(this[A_Index], A_Index, this) {
                    result.Push(A_Index)
                }
            }
        } else {
            result := Container()
            result.Capacity := this.Length
            loop this.Length {
                if Callback(this[A_Index], A_Index, this) {
                    result.Push(this[A_Index])
                }
            }
        }
        result.Capacity := result.Length
        return result
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes. Unset indices are skipped.
     *
     * A new {@link Container} is created as the output container. {@link Container.Prototype.SearchAllSparse}
     * iterates the values in the container, passing each value to a callback function. If the
     * callback function returns a nonzero value, the value or index is added to the output
     * container (depending on the value of parameter `ReturnIndices`). The {@link Container} is
     * returned when all values have been processed.
     *
     * @param {*} Callback -  The function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: Nonzero if {@link Container.Prototype.SearchAllSparse} should add the value or index to the
     * output container; zero or an empty string if the item should not be added to the output container.
     *
     * @param {Boolean} [ReturnIndices = false] - If true, the index of each value that causes
     * the callback to return nonzero will be added to the output {@link Container}. If false, the
     * values themselves will be added to the output {@link Container}.
     *
     * @returns {Container} - A {@link Container} containing the items or indices, depending on the
     * value of `ReturnIndices`.
     */
    SearchAllSparse(Callback, ReturnIndices := false) {
        if ReturnIndices {
            result := Container()
            result.Capacity := this.Length
            loop this.Length {
                if this.Has(A_Index) && Callback(this[A_Index], A_Index, this) {
                    result.Push(A_Index)
                }
            }
        } else {
            result := Container()
            result.Capacity := this.Length
            loop this.Length {
                if this.Has(A_Index) && Callback(this[A_Index], A_Index, this) {
                    result.Push(this[A_Index])
                }
            }
        }
        result.Capacity := result.Length
        return result
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes. Unset indices are skipped.
     *
     * Iterates the values in the container, passing each value to a callback function. If the
     * callback function returns a nonzero value, {@link Container.Prototype.SearchSparse} returns the
     * current index. If the callback function never returns a nonzero value,
     * {@link Container.Prototype.SearchSparse} returns 0.
     *
     * @param {*} Callback - The function can accept one to three parameters.
     *
     * Parameters:
     * - The current value.
     * - The current index.
     * - The {@link Container} object.
     *
     * Returns: Nonzero to direct {@link Container.Prototype.SearchSparse} to return the current index.
     * Zero or an empty string to direct {@link Container.Prototype.SearchSparse} to continue processing.
     *
     * @param {VarRef} [OutValue] - If the callback returns nonzero, this variable will receive the
     * value that was passed to the function when it returned nonzero.
     *
     * @returns {Integer} - If the callback returns nonzero, the index of the value that was passed
     * to the function when it returned nonzero. If the callback never returns nonzero, 0.
     */
    SearchSparse(Callback, &OutValue?) {
        loop this.Length {
            if this.Has(A_Index) && Callback(this[A_Index], A_Index, this) {
                OutValue := this[A_Index]
                return A_Index
            }
        }
        return 0
    }
    /**
     * Defines the comparator for sorting operations. Sets the property
     * {@link Containe#CallbackCompare}.
     *
     * @param {*} Callback - The callback to use as a comparator for sorting operations.
     *
     * Parameters:
     * 1. A value to be compared.
     * 2. A value to be compared.
     *
     * Returns {Number} - If sorting in ascending order:
     * - If the number is less than zero it indicates the first parameter is less than the second parameter.
     * - If the number is zero it indicates the two parameters are equal.
     * - If the number is greater than zero it indicates the first parameter is greater than the second parameter.
     *
     * Invert the return value (multiply by -1) to sort in descending order.
     */
    SetCallbackCompare(Callback) {
        this.CallbackCompare := Callback
    }
    /**
     * Defines the function used to associate a value in the container with a value used for
     * sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @example
     *  c := Container(
     *      { Name: "obj4" }
     *    , { Name: "obj1" }
     *    , { Name: "obj3" }
     *    , { Name: "obj2" }
     *  )
     *  c.SetCompareStringEx()
     *  c.SetCallbackValue((value) => value.Name)
     *  c.SortType := CONTAINER_SORTTYPE_CB_STRING
     *  c.Sort()
     * @
     *
     * If you are designing a class around the usage of {@link Container}, or designing a class that
     * works with a windows API structure that has a name-like member you want to use for sorting,
     * you may as well incorporate the string pointer directly into the class.
     *
     * @example
     *  class SomeStruct {
     *      static __New() {
     *          this.DeleteProp('__New')
     *          proto := this.Prototype
     *          proto.CbSize := 16 ; arbitrary size for example
     *          proto.__pszText_offset := 8 ; arbitrary offset for example
     *      }
     *      __New(pszText) {
     *          this.Buffer := Buffer(this.cbSize)
     *          this.__pszText := Buffer(StrPut(pszText, 'cp1200'))
     *          StrPut(pszText, this.__pszText, 'cp1200')
     *          NumPut('ptr', this.__pszText.Ptr, this, this.__pszText_offset)
     *      }
     *      pszText {
     *          Get => StrGet(this.__pszText, 'cp1200')
     *          Set {
     *              bytes := StrPut(Value, 'cp1200')
     *              if bytes > this.__pszText.Size {
     *                  this.__pszText.Size := bytes
     *                  NumPut('ptr', this.__pszText.Ptr, this, this.__pszText_offset)
     *              }
     *              StrPut(Value, this.__pszText, 'cp1200')
     *          }
     *      }
     *      Ptr => this.Buffer.Ptr
     *      Size => this.Buffer.Size
     *  }
     *
     *  c := Container(
     *      SomeStruct("obj4")
     *    , SomeStruct("obj1")
     *    , SomeStruct("obj3")
     *    , SomeStruct("obj2")
     *  )
     *  c.SetCompareStringEx()
     *  c.SetCallbackValue((value) => value.__pszText.Ptr)
     *  c.SortType := CONTAINER_SORTTYPE_CB_STRINGPTR
     *  c.Sort()
     * @
     *
     * @param {*} Callback - The callback to use as a comparator for sorting operations.
     *
     * Parameters:
     * 1. A value to be compared.
     * 2. A value to be compared.
     *
     * Returns {Number} - If sorting in ascending order:
     * - If the number is less than zero it indicates the first parameter is less than the second parameter.
     * - If the number is zero it indicates the two parameters are equal.
     * - If the number is greater than zero it indicates the first parameter is greater than the second parameter.
     *
     * Invert the return value (multiply by -1) to sort in descending order.
     */
    SetCallbackValue(Callback) {
        this.CallbackValue := Callback
    }
    /**
     * Defines the comparator for string sort operations.
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-comparestringex}.
     * Sets the function to property {@link Container#CallbackCompare}.
     *
     * @param {String|Integer} [LocaleName = LOCALE_NAME_USER_DEFAULT] - Pointer to a locale name,
     * or one of the following predefined values. If `LocaleName` is a string, a buffer object
     * will be created to store the string value. The buffer object is set to property
     * {@link Container#CompareStringLocaleName}.
     * - LOCALE_NAME_INVARIANT
     * - LOCALE_NAME_SYSTEM_DEFAULT
     * - LOCALE_NAME_USER_DEFAULT
     *
     * @param {Integer} [Flag = 0] - See the description of the flags on
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-comparestringex}.
     * The flags each exist as global variables by the same name as indicated in the documentation. To
     * combine flags, use the bitwise "or" ( | ), e.g. `LINGUISTIC_IGNORECASE | NORM_IGNORENONSPACE`.
     *
     * @param {Integer|NlsVersionInfo|Buffer} [VersionInformation = 0] - Either a pointer to a
     * NLSVERSIONINFO structure, or an {@link NlsVersionInfo} object, or a buffer containing an
     * NLSVERSIONINFO structure. If `VersionInformation` is an object, the object is set to
     * property {@link Container#CompareStringVersionInformation}.
     */
    SetCompareStringEx(
        LocaleName := LOCALE_NAME_USER_DEFAULT
      , Flags := 0
      , VersionInformation := 0
      , Encoding := CONTAINER_DEFAULT_ENCODING
    ) {
        if !IsNumber(LocaleName) {
            buf := this.CompareStringLocaleName := Buffer(StrPut(LocaleName, Encoding))
            StrPut(LocaleName, Buf, Encoding)
            LocaleName := buf.Ptr
        }
        if IsObject(VersionInformation) {
            this.CompareStringVersionInformation := VersionInformation
            VersionInformation := VersionInformation.Ptr
        }
        this.CallbackCompare := Container_CompareStringEx.Bind(LocaleName, Flags, VersionInformation)
    }
    /**
     * Defines the comparator for string date operations. This is only valid when dates are formatted
     * as yyyyMMddHHmmss time strings. The entire time string is not necessary, the minimum is
     * just the year, but the values must be in that order. Sets the property
     * {@link Containe#CallbackCompare} with the value {@link Container_CompareDate}.
     */
    SetCompareDate() {
        this.CallbackCompare := Container_CompareDate
    }
    /**
     * Defines the comparator for date sort operations. This permits sorting dates with any format
     * of date string that can be interpeted using {@link DateObj}. This requires that the file
     * DateObj.ahk is included with an `#include` statement, which is already included at the top
     * of Container.ahk as `#include *i <DateObj>`. Just copy DateObj.ahk into your
     * {@link https://www.autohotkey.com/docs/v2/Scripts.htm#lib lib folder}.
     *
     * For details about {@link DateObj}, see the file itself, or in the repo
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-DateObj/blob/main/DateObj.ahk}.
     *
     * {@link Container.Prototype.SetCompareDateStr} calls {@link Container.Prototype.SetDateParser}.
     *
     * @param {String} DateFormat - The format string that {@link DateObj} uses to parse date strings
     * into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     */
    SetCompareDateStr(DateFormat, RegExOptions := '', Century?) {
        this.SetDateParser(DateParser(DateFormat, RegExOptions), Century ?? unset)
    }
    /**
     * This function is called by {@link Container.Prototype.SetCompareDateStr}, but if you already
     * have an instance of {@link DateParser} to use, you can call
     * {@link Container.Prototype.SetDateParser} directly.
     *
     * Defines the comparator for date sort operations. This permits sorting dates with any format
     * of date string that can be interpeted using {@link DateObj}. See the description above
     * {@link Container.Prototype.SetCompareDateStr} for more info.
     *
     * Sets three properties, {@link Container#__DateParser}, {@link Container#CallbackCompare}
     * and {@link Container#CallbackCompareValue}.
     *
     * Sorting by date is the only sort type that has the extra comparator
     * {@link Container#CallbackCompareValue}; all other sort types use only
     * {@link Container#CallbackCompare}.
     *
     * For details about {@link DateObj}, see the file itself, or in the repo
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-DateObj/blob/main/DateObj.ahk}.
     *
     * @param {DateParser} DateParserObj - The {@link DateParser}.
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     */
    SetDateParser(DateParserObj, Century?) {
        this.__DateParser := DateParserObj
        if IsSet(Century) {
            this.CallbackCompare := Container_CompareDateStr_Century.Bind(DateParserObj, Century)
            this.CallbackCompareValue := Container_CompareDateStr_Century_CompareValue.Bind(DateParserObj, Century)
            this.CompareDateCentury := Century
        } else {
            this.CallbackCompare := Container_CompareDateStr.Bind(DateParserObj)
            this.CallbackCompareValue := Container_CompareDateStr_CompareValue.Bind(DateParserObj)
        }
    }
    /**
     * Sets the sort type.
     *
     * @param {Integer} Value - One of the following:
     * - CONTAINER_SORTTYPE_CB_DATE
     * - CONTAINER_SORTTYPE_CB_DATESTR
     * - CONTAINER_SORTTYPE_CB_MISC
     * - CONTAINER_SORTTYPE_CB_NUMBER
     * - CONTAINER_SORTTYPE_CB_STRING
     * - CONTAINER_SORTTYPE_CB_STRINGPTR
     * - CONTAINER_SORTTYPE_DATE
     * - CONTAINER_SORTTYPE_DATESTR
     * - CONTAINER_SORTTYPE_NUMBER
     * - CONTAINER_SORTTYPE_STRING
     * - CONTAINER_SORTTYPE_STRINGPTR
     *
     * @throws {ValueError} - "Invalid SortType."
     */
    SetSortType(Value) {
        switch Value, 0 {
            case CONTAINER_SORTTYPE_CB_DATE
              , CONTAINER_SORTTYPE_CB_DATESTR
              , CONTAINER_SORTTYPE_CB_MISC
              , CONTAINER_SORTTYPE_CB_NUMBER
              , CONTAINER_SORTTYPE_CB_STRING
              , CONTAINER_SORTTYPE_CB_STRINGPTR
              , CONTAINER_SORTTYPE_DATE
              , CONTAINER_SORTTYPE_DATESTR
              , CONTAINER_SORTTYPE_NUMBER
              , CONTAINER_SORTTYPE_STRING
              , CONTAINER_SORTTYPE_STRINGPTR:
                this.SortType := Value
            default: throw ValueError('Invalid SortType.', -1, Value)
        }
    }
    /**
     * Requires sort type: no.
     *
     * Allows unset indices: yes.
     *
     * Creates a new {@link Container} by calling {@link Container.Prototype.Copy} on this container,
     * then fills the new container with the values between range (IndexStart, IndexEnd) of this
     * container.
     *
     * @param {Integer} [IndexStart = 1] - The initial index.
     * @param {Integer} [IndexEnd = this.Length] - The final index.
     * @returns {Container}
     */
    Slice(IndexStart := 1, IndexEnd := this.Length) {
        result := Container(this.SortType)
        IndexStart--
        result.Length := IndexEnd - IndexStart
        loop result.Length {
            if this.Has(++IndexStart) {
                result[A_Index] := this[IndexStart]
            }
        }
        return result
    }
    /**
     * Requires sort type: yes.
     *
     * Allows unset indices: no.
     *
     * Characteristics of {@link Container.Prototype.Sort}:
     * - In-place sorting (mutates the this object).
     * - Unstable (does not preserve original order of equal values).
     * - Can sort either ascending or descending - adjust {@link Container#CallbackCompare} appropriately.
     * - There's a built-in cutoff to use insertion sort for small arrays (16).
     *
     * If memory isn't an issue, {@link Container.Prototype.QuickSort} performs about 30% faster.
     *
     * @returns {Container}
     */
    Sort() {
        if !this.Length {
            throw Error('The ``Container`` is empty.', -1)
        }
        if this.Length == 1 {
            return this
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_NUMBER:
                Compare1 := _CompareNumber1
                Compare2 := _CompareNumber2
            case CONTAINER_SORTTYPE_STRING:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareString1
                Compare2 := _CompareString2
            case CONTAINER_SORTTYPE_STRINGPTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_CB_NUMBER:
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbNumber1
                Compare2 := _CompareCbNumber2
            case CONTAINER_SORTTYPE_CB_STRING:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbString1
                Compare2 := _CompareCbString2
            case CONTAINER_SORTTYPE_CB_STRINGPTR
            , CONTAINER_SORTTYPE_CB_DATE
            , CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompare
                CallbackValue := this.CallbackValue
                Compare1 := _CompareCbValue1
                Compare2 := _CompareCbValue2
            case CONTAINER_SORTTYPE_CB_MISC
            , CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        n := this.Length
        if n == 2 {
            if Compare1(this[1], this[2]) > 0 {
                t := this[1]
                this[1] := this[2]
                this[2] := t
            }
            return this
        } else if n <= CONTAINER_INSERTIONSORT_THRESHOLD {
            i := 1
            loop n - 1 {
                j := i
                b := this[++i]
                loop j {
                    if Compare2(this[j]) < 0 {
                        break
                    }
                    this[j + 1] := this[j--]
                }
                this[j + 1] := b
            }
            return this
        }

        ; Build heap
        i := Floor(n / 2)
        while i >= 1 {
            b := this[i]
            k := i
            if k * 2 <= n {
                left  := k * 2
                right := left + 1
                j := left
                if right <= n && Compare1(this[right], this[left]) > 0 {
                    j := right
                }
                if Compare2(this[j]) <= 0 {
                    i--
                    continue
                }
            } else {
                i--
                continue
            }

            while k * 2 <= n {
                j := k * 2
                if j + 1 <= n && Compare1(this[j + 1], this[j]) > 0 {
                    j++
                }
                this[k] := this[j]
                k := j
            }
            while k > 1 {
                p := Floor(k / 2)
                if Compare2(this[p]) >= 0 {
                    this[k] := b
                    i--
                    continue 2
                }
                this[k] := this[p]
                k := p
            }
        }

        ; Repeatedly move max to end
        i := n
        while i > 1 {
            t := this[1]
            this[1] := this[i]
            this[i] := t
            i--

            b := this[1]
            k := 1
            if k * 2 <= i {
                left  := k * 2
                right := left + 1
                j := left
                if right <= i && Compare1(this[right], this[left]) > 0 {
                    j := right
                }
                if Compare2(this[j]) <= 0 {
                    continue
                }
            } else {
                continue
            }

            while k * 2 <= i {
                j := k * 2
                if j + 1 <= i && Compare1(this[j + 1], this[j]) > 0 {
                    j++
                }
                this[k] := this[j]
                k := j
            }
            while k > 1 {
                p := Floor(k / 2)
                if Compare2(this[p]) >= 0 {
                    this[k] := b
                    continue 2
                }
                this[k] := this[p]
                k := p
            }
        }
        return this

        _CompareNumber1(a, b) => a - b
        _CompareString1(a, b) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber1(a, b) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString1(a, b) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue1(a, b) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue1(a, b) => Callbackcompare(a, b)
        _CompareNumber2(a) => a - b
        _CompareString2(a) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber2(a) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString2(a) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue2(a) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue2(a) => Callbackcompare(a, b)
    }

    /**
     * @memberof Container
     * @instance
     * @type {DateParser}
     */
    DateParser {
        Get => this.__DateParser
        Set => this.SetDateParser(Value)
    }

    ; /**
    ;  * {@link Container.Filter} objects have four properties:
    ;  * - Call: The {@link Container.Filter.Prototype.Call} method which processes the filter.
    ;  * - Callback: The function object.
    ;  * - Container: The {@link Container} object before it has been processed with `Callback`.
    ;  * - FilterIn: The {@link Container} object that contains only values that caused `Callback`
    ;  *   to return zero or an empty string (to keep the values).
    ;  * - FilterOut: The {@link Container} object that contains only values that caused `Callback`
    ;  *   to return nonzero (to remove the values).
    ;  * - Name: Returns {@link Container.Filter.Prototype.__New~Name} or returns the function's
    ;  *   {@link Container.Filter#Name built-in name}.
    ;  * @classdesc
    ;  */
    ; class Filter {
    ;     /**
    ;      * @param {Integer} Index - The index position of the filter in the filter stack.
    ;      *
    ;      * @param {*} Callback - The function can accept one to three parameters. Parameters 1-3
    ;      * should be optional.
    ;      *
    ;      * Parameters:
    ;      * - The value.  If there is no value, this parameter will be unset (the parameter should be optional).
    ;      * - The value's index.
    ;      * - The {@link Container} object.
    ;      *
    ;      * Return a nonzero value to direct {@link Container.Filter.Prototype.Call} to add the value
    ;      * to the {@link Container.Filter#FilterOut} container.
    ;      *
    ;      * Return zero or an empty string to direct {@link Container.Filter.Prototype.Call} to add ]
    ;      * the value to the {@link Container.Filter#FilterIn} container.
    ;      *
    ;      * @param {String} [Name] - A name to assign to the filter.
    ;      */
    ;     __New(Index, Callback, Name?) {
    ;         this.Index := Index
    ;         this.Callback := Callback
    ;         if IsSet(Name) {
    ;             this.DefineProp('Name', { Value: Name })
    ;         }
    ;     }
    ;     Call() {
    ;         stack := this.FilterStack
    ;         if this.Index = 1 {
    ;             c := this.Container
    ;         } else {
    ;             c := stack[this.Index - 1].FilterIn
    ;         }
    ;         filterIn := this.FilterIn := Container()
    ;         filterOut := this.FilterOut := Container()
    ;         Callback := this.Callback
    ;         loop c.Length {
    ;             if c.Has(A_Index) {
    ;                 if Callback(c[A_Index], A_Index, c) {
    ;                     filterOut.Push(c[A_Index])
    ;                 } else {
    ;                     filterIn.Push(c[A_Index])
    ;                 }
    ;             }
    ;         }
    ;     }
    ;     Name => this.Callback.Name
    ; }

    ; class FilterStack extends Container {
    ;     static __New() {
    ;         this.DeleteProp('__New')
    ;         proto := this.Prototype
    ;     }
    ;     __New(ContainerObj) {
    ;         this.Constructor := Class()
    ;         this.Constructor.Prototype := {
    ;             Container: ContainerObj
    ;           , FilterStack: this
    ;         }
    ;         this.Constructor.Base := Container.Filter
    ;         ObjRelease(ObjPtr(this))
    ;     }
    ;     Add(Callback, Name?) {
    ;         this.Push(this.Constructor.Call(this.Length + 1, Callback, Name ?? unset))
    ;     }
    ;     Call(StartIndex := 1, EndIndex := this.Length) {
    ;         StartIndex--
    ;         loop EndIndex - StartIndex {
    ;             this[++StartIndex]()
    ;         }
    ;     }
    ;     Remove(Value) {
    ;         ; Index
    ;         if IsNumber(Value) {
    ;             i := Value
    ;             removed := this.RemoveAt(Value)
    ;         } else{
    ;             for filter in this {
    ;                 if filter.Name = Value {
    ;                     i := A_Index
    ;                     removed := this.RemoveAt(A_Index)
    ;                     break
    ;                 }
    ;             }
    ;         }
    ;         loop this.Length - i {
    ;             this[i] := this[++i]
    ;             this[i - 1].Index := i - 1
    ;         }
    ;     }
    ;     __Delete() {
    ;         if this.HasOwnProp('Constructor')
    ;         && this.Constructor.HasOwnProp('Prototype')
    ;         && this.Constructor.Prototype.HasOwnProp('FilterStack')
    ;         && ObjPtr(this.Constructor.Prototype.FilterStack) == ObjPtr(this) {
    ;             ObjPtrAddRef(this)
    ;             this.DeleteProp('Constructor')
    ;         }
    ;     }
    ;     Container => this.Constructor.Prototype.Container
    ; }
}
