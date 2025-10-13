
/*
List of sort types
CONTAINER_SORTTYPE_CB_DATE
CONTAINER_SORTTYPE_CB_DATESTR
CONTAINER_SORTTYPE_CB_NUMBER
CONTAINER_SORTTYPE_CB_STRING
CONTAINER_SORTTYPE_CB_STRINGPTR
CONTAINER_SORTTYPE_DATE
CONTAINER_SORTTYPE_DATESTR
CONTAINER_SORTTYPE_DATEVALUE
CONTAINER_SORTTYPE_MISC
CONTAINER_SORTTYPE_NUMBER
CONTAINER_SORTTYPE_STRING
CONTAINER_SORTTYPE_STRINGPTR
*/

/**
 * @param {Boolean} [force = false] - If false, and if {@link Container_SetConstants} has been called
 * before, returns immediately and does not set the values. If true, executes the entire function
 * whether or not {@link Container_SetConstants} has been called before.
 */
Container_SetConstants(force := false) {
    global
    if IsSet(container_flag_constants_set) && !force {
        return
    }
    g_kernel32_CompareStringEx := DllCall('GetProcAddress', 'Ptr', DllCall('GetModuleHandle', 'Str', 'kernel32', 'Ptr'), 'AStr', 'CompareStringEx', 'Ptr')

    if !IsSet(PTR_EMPTY_STRING) {
        PTR_EMPTY_STRING := StrPtr('')
    }

    local i := 0
    CONTAINER_SORTTYPE_CB_DATE         := ++i
    CONTAINER_SORTTYPE_CB_DATESTR      := ++i
    CONTAINER_SORTTYPE_CB_NUMBER       := ++i
    CONTAINER_SORTTYPE_CB_STRING       := ++i
    CONTAINER_SORTTYPE_CB_STRINGPTR    := ++i
    CONTAINER_SORTTYPE_DATE            := ++i
    CONTAINER_SORTTYPE_DATESTR         := ++i
    CONTAINER_SORTTYPE_DATEVALUE       := ++i
    CONTAINER_SORTTYPE_MISC            := ++i
    CONTAINER_SORTTYPE_NUMBER          := ++i
    CONTAINER_SORTTYPE_STRING          := ++i
    CONTAINER_SORTTYPE_STRINGPTR       := ++i
    CONTAINER_SORTTYPE_END             := i ; indicates the final value in the group

    CONTAINER_DEFAULT_ENCODING          := 'cp1200'
    CONTAINER_INSERTIONSORT_THRESHOLD   := 16

    LOCALE_NAME_INVARIANT               := PTR_EMPTY_STRING
    LOCALE_NAME_USER_DEFAULT            := 0
    LOCALE_NAME_SYSTEM_DEFAULT          := StrPtr('!x-sys-default-locale')
    LINGUISTIC_IGNORECASE               := 0x00000010
    LINGUISTIC_IGNOREDIACRITIC          := 0x00000020
    NORM_IGNORECASE                     := 0x00000001
    NORM_IGNOREKANATYPE                 := 0x00010000
    NORM_IGNORENONSPACE                 := 0x00000002
    NORM_IGNORESYMBOLS                  := 0x00000004
    NORM_IGNOREWIDTH                    := 0x00020000
    NORM_LINGUISTIC_CASING              := 0x08000000
    SORT_DIGITSASNUMBERS                := 0x00000008
    SORT_STRINGSORT                     := 0x00001000

    container_flag_constants_set := true
}

Container_CompareStringEx(LocaleName, Flags, NlsVersionInfo, Ptr1, Ptr2) {
    if result := DllCall(
        g_kernel32_CompareStringEx
      , 'ptr', LocaleName
      , 'uint', Flags
      , 'ptr', Ptr1
      , 'int', -1
      , 'ptr', Ptr2
      , 'int', -1
      , 'ptr', NlsVersionInfo
      , 'ptr', 0
      , 'ptr', 0
      , 'int'
    ) {
        return result - 2
    } else {
        throw OSError()
    }
}

Container_CompareDate(date1, date2) {
    return DateDiff(date1, date2, 'S')
}
Container_CompareDateEx(date1, date2) {
    return Container_Date.FromTimestamp(date1).TotalSeconds - Container_Date.FromTimestamp(date2).TotalSeconds
}
Container_CompareDateStr(DateParserObj, dateStr1, dateStr2) {
    return DateParserObj(dateStr1).Diff('S', DateParserObj(dateStr2).Timestamp)
}
Container_CompareDateStr_Century(DateParserObj, Century, dateStr1, dateStr2) {
    return DateParserObj(dateStr1, Century).Diff('S', DateParserObj(dateStr2, Century).Timestamp)
}
Container_CompareDateStr_CompareValue(DateParserObj, date1, dateStr2) {
    return date1.Diff('S', DateParserObj(dateStr2).Timestamp)
}
Container_CompareDateStr_Century_CompareValue(DateParserObj, Century, date1, dateStr2) {
    return date1.Diff('S', DateParserObj(dateStr2, Century).Timestamp)
}
Container_CompareDateStrEx(DateParserObj, dateStr1, dateStr2) {
    return DateParserObj(dateStr1).TotalSeconds - DateParserObj(dateStr2).TotalSeconds
}
Container_CompareDateStr_CenturyEx(DateParserObj, Century, dateStr1, dateStr2) {
    return DateParserObj(dateStr1, Century).TotalSeconds - DateParserObj(dateStr2, Century).TotalSeconds
}
Container_CompareDateStr_CompareValueEx(DateParserObj, date1, dateStr2) {
    return date1.TotalSeconds - DateParserObj(dateStr2).TotalSeconds
}
Container_CompareDateStr_Century_CompareValueEx(DateParserObj, Century, date1, dateStr2) {
    return date1.TotalSeconds - DateParserObj(dateStr2, Century).TotalSeconds
}
Container_CallbackValue_DateValue(Value) {
    return Value.__Container_DateValue
}
Container_CallbackValue_DateValueCustom(PropertyName, Value) {
    return Value.%PropertyName%
}
Container_CallbackDateInsert(PropertyName, DateObjFunc, CallbackValue, Value) {
    Value.DefineProp(PropertyName, { Value: DateObjFunc(CallbackValue(Value)).TotalSeconds })
}
Container_ConvertDate(DateObjFunc, Self, Value) {
    return DateObjFunc(Value).TotalSeconds
}
Container_ConvertDateCb(DateObjFunc, CallbackValue, Self, Value) {
    return DateObjFunc(CallbackValue(Value)).TotalSeconds
}

Container_IndexToSymbol(index) {
    if !Container.HasOwnProp('SortType') {
        Container_SetSortTypeContainer()
    }
    if Container.SortType.Find(index, &value) {
        return value
    } else {
        throw IndexError('``index`` is out of range.', , index)
    }
}
Container_SetSortTypeContainer() {
    sortType := Container.SortType := Container.CbNumber((value) => value.index)
    for s in Container.SortTypeSymbolList {
        if InStr(s, '_CB_') {
            obj := {
                index: %s%
              , name: RegExReplace(s, 'CONTAINER_SORTTYPE_CB_(\w)(\w+)', 'Cb$1$L2')
              , symbol: s
            }
        } else {
            obj := {
                index: %s%
              , name: RegExReplace(s, 'CONTAINER_SORTTYPE_(\w)(\w+)', '$1$L2')
              , symbol: s
            }
        }
        sortType.Insert(obj)
    }
}
