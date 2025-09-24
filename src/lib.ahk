
Container_SetConstants() {
    global
    g_proc_kernel32_CompareStringEx := 0

    Container.LibToken := LibraryManager(
        'kernel32', [ 'CompareStringEx' ]
    )

    if !IsSet(PTR_EMPTY_STRING) {
        PTR_EMPTY_STRING := StrPtr('')
    }

    local i := 0
    CONTAINER_SORTTYPE_CB_DATE         := ++i
    CONTAINER_SORTTYPE_CB_DATESTR      := ++i
    CONTAINER_SORTTYPE_CB_MISC         := ++i
    CONTAINER_SORTTYPE_CB_NUMBER       := ++i
    CONTAINER_SORTTYPE_CB_STRING       := ++i
    CONTAINER_SORTTYPE_CB_STRINGPTR    := ++i
    CONTAINER_SORTTYPE_DATE            := ++i
    CONTAINER_SORTTYPE_DATESTR         := ++i
    CONTAINER_SORTTYPE_NUMBER          := ++i
    CONTAINER_SORTTYPE_STRING          := ++i
    CONTAINER_SORTTYPE_STRINGPTR       := ++i
/*
Template for writing switch statements
switch SortType, 0 {
    case CONTAINER_SORTTYPE_CB_DATE:
    case CONTAINER_SORTTYPE_CB_DATESTR:
    case CONTAINER_SORTTYPE_CB_MISC:
    case CONTAINER_SORTTYPE_CB_NUMBER:
    case CONTAINER_SORTTYPE_CB_STRING:
    case CONTAINER_SORTTYPE_CB_STRINGPTR:
    case CONTAINER_SORTTYPE_DATE:
    case CONTAINER_SORTTYPE_DATESTR:
    case CONTAINER_SORTTYPE_NUMBER:
    case CONTAINER_SORTTYPE_STRING:
    case CONTAINER_SORTTYPE_STRINGPTR:
}
*/
/*
List of sort types
CONTAINER_SORTTYPE_CB_DATE
CONTAINER_SORTTYPE_CB_DATESTR
CONTAINER_SORTTYPE_CB_MISC
CONTAINER_SORTTYPE_CB_NUMBER
CONTAINER_SORTTYPE_CB_STRING
CONTAINER_SORTTYPE_CB_STRINGPTR
CONTAINER_SORTTYPE_DATE
CONTAINER_SORTTYPE_DATESTR
CONTAINER_SORTTYPE_NUMBER
CONTAINER_SORTTYPE_STRING
CONTAINER_SORTTYPE_STRINGPTR
*/

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
}

Container_CompareStringEx(LocaleName, Flags, VersionInformation, Ptr1, Ptr2) {
    if result := DllCall(
        g_proc_kernel32_CompareStringEx
      , 'ptr', LocaleName
      , 'uint', Flags
      , 'ptr', Ptr1
      , 'int', -1
      , 'ptr', Ptr2
      , 'int', -1
      , 'ptr', VersionInformation
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
