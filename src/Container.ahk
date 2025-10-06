/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-Container/tree/main
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

; Only needed if using the NlsVersionInfoEx class.
#include *i NlsVersionInfoEx.ahk

#include Container_Date.ahk
#include lib.ahk

class Container extends Array {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CallbackCompare := proto.CallbackValue := proto.CompareDateCentury :=
        proto.CallbackCompareValue := proto.CompareStringNlsVersionInfo :=
        proto.CompareStringLocaleName := proto.__DateParser := proto.CallbackDateInsert :=
        ''
        proto.SortType := 0
        if !IsSet(CONTAINER_SORTTYPE_NUMBER) {
            Container_SetConstants()
        }
        this.SortTypeSymbolList := [
            'CONTAINER_SORTTYPE_CB_DATE'
          , 'CONTAINER_SORTTYPE_CB_DATESTR'
          , 'CONTAINER_SORTTYPE_CB_NUMBER'
          , 'CONTAINER_SORTTYPE_CB_STRING'
          , 'CONTAINER_SORTTYPE_CB_STRINGPTR'
          , 'CONTAINER_SORTTYPE_DATE'
          , 'CONTAINER_SORTTYPE_DATESTR'
          , 'CONTAINER_SORTTYPE_DATEVALUE'
          , 'CONTAINER_SORTTYPE_MISC'
          , 'CONTAINER_SORTTYPE_NUMBER'
          , 'CONTAINER_SORTTYPE_STRING'
          , 'CONTAINER_SORTTYPE_STRINGPTR'
          , 'CONTAINER_SORTTYPE_END'
        ]
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a string in the format yyyyMMddHHmmss.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDate}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.timestamp
     * }
     *
     * c := Container.CbDate(CallbackValue)
     * c.InsertList([
     *     { timestamp: "20250312122930" }
     *   , { timestamp: "20250411122900" }
     *   , { timestamp: "20251015091805" }
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static CbDate(CallbackValue, UseCompareDateEx := false, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_CB_DATE)
        c.SetCallbackValue(CallbackValue)
        c.SetCompareDate(UseCompareDateEx)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized by the
     * {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDateStr}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * c := Container.CbDateStr(CallbackValue, "yyyy-MM-dd HH:mm:ss")
     * c.InsertList([
     *     { date: "2025-03-12 12:29:30" }
     *   , { date: "2025-04-11 12:29:00" }
     *   , { date: "2025-10-15 09:18:05" }
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static CbDateStr(CallbackValue, DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
        c.SetCallbackValue(CallbackValue)
        c.SetCompareDateStr(DateFormat, RegExOptions, Century ?? unset, UseCompareDateEx)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized
     * by the {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetDateParser}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * dateParser := Container_DateParser("yyyy-MM-dd HH:mm:ss")
     * c := Container.CbDateStrFromParser(CallbackValue, dateParser)
     * c.InsertList([
     *     { date: "2025-03-12 12:29:30" }
     *   , { date: "2025-04-11 12:29:00" }
     *   , { date: "2025-10-15 09:18:05" }
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {Container_DateParser} DateParserObj - The {@link Container_DateParser}.
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateStr} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static CbDateStrFromParser(CallbackValue, DateParserObj, Century?, UseCompareDateEx := false, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
        c.SetCallbackValue(CallbackValue)
        c.SetDateParser(DateParserObj, Century ?? unset, UseCompareDateEx)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a number.
     * - **CallbackCompare**: Not used.
     *
     * @example
     * CallbackValue(value) {
     *     return value.value
     * }
     *
     * c := Container.CbNumber(CallbackValue)
     * c.InsertList([
     *     { value: 298581 }
     *   , { value: 195801 }
     *   , { value: 585929 }
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static CbNumber(CallbackValue, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_CB_NUMBER)
        c.SetCallbackValue(CallbackValue)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a string.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.name
     * }
     *
     * c := Container.CbString(CallbackValue)
     * c.InsertList([
     *     { name: "obj4" }
     *   , { name: "obj3" }
     *   , { name: "obj1" }
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static CbString(CallbackValue, LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_CB_STRING)
        c.SetCallbackValue(CallbackValue)
        c.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a pointer to a null-terminated string.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * If you know your code will be used for a lot of sorting and finding operations, you can
     * improve performance by storing the name / key in a buffer.
     *
     * @example
     * class ImageSamples {
     *     __New(Name, ImageData) {
     *         this.NameBuffer := Buffer(StrPut(Name, "cp1200"))
     *         StrPut(Name, this.NameBuffer, "cp1200")
     *         this.ImageData := ImageData
     *     }
     *     Name => StrGet(this.NameBuffer, "cp1200")
     * }
     *
     * CallbackValue(value) {
     *     return value.NameBuffer.Ptr
     * }
     *
     * c := Container.CbStringPtr(CallbackValue)
     * c.InsertList([
     *     ImageSamples("obj4", data4)
     *   , ImageSamples("obj3", data3)
     *   , ImageSamples("obj1", data1)
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static CbStringPtr(CallbackValue, LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_CB_STRINGPTR)
        c.SetCallbackValue(CallbackValue)
        c.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return c
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDate}.
     *
     * @example
     * c := Container.Date()
     * c.InsertList([
     *     "20250312122930"
     *   , "20250411122900"
     *   , "20251015091805"
     * ])
     * @
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static Date(UseCompareDateEx := false, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_DATE)
        c.SetCompareDate(UseCompareDateEx)
        return c
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDateStr}.
     *
     * @example
     * c := Container.DateStr("yyyy-MM-dd HH:mm:ss")
     * c.InsertList([
     *     "2025-03-12 12:29:30"
     *   , "2025-04-11 12:29:00"
     *   , "2025-10-15 09:18:05"
     * ])
     * @
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static DateStr(DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_DATESTR)
        c.SetCompareDateStr(DateFormat, RegExOptions, Century ?? unset, UseCompareDateEx)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized
     * by the {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetDateParser}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * dateParser := Container_DateParser("yyyy-MM-dd HH:mm:ss")
     * c := Container.DateStrFromParser(dateParser)
     * c.InsertList([
     *     "2025-03-12 12:29:30"
     *   , "2025-04-11 12:29:00"
     *   , "2025-10-15 09:18:05"
     * ])
     * @
     *
     * @param {Container_DateParser} DateParserObj - The {@link Container_DateParser}.
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateStr} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static DateStrFromParser(DateParserObj, Century?, UseCompareDateEx := false, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_DATESTR)
        c.SetDateParser(DateParserObj, Century ?? unset, UseCompareDateEx)
        return c
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized
     * by the {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.DatePreprocess}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * c := Container.DateValue(CallbackValue, "yyyy-MM-dd HH:mm:ss")
     * ; Use DateInsertList (not InsertList)
     * c.DateInsertList([
     *     { date: "2025-03-12 12:29:30" }
     *   , { date: "2025-04-11 12:29:00" }
     *   , { date: "2025-10-15 09:18:05" }
     * ])
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static DateValue(CallbackValue, DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false, PropertyName := '__Container_DateValue', Values*) {
        c := this.CbDateStr(CallbackValue, DateFormat, RegExOptions, Century ?? unset, UseCompareDateEx)
        if Values.Length {
            c.Push(Values*)
        }
        c.DatePreprocess(, , PropertyName)
        return c
    }
    /**
     * Converts an existing `Array` object into a `Container` object.
     *
     * @param {Array} Arr - The `Array` object to convert.
     *
     * @returns {Container} - The same `Arr` after changing the base to `Container.Prototype`.
     */
    static FromArray(Arr) {
        ObjSetBase(Arr, this.Prototype)
        return Arr
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: Provided by your code and implements custom logic to return the comparison
     * value.
     *
     * @example
     * CallbackCompare(value1, value2) {
     *     ; Implements some logic and returns a number
     *     ; indicating the relationship of the two values
     * }
     *
     * c := Container.Misc(CallbackCompare)
     * c.InsertList([
     *     { id: "CFikHajB" }
     *   , { id: "zhLAlxeK" }
     *   , { id: "RwaedOSw" }
     * ])
     * @
     *
     * @param {*} CallbackCompare - The callback to use as a comparator for sorting operations. Sets
     * the property {@link Container#CallbackCompare}.
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
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static Misc(CallbackCompare, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_MISC)
        c.SetCallbackCompare(CallbackCompare)
        return c
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: Not used.
     *
     * @example
     * c := Container.Number()
     * c.InsertList([
     *     298581
     *   , 195801
     *   , 585929
     * ])
     * @
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static Number(Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_NUMBER)
        return c
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * c := Container.String()
     * c.InsertList([
     *     "string4"
     *   , "string3"
     *   , "string1"
     * ])
     * @
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static String(LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_STRING)
        c.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return c
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * StrBuf(str) {
     *     buf := Buffer(StrPut(str, "cp1200"))
     *     StrPut(str, buf, "cp1200")
     *     return buf
     * }
     *
     * buf1 := StrBuf("string4")
     * buf2 := StrBuf("string3")
     * buf3 := StrBuf("string1")
     *
     * c := Container.StringPtr()
     * c.InsertList([
     *     buf1.Ptr
     *   , buf2.Ptr
     *   , buf3.Ptr
     * ])
     * @
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    static StringPtr(LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        c := Container(Values*)
        c.SetSortType(CONTAINER_SORTTYPE_STRINGPTR)
        c.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return c
    }
    /**
     * Calls {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm StrSplit} and converts
     * the return value to a {@link Container}. Calls {@link Container.Prototype.ToString} from
     * the new container.
     *
     * @param {String} Str - The string to pass to {@link https://www.autohotkey.com/docs/v2/lib/StrSplit.htm StrSplit}.
     *
     * @param {String} [Delimiters] - If blank or omitted, each character of the input string will
     * be treated as a separate substring.
     *
     * Otherwise, specify either a single string or an array of strings (case-sensitive), each of
     * which is used to determine where the boundaries between substrings occur. Since the
     * delimiters are not considered to be part of the substrings themselves, they are never
     * included in the returned array. Also, if there is nothing between a pair of delimiters
     * within the input string, the corresponding array element will be blank.
     *
     * For example: "," would divide the string based on every occurrence of a comma. Similarly,
     * `[A_Space, A_Tab]` would create a new array element every time a space or tab is encountered
     * in the input string.
     *
     * @param {String} [OmitChars] - If blank or omitted, no characters will be excluded. Otherwise,
     * specify a list of characters (case-sensitive) to exclude from the beginning and end of each
     * array element. For example, if OmitChars is " `t", spaces and tabs will be removed from the
     * beginning and end (but not the middle) of every element.
     *
     * If Delimiters is blank, OmitChars indicates which characters should be excluded from the array.
     *
     * @param {Integer} [MaxParts = -1] - If omitted, it defaults to -1, which means "no limit".
     * Otherwise, specify the maximum number of substrings to return. If non-zero, the string is
     * split a maximum of MaxParts-1 times and the remainder of the string is returned in the last
     * substring (excluding any leading or trailing OmitChars).
     *
     * @returns {Container}
     */
    static StrSplit(Str, Delimiters?, OmitChars?, MaxParts := -1, LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0) {
        split := StrSplit(Str, Delimiters ?? unset, OmitChars ?? unset, MaxParts)
        ObjSetBase(split, Container.Prototype)
        split.ToString(LocaleName, Flags, NlsVersionInfo)
        return split
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Compares the input value with a value in the container.
     * @example
     * if index := c.Find(MyValue) {
     *     ; do something
     * } else {
     *     ; Since it didn't return an index, we know `MyValue` is outside of the range of the container.
     *     ; To place the value in order, we must know if it should be placed at the beginning or end.
     *     if c.Compare(MyValue, 1) < 0 {
     *         c.InsertAt(1, MyValue)
     *     } else {
     *         c.Push(MyValue)
     *     }
     * }
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
                    return this.CallbackCompareValue.Call(Container_Date.FromTimestamp(Value), this[Index])
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
                        date1 := Container_Date.FromTimestamp(Value)
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
            case CONTAINER_SORTTYPE_MISC:
                return this.CallbackCompare.Call(Value, this[Index])
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                return Value - this[Index].__Container_DateValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * Removes all unset indices, shifting the values to the left.
     */
    Condense(IndexStart := 1, IndexEnd := this.Length) {
        IndexStart--
        loop IndexEnd - IndexStart {
            if !this.Has(++IndexStart) {
                this.RemoveAt(IndexStart--)
            }
        }
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * Creates a new {@link Container}, copying the values of any own properties of this object.
     * The base object of the new {@link Container} is also set to the base of this object.
     *
     * The new container is empty. To also fill the container with the same values, use the built-in
     * `Array.Prototype.Clone` method, e.g. `containerObj.Clone()`.
     */
    Copy() {
        c := Container()
        for prop in this.OwnProps() {
            c.DefineProp(prop, this.GetOwnPropDesc(prop))
        }
        ObjSetBase(c, this.Base)
        return c
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * {@link Container#DateConvert} is defined from the body of {@link Container.Prototype.DatePreprocess}.
     * This converts a string value to a value that can be passed to any of the binary search methods.
     *
     * @example
     * c := Container(
     *     { Date: "3/1/25 12:01" }
     *   , { Date: "3/1/25 12:15" }
     *   , { Date: "3/1/25 9:17" }
     *   , { Date: "3/1/25 14:25" }
     * )
     * c.SetDateCompareDateStr("M/d/yy H:mm")
     * c.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
     * c.SetCallbackValue((value) => value.Date)
     * c.DatePreprocess()
     * ; After calling c.DatePreprocess, I can no longer search for values using strings
     * ; like "3/1/25 9:17", so I have to convert the date string to a date value
     * dateValue := c.DateConvert("3/1/25 9:17")
     * index := c.Find(dateValue)
     * OutputDebug(index "`n") ; 1
     * @
     *
     * @param {*} Value - The value to convert to an integer.
     */
    DateConvert(Value) {
        throw Error(A_ThisFunc ' must be overridden by ``Container.Prototype.DatePreprocess``.')
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * {@link Container#DateConvertCb} is defined from the body of {@link Container.Prototype.DatePreprocess}.
     * This converts an object value to a value that can be passed to any of the binary search methods.
     *
     * @example
     * c := Container(
     *     { Date: "3/1/25 12:01" }
     *   , { Date: "3/1/25 12:15" }
     *   , { Date: "3/1/25 9:17" }
     *   , { Date: "3/1/25 14:25" }
     * )
     * c.SetDateCompareDateStr("M/d/yy H:mm")
     * c.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
     * c.SetCallbackValue((value) => value.Date)
     * c.DatePreprocess()
     * ; After calling c.DatePreprocess, I can no longer search for values using strings
     * ; like "3/1/25 9:17", so I have to convert the date string to a date value
     * dateValue := c.DateConvert({ Date: "3/1/25 9:17" })
     * index := c.Find(dateValue)
     * OutputDebug(index "`n") ; 1
     * ; This is unnecessary for values taken directly from the container
     * ; because the values in the container are processed and can be
     * ; used directly.
     * valueToFind := c[2]
     * index := c.Find(valueToFind)
     * OutputDebug(index "`n") ; 2
     * @
     *
     * @param {*} Value - The value to convert to an integer.
     */
    DateConvertCb(Value) {
        throw Error(A_ThisFunc ' must be overridden by ``Container.Prototype.DatePreprocess``.')
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts a value in order. See {@link Container.Prototype.DatePreprocess} for more
     * information.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    DateInsert(Value) {
        this.CallbackDateInsert.Call(Value)
        return this.Insert(Value)
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts a value in order if the value does not exist in the container. See
     * {@link Container.Prototype.DatePreprocess} for more information.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    DateInsertIfAbsent(Value) {
        this.CallbackDateInsert.Call(Value)
        return this.InsertIfAbsent(Value)
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts a value in order if the value does not exist in the container. See
     * {@link Container.Prototype.DatePreprocess} for more information.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    DateInsertIfAbsentSparse(Value) {
        this.CallbackDateInsert.Call(Value)
        return this.InsertIfAbsentSparse(Value)
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts values in order. See {@link Container.Prototype.DatePreprocess} for more information.
     *
     * @param {*} Values - One or more values to insert.
     */
    DateInsertList(Values) {
        if Values is Array {
            callbackDateInsert := this.CallbackDateInsert
            for value in Values {
                callbackDateInsert.Call(value)
                this.Insert(value)
            }
        } else {
            this.CallbackDateInsert.Call(Values)
            this.Insert(Values)
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts values in order. See {@link Container.Prototype.DatePreprocess} for more information.
     *
     * @param {*} Values - One or more values to insert.
     */
    DateInsertListSparse(Values) {
        if Values is Array {
            callbackDateInsert := this.CallbackDateInsert
            loop Values.Length {
                if Values.Has(A_Index) {
                    callbackDateInsert.Call(Values[A_Index])
                    this.InsertSparse(Values[A_Index])
                }
            }
        } else {
            this.CallbackDateInsert.Call(Values)
            this.InsertSparse(Values)
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts a value in order. See {@link Container.Prototype.DatePreprocess} for more
     * information.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    DateInsertSparse(Value) {
        this.CallbackDateInsert.Call(Value)
        return this.InsertSparse(Value)
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * {@link Container.Prototype.DatePreprocess} iterates the values in the container and sets
     * a property with an integer representing the number of seconds between 01/01/0001 00:00:00 and
     * the date associated with that value. This allows sorting operations to be performed with
     * simple arithmetic, significantly improving performance.
     *
     * There are two options for adding values to the container after
     * {@link Container.Prototype.DatePreprocess} has been called:
     * - Call {@link Container.Prototype.DateInsert} or {@link Container.Prototype.DateInsertSparse}
     *   to add one value to an already-sorted container.
     * - Add one or more values to the end of the container, then call
     *   {@link Container.Prototype.DateUpdate} specifying the range.
     *
     * To use {@link Container.Prototype.DatePreprocess}, the following must be true:
     * - The values in the container are objects.
     * - Property {@link Container#SortType} is CONTAINER_SORTTYPE_CB_DATE or CONTAINER_SORTTYPE_CB_DATESTR.
     * - Property {@link Container#CallbackValue} is set with a function that will return the date
     *   string, or your code passes a function to parameter `CallbackValue`.
     *
     * If {@link Container#SortType} is CONTAINER_SORTTYPE_CB_DATESTR, then there is one additional
     * requirement:
     * - Your code has previously called {@link Container.Prototype.SetCompareDateStr}, or your
     *   code passes a {@link Container_DateParser} to parameter `DateParserObj`.
     *
     * After calling {@link Container.Prototype.DatePreprocess}, your code has a range of options for
     * kinds of values to pass to the methods that implement a binary search. You can pass
     * - A date string that is in the format readable by {@link Container#DateParser}.
     * - An object that returns a date string when passed to {@link Container#CallbackValue}.
     * - An object that has the property `PropertyName` (i.e. an object in the container that has
     *   been processed by {@link Container.Prototype.DatePreprocess} or
     *   {@link Container.Prototype.DateUpdate}.
     * - A date value number, e.g. a value returned by {@link Container#DateConvert} or
     *   {@link Container#DateConvertCb}.
     *
     * The following are some additional actions taken by {@link Container.Prototype.DatePreprocess}:
     * - Sets property {@link Container#CallbackDateInsert} with a function that sets the property
     *   with the date value.
     * - Sets property {@link Container#DateConvert} with a function that returns the date
     *   value from an input string.
     * - Sets property {@link Container#DateConvertCb} with a function that returns the date
     *   value from an input object.
     * - Deletes property {@link Container#CallbackCompare} if it exists.
     * - If the sort type is `CONTAINER_SORTTYPE_CB_DATESTR ` and if a value is passed to
     *   `DateParserObj`, property {@link Container#__DateParser} is set with that value.
     *
     * If the value of `PropertyName` is the default "__Container_DateValue":
     * - Sets the value of property {@link Container#SortType} to CONTAINER_SORTTYPE_DATEVALUE.
     * - Sets the value of property {@link Container#CallbackValue} to{@link Container_CallbackValue_DateValue}.
     *
     * If the value of `PropertyName` is something other than the default:
     * - Sets the value of property {@link Container#SortType} to CONTAINER_SORTTYPE_CB_NUMBER.
     * - Sets the value of property {@link Container#CallbackValue} to {@link Container_CallbackValue_DateValueCustom}.
     *
     * @param {*} [CallbackValue] - The `Func` or callable object that is called to get the date
     * string associated with each object. This is required if property {@link Container#CallbackValue}
     * is not set.
     *
     * @param {Container_DateParser} [DateParserObj] - The {@link Container_DateParser} that will
     * be used to produce the date value. This is required if property {@link Container#__DateParser}
     * is not set. This value is set to property {@link Container#__DateParser}.
     *
     * This is ignored if {@link Container#SortType} is not CONTAINER_SORTTYPE_CB_DATESTR.
     *
     * @param {String} [PropertyName = "__Container_DateValue"] - The name of the property that
     * is set with the date value. {@link Container} is optimized to use the default name. Changing
     * the name is valid but reduces performance.
     */
    DatePreprocess(CallbackValue?, DateParserObj?, PropertyName := '__Container_DateValue') {
        if !IsSet(CallbackValue) {
            CallbackValue := this.CallbackValue
        }
        if this.SortType = CONTAINER_SORTTYPE_CB_DATE {
            Fn := ObjBindMethod(Container_Date, 'FromTimestamp')
        } else if this.SortType = CONTAINER_SORTTYPE_CB_DATESTR {
            Fn := DateParserObj ?? this.__DateParser
        } else {
            throw PropertyError('Property "SortType" must be either CONTAINER_SORTTYPE_CB_DATE or CONTAINER_SORTTYPE_CB_DATESTR.')
        }
        this.CallbackDateInsert := Container_CallbackDateInsert.Bind(PropertyName, Fn, CallbackValue)
        this.DefineProp('DateConvert', { Call: Container_ConvertDate.Bind(Fn) })
        this.DefineProp('DateConvertCb', { Call: Container_ConvertDateCb.Bind(Fn, CallbackValue) })
        i := 0
        loop this.Length {
            if this.Has(++i) {
                this[i].DefineProp(PropertyName, { Value: Fn(CallbackValue(this[i])).TotalSeconds })
            }
        }
        if this.HasOwnProp('CallbackCompare') {
            this.DeleteProp('CallbackCompare')
        }
        if PropertyName = '__Container_DateValue' {
            this.SortType := CONTAINER_SORTTYPE_DATEVALUE
            this.CallbackValue := Container_CallbackValue_DateValue
        } else {
            this.SortType := CONTAINER_SORTTYPE_CB_NUMBER
            this.CallbackValue := Container_CallbackValue_DateValueCustom.Bind(PropertyName)
        }
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * For each value in the indicated range, sets a property with an integer representing the number
     * of seconds between 01/01/0001 00:00:00 and the date associated with that value.
     *
     * {@link Container.Prototype.DateUpdate} can only be called after
     * {@link Container.Prototype.DatePreprocess} has been called at least once.
     *
     * @param {Integer} [IndexStart = 1] - The start index.
     *
     * @param {Integer} [IndexEnd = this.Length] - The end index.
     */
    DateUpdate(IndexStart := 1, IndexEnd := this.Length) {
        Fn := this.CallbackDateInsert
        IndexStart--
        loop IndexEnd - IndexStart {
            if this.Has(++IndexStart) {
                Fn(this[IndexStart])
            }
        }
    }
    /**
     * @description - Recursively copies the {@link Container} object's properties onto a new object. For all new objects,
     * `ObjDeepClone` attempts to set the new object's base to the same base as the subject. For objects
     * that inherit from `Map` or `Array`, clones the items in addition to the properties.
     * @param {*} Self - The object to be deep cloned. If calling this method from an instance,
     * exclude this parameter.
     * @param {Map} [ConstructorParams] - A map of constructor parameters, where the key is the class
     * name (use `ObjToBeCloned.__Class` as the key), and the value is an array of values that will be
     * passed to the constructor. Using `ConstructorParams` can allow `ObjDeepClone` to create correctly-
     * typed objects in cases where normally AHK will not allow setting the type using `ObjSetBase()`.
     * @param {Integer} [Depth = 0] - The maximum depth to clone. A value equal to or less than 0 will
     * result in no limit.
     * @returns {*}
     */
    DeepClone(ConstructorParams?, Depth := 0) {
        GetTarget := IsSet(ConstructorParams) ? _GetTarget2 : _GetTarget1
        Result := GetTarget(this)
        PtrList := Map(ObjPtr(this), Result)
        CurrentDepth := 0
        return _Recurse(Result, this)

        _Recurse(Target, Subject) {
            CurrentDepth++
            for Prop in Subject.OwnProps() {
                Desc := Subject.GetOwnPropDesc(Prop)
                if Desc.HasOwnProp('Value') {
                    Target.DefineProp(Prop, { Value: IsObject(Desc.Value) ? _ProcessValue(Desc.Value) : Desc.Value })
                } else {
                    Target.DefineProp(Prop, Desc)
                }
            }
            if Target is Array {
                Target.Length := Subject.Length
                for item in Subject {
                    if IsSet(item) {
                        Target[A_Index] := IsObject(item) ? _ProcessValue(item) : item
                    }
                }
            } else if Target is Map {
                Target.Capacity := Subject.Capacity
                for Key, Val in Subject {
                    if IsObject(Key) {
                        Target.Set(_ProcessValue(Key), IsObject(Val) ? _ProcessValue(Val) : Val)
                    } else {
                        Target.Set(Key, IsObject(Val) ? _ProcessValue(Val) : Val)
                    }
                }
            }
            CurrentDepth--
            return Target
        }
        _GetTarget1(Subject) {
            try {
                Target := GetObjectFromString(Subject.__Class)()
            } catch {
                if Subject Is Map {
                    Target := Map()
                } else if Subject is Array {
                    Target := Array()
                } else {
                    Target := Object()
                }
            }
            try {
                ObjSetBase(Target, Subject.Base)
            }
            return Target
        }
        _GetTarget2(Subject) {
            if ConstructorParams.Has(Subject.__Class) {
                Target := GetObjectFromString(Subject.__Class)(ConstructorParams.Get(Subject.__Class)*)
            } else {
                try {
                    Target := GetObjectFromString(Subject.__Class)()
                } catch {
                    if Subject Is Map {
                        Target := Map()
                    } else if Subject is Array {
                        Target := Array()
                    } else {
                        Target := Object()
                    }
                }
                try {
                    ObjSetBase(Target, Subject.Base)
                }
            }
            return Target
        }
        _ProcessValue(Val) {
            if Val is ComValue {
                return Val
            }
            if PtrList.Has(ObjPtr(Val)) {
                return PtrList.Get(ObjPtr(Val))
            }
            if CurrentDepth == Depth {
                return Val
            } else {
                PtrList.Set(ObjPtr(Val), _Target := GetTarget(Val))
                return _Recurse(_Target, Val)
            }
        }
        GetObjectFromString(Path) {
            Split := StrSplit(Path, '.')
            if !IsSet(%Split[1]%)
                return
            OutObj := %Split[1]%
            i := 1
            while ++i <= Split.Length {
                if !OutObj.HasOwnProp(Split[i])
                    return
                OutObj := OutObj.%Split[i]%
            }
            return OutObj
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Calls {@link Container.Prototype.FindAll} to find a value in the container. If the
     * value is found, deletes each instance of the value, leaving the indices unset.
     *
     * @param {*} Value - The value to find and delete.
     *
     * @param {VarRef} [OutList] - A variable that will receive a {@link Container} containing
     * the deleted values. The {@link Container} is created by calling {@link Container.Prototype.Copy}.
     * You must set the variable with a nonzero value before calling {@link Container.Prototype.DeleteAll}
     * to direct the function to collect the values.
     *
     * @example
     * ; Assume `c` is a correctly prepared `Container`.
     * index := c.DeleteAll(1000, &list := true)
     * for v in list {
     *     ; do something
     * }
     * @
     *
     * @returns {Integer} - If the value is found, the first index from left-to-right where the value
     * was located. Else, 0.
     */
    DeleteAll(Value, &OutList?) {
        if index := this.FindAll(Value, &lastIndex) {
            i := index - 1
            if IsSet(OutList) && OutList {
                OutList := this.Copy()
                loop lastIndex - i {
                    OutList.Push(this.Delete(++i))
                }
            } else {
                loop lastIndex - i {
                    this.Delete(++i)
                }
            }
            return index
        }
        return 0
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Calls {@link Container.Prototype.FindAllSparse} to find a value in the container. If the
     * value is found, deletes each instance of the value, leaving the indices unset.
     *
     * @param {*} Value - The value to find and delete.
     *
     * @param {VarRef} [OutList] - A variable that will receive a {@link Container} containing
     * the deleted values. The {@link Container} is created by calling {@link Container.Prototype.Copy}.
     * You must set the variable with a nonzero value before calling
     * {@link Container.Prototype.DeleteAllSparse} to direct the function to collect the values.
     *
     * @example
     * ; Assume `c` is a correctly prepared `Container`.
     * index := c.DeleteAllSparse(1000, &list := true)
     * for v in list {
     *     ; do something
     * }
     * @
     *
     * @returns {Integer} - If the value is found, the first index from left-to-right where the value
     * was located. Else, 0.
     */
    DeleteAllSparse(Value, &OutList?) {
        if index := this.FindAllSparse(Value, &lastIndex) {
            i := index - 1
            if IsSet(OutList) && OutList {
                OutList := this.Copy()
                loop lastIndex - i {
                    if this.Has(++i) {
                        OutList.Push(this.Delete(i))
                    }
                }
            } else {
                loop lastIndex - i {
                    if this.Has(++i) {
                        this.Delete(i)
                    }
                }
            }
            return index
        }
        return 0
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Calls {@link Container.Prototype.Find} to find a value in the container. If the
     * value is found, deletes the value, leaving the index unset. If the value is not found, throws
     * an error.
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
     * Requires a sorted container: yes.
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
     * Requires a sorted container: yes.
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
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Calls {@link Container.Prototype.FindSparse} to find a value in the container. If the
     * value is found, deletes the value, leaving the index unset. If the value is not found, throws
     * an error.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: yes.
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
            return 0
        }
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_CB_DATE:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := Container_Date.FromTimestamp(Value)
                } else {
                    Value := Container_Date.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                CallbackValue := this.CallbackValue
                Compare := _CompareCbValue
                if IsObject(Value) {
                    Value := CallbackValue(Value)
                }
                if IsNumber(Value) {
                    Value := Container_Date.FromTimestamp(Value)
                } else {
                    Value := this.__DateParser.Call(
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
                Compare := _CompareCbValue
                if !IsNumber(Value) {
                    if IsObject(Value) {
                        Value := CallbackValue(Value)
                    } else {
                        _value := Value
                        Value := StrPtr(_value)
                    }
                }
            case CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            case CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                Compare := _CompareValue
                if IsNumber(Value) {
                    Value := Container_Date.FromTimestamp(Value)
                } else {
                    Value := this.DateParser.Call(
                        Value
                      , StrLen(this.CompareDateCentury) ? this.CompareDateCentury : unset
                    )
                }
                if !Value {
                    throw Error('Failed to parse ``Value``.', , Value)
                }
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                Compare := _CompareDateValue
            case CONTAINER_SORTTYPE_MISC:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
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
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        while IndexEnd - IndexStart > 4 {
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

        _CompareDateValue() => Value - this[i].__Container_DateValue
        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue() => CallbackCompare(Value, this[i])
    }
    /**
     * Requires a sorted container: yes.
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
            return 0
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
                    Value := Container_Date.FromTimestamp(Value)
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
                Compare := _CompareCbValue
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
                    Value := Container_Date.FromTimestamp(Value)
                } else {
                    Value := Container_Date.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                CallbackValue := this.CallbackValue
                Compare := _CompareCbValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := Container_Date.FromTimestamp(Value)
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                Compare := _CompareDateValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        while IndexEnd - IndexStart > 4 {
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

        _CompareDateValue() => Value - this[i].__Container_DateValue
        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue() => CallbackCompare(Value, this[i])
    }
    /**
     * Requires a sorted container: yes.
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
            return 0
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
                    Value := Container_Date.FromTimestamp(Value)
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
                Compare := _CompareCbValue
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
                    Value := Container_Date.FromTimestamp(Value)
                } else {
                    Value := Container_Date.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                CallbackValue := this.CallbackValue
                Compare := _CompareCbValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := Container_Date.FromTimestamp(Value)
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                Compare := _CompareDateValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        while IndexEnd - IndexStart > 4 {
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

        _CompareDateValue() => Value - this[i].__Container_DateValue
        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue() => CallbackCompare(Value, CallbackValue(this[i]))
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
     * Requires a sorted container: yes.
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
            return 0
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
                    Value := Container_Date.FromTimestamp(Value)
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
                        date := Container_Date.FromTimestamp(Value)
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                Compare1 := _CompareDateValue1
                Compare2 := _CompareDateValue2
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }

        ;@region 1 Unique val
        ; This block handles conditions where there is only one unique value between `IndexStart`
        ; and `IndexEnd`.
        if IndexEnd > IndexStart {
            x := Compare2(IndexStart, IndexEnd)
        } else {
            x := 0
        }
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

        ;@region Process
        while IndexEnd - IndexStart > 4 {
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

        _CompareDateValue1() => Value - this[i].__Container_DateValue
        _CompareNumber1() => Value - this[i]
        _CompareString1() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber1() => Value - CallbackValue(this[i])
        _CompareCbString1() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue1() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue1() => CallbackCompare(Value, this[i])
        _CompareDate1() => CallbackCompareValue(Value, this[i])
        _CompareCbDate1() => CallbackCompareValue(Value, CallbackValue(this[i]))

        _CompareDateValue2(a, b) => this[a].__Container_DateValue - this[b].__Container_DateValue
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
             * if GT {
             *     HEV_Direction := BaseDirection == 1 ? -1 : 1
             * } else {
             *     HEV_Direction := BaseDirection == 1 ? 1 : -1
             * }
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
             * if GT {
             *     HEV_Direction := BaseDirection == 1 ? 1 : -1
             * } else {
             *     HEV_Direction := BaseDirection == 1 ? -1 : 1
             * }
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
     * Requires a sorted container: yes.
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
            return 0
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
                    Value := Container_Date.FromTimestamp(Value)
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
                        date := Container_Date.FromTimestamp(Value)
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                Compare1 := _CompareDateValue1
                Compare2 := _CompareDateValue2
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
        if IndexEnd > IndexStart {
            x := Compare2(left, right)
        } else {
            x := 0
        }
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

        stop := -1
        rng := IndexEnd - IndexStart + 1
        ;@region Process
        while rng * 0.5 ** stop > 4 {
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

        _CompareDateValue1() => Value - this[i].__Container_DateValue
        _CompareNumber1() => Value - this[i]
        _CompareString1() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber1() => Value - CallbackValue(this[i])
        _CompareCbString1() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue1() => CallbackCompare(Value, CallbackValue(this[i]))
        _CompareValue1() => CallbackCompare(Value, this[i])
        _CompareDate1() => CallbackCompareValue(Value, this[i])
        _CompareCbDate1() => CallbackCompareValue(Value, CallbackValue(this[i]))

        _CompareDateValue2(a, b) => this[a].__Container_DateValue - this[b].__Container_DateValue
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
             * if GT {
             *     HEV_Direction := BaseDirection == 1 ? -1 : 1
             * } else {
             *     HEV_Direction := BaseDirection == 1 ? 1 : -1
             * }
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
             * if GT {
             *     HEV_Direction := BaseDirection == 1 ? 1 : -1
             * } else {
             *     HEV_Direction := BaseDirection == 1 ? -1 : 1
             * }
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
     * Requires a sorted container: yes.
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
            return 0
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
                    Value := Container_Date.FromTimestamp(Value)
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
                Compare := _CompareCbValue
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
                    Value := Container_Date.FromTimestamp(Value)
                } else {
                    Value := Container_Date.FromTimestamp(this.CallbackValue.Call(Value))
                }
            case CONTAINER_SORTTYPE_CB_DATESTR:
                CallbackCompare := this.CallbackCompareValue
                CallbackValue := this.CallbackValue
                Compare := _CompareCbValue
                date := ''
                if !IsObject(Value) {
                    if IsNumber(Value) {
                        date := Container_Date.FromTimestamp(Value)
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE:
                CallbackCompare := this.CallbackCompare
                Compare := _CompareValue
            case CONTAINER_SORTTYPE_DATEVALUE:
                if IsObject(Value) {
                    if HasProp(Value, '__Container_DateValue') {
                        Value := Value.__Container_DateValue
                    } else {
                        Value := this.DateConvertCb(Value)
                    }
                } else if !IsNumber(Value) {
                    Value := this.DateConvert(Value)
                }
                Compare := _CompareDateValue
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }
        while IndexEnd - IndexStart > 4 {
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
        i := IndexStart - 1
        loop IndexEnd - i + 1 {
            if this.Has(++i) && !Compare() {
                OutValue := this[i]
                return i
            }
        }

        return 0

        _CompareDateValue() => Value - this[i].__Container_DateValue
        _CompareNumber() => Value - this[i]
        _CompareString() => CallbackCompare(Value, StrPtr(this[i]))
        _CompareCbNumber() => Value - CallbackValue(this[i])
        _CompareCbString() => CallbackCompare(Value, StrPtr(CallbackValue(this[i])))
        _CompareCbValue() => CallbackCompare(Value, CallbackValue(this[i]))
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Uses {@link Container.Prototype.Find} to return a value.
     *
     * @param {*} Value - The value passed to {@link Container.Prototype.Find}.
     *
     * @param {*} [Default] - The value to return if {@link Container.Prototype.Find} returns 0.
     *
     * @returns {*} -  If found, returns the found value. If not found, and if `Default` is set,
     * returns `Default`. If `Default` is not set, and if the container has a
     * {@link https://www.autohotkey.com/docs/v2/lib/Array.htm#Default "Default"} property, returns
     * `this.Default`. Else, throws an error.
     *
     * @throws {UnsetItemError} - "Value not found."
     */
    GetValue(Value, Default?) {
        if this.Find(Value, &outValue) {
            return outValue
        } else {
            if IsSet(Default) {
                return Default
            } else if HasProp(this, 'Default') {
                return this.Default
            } else {
                throw UnsetItemError('Value not found.')
            }
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Uses {@link Container.Prototype.Find} to return a value.
     *
     * @param {*} Value - The value passed to {@link Container.Prototype.Find}.
     *
     * @param {*} [Default] - The value to return if {@link Container.Prototype.Find} returns 0.
     *
     * @returns {*} -  If found, returns the found value. If not found, and if `Default` is set,
     * returns `Default`. If `Default` is not set, and if the container has a
     * {@link https://www.autohotkey.com/docs/v2/lib/Array.htm#Default "Default"} property, returns
     * `this.Default`. Else, throws an error.
     *
     * @throws {UnsetItemError} - "Value not found."
     */
    GetValueSparse(Value, Default?) {
        if this.FindSparse(Value, &outValue) {
            return outValue
        } else {
            if IsSet(Default) {
                return Default
            } else if HasProp(this, 'Default') {
                return this.Default
            } else {
                throw UnsetItemError('Value not found.')
            }
        }
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: no.
     *
     * Iterates the values in the container and compares the values to `Value`. If found, the function returns the index.
     *
     * @example
     * c := Container(
     *     { Name: "obj4" }
     *   , { Name: "obj1" }
     *   , { Name: "obj3" }
     *   , { Name: "obj2" }
     * )
     * OutputDebug(c.HasValue("obj1", (value) => value.Name) '`n') ; 2
     * OutputDebug(c.HasValue("obj5", (value) => value.Name) '`n') ; 0
     * @
     *
     * @param {*} Value - The value to find.
     *
     * @param {*} [Callback] - A `Func` or callable object that is called for each value in the container.
     *
     * Parameters:
     * 1. The current value.
     *
     * Returns the value to compare with `Value`.
     *
     * @returns {Integer} - If `Value` is found, the index. Else, 0.
     */
    HasValue(Value, Callback?) {
        if IsSet(Callback) {
            loop this.Length {
                if Callback(this[A_Index]) = Value {
                    return A_Index
                }
            }
        } else {
            loop this.Length {
                if this[A_Index] = Value {
                    return A_Index
                }
            }
        }
        return 0
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * Iterates the values in the container and compares the values to `Value`. If found, the function returns the index.
     *
     * @example
     * c := Container(
     *     { Name: "obj4" }
     *   ,
     *   ,
     *   , { Name: "obj2" }
     * )
     * OutputDebug(c.HasValueSparse("obj1", (value) => value.Name) '`n') ; 0
     * OutputDebug(c.HasValueSparse("obj2", (value) => value.Name) '`n') ; 4
     * @
     *
     * @param {*} Value - The value to find.
     *
     * @param {*} Callback - A `Func` or callable object that is called for each value in the container.
     *
     * Parameters:
     * 1. The current value.
     *
     * Returns the value to compare with `Value`.
     *
     * @returns {Integer} - If `Value` is found, the index. Else, 0.
     */
    HasValueSparse(Value, Callback?) {
        if IsSet(Callback) {
            loop this.Length {
                if this.Has(A_Index) && Callback(this[A_Index]) = Value {
                    return A_Index
                }
            }
        } else {
            loop this.Length {
                if this.Has(A_Index) && this[A_Index] = Value {
                    return A_Index
                }
            }
        }
        return 0
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts a value in order.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    Insert(Value) {
        if this.Length {
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
        } else {
            this.Push(Value)
            return 1
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts a value in order if the value does not exist in the container.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    InsertIfAbsent(Value) {
        if this.Length {
            if index := this.FindInequality(Value, , '>=') {
                ; If `Value` is not equivalent with the value at `index`
                if this.Compare(Value, index) {
                    this.InsertAt(index, Value)
                    return index
                }
            } else if this.Compare(Value, 1) < 0 {
                this.InsertAt(1, Value)
                return 1
            } else {
                this.Push(Value)
                return this.Length
            }
        } else {
            this.Push(Value)
            return 1
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts a value in order if the value does not exist in the container.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    InsertIfAbsentSparse(Value) {
        if this.Length {
            if index := this.FindInequalitySparse(Value, , '>=') {
                ; If `Value` is not equivalent with the value at `index`
                if this.Compare(Value, index) {
                    ; If there is an unset index to the left, fill it in
                    if !this.Has(index - 1) && index > 1 {
                        this[index - 1] := Value
                        return index - 1
                    } else {
                        this.InsertAt(index, Value)
                        return index
                    }
                }
            } else {
                i := 1
                while !this.Has(i) && i < this.Length {
                    ++i
                }
                ; If all indices are unset
                if !this.Has(i) {
                    this[1] := Value
                    return
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
        } else {
            this.Push(Value)
            return 1
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Inserts values in order.
     *
     * @param {*} Values - One or more values to insert.
     */
    InsertList(Values) {
        if Values is Array {
            for value in Values {
                this.Insert(value)
            }
        } else {
            this.Insert(Values)
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts values in order.
     *
     * @param {*} Values - One or more values to insert.
     */
    InsertListSparse(Values) {
        if Values is Array {
            loop Values.Length {
                if Values.Has(A_Index) {
                    this.InsertSparse(Values[A_Index])
                }
            }
        } else {
            this.InsertSparse(Values)
        }
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Inserts a value in order.
     *
     * @param {*} Value - The value.
     *
     * @returns {Integer} - The index at which it was inserted.
     */
    InsertSparse(Value) {
        if this.Length {
            if index := this.FindInequalitySparse(Value, , '>') {
                ; If there is an unset index to the left, fill it in
                if !this.Has(index - 1) && index > 1 {
                    this[index - 1] := Value
                    return index - 1
                } else {
                    this.InsertAt(index, Value)
                    return index
                }
            } else {
                i := 1
                while !this.Has(i) && i < this.Length {
                    ++i
                }
                ; If all indices are unset
                if !this.Has(i) {
                    this[1] := Value
                    return
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
        } else {
            this.Push(Value)
            return 1
        }
    }
    /**
     * Requires a sorted container: no.
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_DATEVALUE:
                Compare1 := _CompareDateValue1
                Compare2 := _CompareDateValue2
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

        _CompareDateValue1(a, b) => a.__Container_DateValue - b.__Container_DateValue
        _CompareNumber1(a, b) => a - b
        _CompareString1(a, b) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber1(a, b) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString1(a, b) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue1(a, b) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue1(a, b) => Callbackcompare(a, b)
        _CompareDateValue2(a) => a.__Container_DateValue - b.__Container_DateValue
        _CompareNumber2(a) => a - b
        _CompareString2(a) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber2(a) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString2(a) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue2(a) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue2(a) => Callbackcompare(a, b)
    }
    /**
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * @param {*} [CallbackObject = (value) => "{ " Type(value) " }"] - A `Func` or callable object
     * which accepts the object as an argument and returns the substring to add to the result string.
     *
     * @returns {String} - The string.
     */
    JoinEx(Delimiter := ', ', UnsetItem := '""', CallbackObject := (value) => '{ ' Type(value) ' }') {
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
     *
     * Allows unset indices: yes.
     *
     * This is similar to `Array.Prototype.Push`, except:
     * - It is not variadic, but you can pass an array of items to `Value`.
     * - It returns the container, allowing {@link Container.Prototype.PushEx} to be chained
     *   with other functions.
     *
     * @example
     * c := Container(1, 2, 3)
     * c2 := Container(4, 5, 6)
     * c3 := Container(7, 8, 9)
     * c.PushEx(c2.PushEx(c3.PushEx([10, 11, 12])))
     * OutputDebug(c.Join() '`n') ; 1, 2, 3, 4, 5, ...
     * @
     *
     * @param {*} Value - The value(s) to add to the container. Is `Value` inherits from `Array`,
     * the values contained in the array are added to the container, not `Value` itself. To add
     * a value that inherits from `Array` as-is, pass the value nested in another array.
     * @example
     * c := Container(1, 2, 3)
     * arr := [ 4, 5, 6 ]
     * c.PushEx([ arr ])
     * @
     */
    PushEx(Value) {
        if Value is Array {
            this.Push(Value*)
        } else {
            this.Push(Value)
        }
        return this
    }
    /**
     * Requires a sorted container: no.
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_DATEVALUE:
                Compare1 := _CompareDateValue1
                Compare2 := _CompareDateValue2
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

        _CompareDateValue1(a, b) => a.__Container_DateValue - b.__Container_DateValue
        _CompareNumber1(a, b) => a - b
        _CompareString1(a, b) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber1(a, b) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString1(a, b) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue1(a, b) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue1(a, b) => Callbackcompare(a, b)
        _CompareDateValue2(a) => a.__Container_DateValue - b.__Container_DateValue
        _CompareNumber2(a) => a - b
        _CompareString2(a) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber2(a) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString2(a) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue2(a) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue2(a) => Callbackcompare(a, b)
        _MakeResult(c) {
            ObjSetBase(c, this.Base)
            for prop in this.OwnProps() {
                c.DefineProp(prop, this.GetOwnPropDesc(prop))
            }
            return c
        }
    }
    /**
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: yes.
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
     * Requires a sorted container: yes.
     *
     * Allows unset indices: no.
     *
     * Calls {@link Container.Prototype.FindAll} to find a value in the container. If the
     * value is found, removes each instance of the value.
     *
     * @param {*} Value - The value to find and remove.
     *
     * @param {VarRef} [OutList] - A variable that will receive a {@link Container} containing
     * the removed values. The {@link Container} is created by calling {@link Container.Prototype.Copy}.
     * You must set the variable with a nonzero value before calling {@link Container.Prototype.RemoveAll}
     * to direct the function to collect the values.
     *
     * @example
     * ; Assume `c` is a correctly prepared `Container`.
     * index := c.RemoveAll(1000, &list := true)
     * for v in list {
     *     ; do something
     * }
     * @
     *
     * @returns {Integer} - If the value is found, the first index from left-to-right where the value
     * was located. Else, 0.
     */
    RemoveAll(Value, &OutList?) {
        if index := this.FindAll(Value, &lastIndex) {
            i := index - 1
            if IsSet(OutList) && OutList {
                OutList := this.Copy()
                loop lastIndex - i {
                    OutList.Push(this.RemoveAt(i))
                }
            } else {
                loop lastIndex - i {
                    this.RemoveAt(i)
                }
            }
            return index
        }
        return 0
    }
    /**
     * Requires a sorted container: yes.
     *
     * Allows unset indices: yes.
     *
     * Calls {@link Container.Prototype.FindAllSparse} to find a value in the container. If the
     * value is found, removes each instance of the value.
     *
     * @param {*} Value - The value to find and remove.
     *
     * @param {VarRef} [OutList] - A variable that will receive a {@link Container} containing
     * the removed values. The {@link Container} is created by calling {@link Container.Prototype.Copy}.
     * You must set the variable with a nonzero value before calling
     * {@link Container.Prototype.RemoveAllSparse} to direct the function to collect the values.
     *
     * @example
     * ; Assume `c` is a correctly prepared `Container`.
     * index := c.RemoveAllSparse(1000, &list := true)
     * for v in list {
     *     ; do something
     * }
     * @
     *
     * @returns {Integer} - If the value is found, the first index from left-to-right where the value
     * was located. Else, 0.
     */
    RemoveAllSparse(Value, &OutList?) {
        if index := this.FindAllSparse(Value, &lastIndex) {
            i := index - 1
            if IsSet(OutList) && OutList {
                OutList := this.Copy()
                loop lastIndex - i {
                    if this.Has(++i) {
                        OutList.Push(this.RemoveAt(i--))
                    }
                }
            } else {
                loop lastIndex - i {
                    if this.Has(++i) {
                        this.RemoveAt(i--)
                    }
                }
            }
            return index
        }
        return 0
    }
    /**
     * Requires a sorted container: yes.
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
     * Requires a sorted container: yes.
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
     * Requires a sorted container: yes.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
     * {@link Container#CallbackCompare}.
     *
     * @param {*} CallbackCompare - The callback to use as a comparator for sorting operations.
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
    SetCallbackCompare(CallbackCompare) {
        this.CallbackCompare := CallbackCompare
    }
    /**
     * Defines the function used to associate a value in the container with a value used for
     * sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.Name
     * }
     *
     * c := Container(
     *     { Name: "obj4" }
     *   , { Name: "obj1" }
     *   , { Name: "obj3" }
     *   , { Name: "obj2" }
     * )
     * c.SetCallbackValue(CallbackValue)
     * @
     *
     * @param {*} CallbackValue - The function that returns the sort value from items in the container.
     *
     * Parameters:
     * 1. A value to be compared.
     *
     * Returns:
     * The value used for sorting.
     */
    SetCallbackValue(CallbackValue) {
        this.CallbackValue := CallbackValue
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     */
    SetCompareStringEx(LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0) {
        if !IsNumber(LocaleName) {
            buf := this.CompareStringLocaleName := Buffer(StrPut(LocaleName, CONTAINER_DEFAULT_ENCODING))
            StrPut(LocaleName, Buf, CONTAINER_DEFAULT_ENCODING)
            LocaleName := buf.Ptr
        }
        if IsObject(NlsVersionInfo) {
            this.CompareStringNlsVersionInfo := NlsVersionInfo
            NlsVersionInfo := NlsVersionInfo.Ptr
        }
        this.CallbackCompare := Container_CompareStringEx.Bind(LocaleName, Flags, NlsVersionInfo)
    }
    /**
     * Defines the comparator for string date operations. This is only valid when dates are formatted
     * as yyyyMMddHHmmss time strings. The entire time string is not necessary, the minimum is
     * just the year, but the values must be in that order and values cannot be skipped.
     *
     * This sets the property {@link Container#CallbackCompare} with the comparator.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     */
    SetCompareDate(UseCompareDateEx := false) {
        this.CallbackCompare := UseCompareDateEx ? Container_CompareDateEx : Container_CompareDate
    }
    /**
     * Defines the comparator for date sort operations. This permits sorting dates with any format
     * of date string that can be interpeted using {@link Container_Date}. This requires that the
     * file Container_Date.ahk is included with an `#include` statement, which is already
     * included at the top of Container.ahk.
     *
     * For details about {@link Container_Date}, see Container_Date.ahk.
     *
     * {@link Container.Prototype.SetCompareDateStr} calls {@link Container.Prototype.SetDateParser}.
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with a function that compares dates using a custom operation which will perform more slowly
     * but is not subject to the same limitation as {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container#CallbackCompare} is set with a function that uses
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff} which will perform more
     * quickly but cannot handle dates prior to year 1601.
     */
    SetCompareDateStr(DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false) {
        this.SetDateParser(Container_DateParser(DateFormat, RegExOptions), Century ?? unset)
    }
    /**
     * This method is called by {@link Container.Prototype.SetCompareDateStr}, but if you already
     * have an instance of {@link Container_DateParser} to use, you can call
     * {@link Container.Prototype.SetDateParser} directly.
     *
     * Defines the comparator for date sort operations. This permits sorting dates with any format
     * of date string that can be interpeted using {@link Container_Date}. See the description
     * above {@link Container.Prototype.SetCompareDateStr} for more info.
     *
     * Sets three properties, {@link Container#__DateParser}, {@link Container#CallbackCompare}
     * and {@link Container#CallbackCompareValue}.
     *
     * For details about {@link Container_Date}, see the Container_Date.ahk.
     *
     * @param {Container_DateParser} DateParserObj - The {@link Container_DateParser}.
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with a function that compares dates using a custom operation which will perform more slowly
     * but is not subject to the same limitation as {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container#CallbackCompare} is set with a function that uses
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff} which will perform more
     * quickly but cannot handle dates prior to year 1601.
     */
    SetDateParser(DateParserObj, Century?, UseCompareDateEx := false) {
        this.__DateParser := DateParserObj
        if IsSet(Century) {
            if UseCompareDateEx {
                this.CallbackCompare := Container_CompareDateStr_CenturyEx.Bind(DateParserObj, Century)
                this.CallbackCompareValue := Container_CompareDateStr_Century_CompareValueEx.Bind(DateParserObj, Century)
            } else {
                this.CallbackCompare := Container_CompareDateStr_Century.Bind(DateParserObj, Century)
                this.CallbackCompareValue := Container_CompareDateStr_Century_CompareValue.Bind(DateParserObj, Century)
            }
            this.CompareDateCentury := Century
        } else {
            if UseCompareDateEx {
                this.CallbackCompare := Container_CompareDateStrEx.Bind(DateParserObj)
                this.CallbackCompareValue := Container_CompareDateStr_CompareValueEx.Bind(DateParserObj)
            } else {
                this.CallbackCompare := Container_CompareDateStr.Bind(DateParserObj)
                this.CallbackCompareValue := Container_CompareDateStr_CompareValue.Bind(DateParserObj)
            }
        }
    }
    /**
     * Sets the sort type.
     *
     * ### CONTAINER_SORTTYPE_CB_DATE
     *
     * CallbackValue is provided by your code and returns a string in the format yyyyMMddHHmmss.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareDate}.
     *
     * @example
     * c := Container(
     *     { timestamp: '20250312122930' }
     *   , { timestamp: '20250411122900' }
     *   , { timestamp: '20251015091805' }
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_CB_DATE)
     * c.SetCallbackValue((value) => value.timestamp)
     * c.SetCompareDate()
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_CB_DATESTR
     *
     * CallbackValue is provided by your code and returns a date string in any format recognized
     * by {@link Container_DateParser}.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareDateStr} or
     * {@link Container.Prototype.SetDateParser}.
     *
     * @example
     * c := Container(
     *     { date: '2025-03-12 12:29:30' }
     *   , { date: '2025-04-11 12:29:00' }
     *   , { date: '2025-10-15 09:18:05' }
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
     * c.SetCallbackValue((value) => value.date)
     * c.SetCompareDateStr('yyyy-MM-dd HH:mm:ss')
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_CB_NUMBER
     *
     * CallbackValue is provided by your code and returns a number.
     *
     * CallbackCompare is not used.
     *
     * @example
     * c := Container(
     *     { value: 298581 }
     *   , { value: 195801 }
     *   , { value: 585929 }
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_CB_NUMBER)
     * c.SetCallbackValue((value) => value.value)
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_CB_STRING
     *
     * CallbackValue is provided by your code and returns a string.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * c := Container(
     *     { name: 'obj4' }
     *   , { name: 'obj3' }
     *   , { name: 'obj1' }
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_CB_STRING)
     * c.SetCallbackValue((value) => value.name)
     * c.SetCompareStringEx()
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_CB_STRINGPTR
     *
     * CallbackValue is provided by your code and returns a pointer to a null-terminated string.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * class SomeStruct {
     *     static __New() {
     *         this.DeleteProp('__New')
     *         proto := this.Prototype
     *         proto.CbSize := 16 ; arbitrary size for example
     *         proto.__pszText_offset := 8 ; arbitrary offset for example
     *     }
     *     __New(pszText) {
     *         this.Buffer := Buffer(this.cbSize)
     *         this.__pszText := Buffer(StrPut(pszText, 'cp1200'))
     *         StrPut(pszText, this.__pszText, 'cp1200')
     *         NumPut('ptr', this.__pszText.Ptr, this, this.__pszText_offset)
     *     }
     *     pszText {
     *         Get => StrGet(this.__pszText, 'cp1200')
     *         Set {
     *             bytes := StrPut(Value, 'cp1200')
     *             if bytes > this.__pszText.Size {
     *                 this.__pszText.Size := bytes
     *                 NumPut('ptr', this.__pszText.Ptr, this, this.__pszText_offset)
     *             }
     *             StrPut(Value, this.__pszText, 'cp1200')
     *         }
     *     }
     *     Ptr => this.Buffer.Ptr
     *     Size => this.Buffer.Size
     * }
     *
     * c := Container(
     *     SomeStruct("obj4")
     *   , SomeStruct("obj3")
     *   , SomeStruct("obj1")
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_CB_STRINGPTR)
     * c.SetCallbackValue((value) => value.__pszText.Ptr)
     * c.SetCompareStringEx()
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_DATE
     *
     * CallbackValue is not used.
     *
     * Values in the container are date strings in the format yyyyMMddHHmmss.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareDate}.
     *
     * @example
     * c := Container(
     *     '20250312122930'
     *   , '20250411122900'
     *   , '20251015091805'
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_DATE)
     * c.SetCompareDate()
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_DATESTR
     *
     * CallbackValue is not used.
     *
     * Values in the container are date string in any format recognized by {@link Container_DateParser}.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareDateStr} or
     * {@link Container.Prototype.SetDateParser}.
     *
     * @example
     * c := Container(
     *     '2025-03-12 12:29:30'
     *   , '2025-04-11 12:29:00'
     *   , '2025-10-15 09:18:05'
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_DATESTR)
     * c.SetCompareDateStr('yyyy-MM-dd HH:mm:ss')
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_DATEVALUE
     *
     * Your code does not assign this sort type directly. See {@link Container.Prototype.DatePreprocess}
     * for details about this sort type.
     *
     * ### CONTAINER_SORTTYPE_MISC
     *
     * CallbackValue is not used.
     *
     * CallbackCompare is provided by your code and implements custom logic to return the comparison
     * value.
     *
     * @example
     * c := Container(
     *     { id: 'CFikHajB' }
     *   , { id: 'zhLAlxeK' }
     *   , { id: 'RwaedOSw' }
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_MISC)
     * c.SetCallbackCompare(MyCallbackCompare)
     * MyCallbackCompare(value1, value2) {
     *     ; Implements some logic and returns a number indicating the relationship of the two values
     * }
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_NUMBER
     *
     * CallbackValue is not used.
     *
     * Values in the container are numbers.
     *
     * CallbackCompare is not used.
     *
     * @example
     * c := Container(
     *     298581
     *   , 195801
     *   , 585929
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_NUMBER)
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_STRING
     *
     * CallbackValue is not used.
     *
     * Values in the container are strings.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * c := Container(
     *     'string4'
     *   , 'string3'
     *   , 'string1'
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_STRING)
     * c.SetCompareStringEx()
     * c.Sort()
     * @
     *
     * ### CONTAINER_SORTTYPE_STRINGPTR
     *
     * CallbackValue is not used.
     *
     * Values in the container are pointers to null-terminated strings.
     *
     * Set CallbackCompare by calling {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * buf1 := StrBuf('string4')
     * buf2 := StrBuf('string3')
     * buf3 := StrBuf('string1')
     * c := Container(
     *     buf1.Ptr
     *   , buf2.Ptr
     *   , buf3.Ptr
     * )
     * c.SetSortType(CONTAINER_SORTTYPE_STRINGPTR)
     * c.SetCompareStringEx()
     * c.Sort()
     *
     * StrBuf(str) {
     *     buf := Buffer(StrPut(str, 'cp1200'))
     *     StrPut(str, buf, 'cp1200')
     *     return buf
     * }
     * @
     *
     * @throws {ValueError} - "Invalid SortType."
     */
    SetSortType(Value) {
        switch Value, 0 {
            case CONTAINER_SORTTYPE_CB_DATE
              , CONTAINER_SORTTYPE_CB_DATESTR
              , CONTAINER_SORTTYPE_MISC
              , CONTAINER_SORTTYPE_CB_NUMBER
              , CONTAINER_SORTTYPE_CB_STRING
              , CONTAINER_SORTTYPE_CB_STRINGPTR
              , CONTAINER_SORTTYPE_DATE
              , CONTAINER_SORTTYPE_DATESTR
              , CONTAINER_SORTTYPE_NUMBER
              , CONTAINER_SORTTYPE_STRING
              , CONTAINER_SORTTYPE_STRINGPTR
              , CONTAINER_SORTTYPE_DATEVALUE:
                this.SortType := Value
            default: throw ValueError('Invalid SortType.', -1, Value)
        }
    }
    /**
     * Requires a sorted container: no.
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
     * Requires a sorted container: no.
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
            case CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR:
                CallbackCompare := this.CallbackCompare
                Compare1 := _CompareValue1
                Compare2 := _CompareValue2
            case CONTAINER_SORTTYPE_DATEVALUE:
                Compare1 := _CompareDateValue1
                Compare2 := _CompareDateValue2
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

        _CompareDateValue1(a, b) => a.__Container_DateValue - b.__Container_DateValue
        _CompareNumber1(a, b) => a - b
        _CompareString1(a, b) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber1(a, b) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString1(a, b) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue1(a, b) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue1(a, b) => Callbackcompare(a, b)
        _CompareDateValue2(a) => a.__Container_DateValue - b.__Container_DateValue
        _CompareNumber2(a) => a - b
        _CompareString2(a) => CallbackCompare(StrPtr(a), StrPtr(b))
        _CompareCbNumber2(a) => CallbackValue(a) - CallbackValue(b)
        _CompareCbString2(a) => CallbackCompare(StrPtr(CallbackValue(a)), StrPtr(CallbackValue(b)))
        _CompareCbValue2(a) => CallbackCompare(CallbackValue(a), CallbackValue(b))
        _CompareValue2(a) => Callbackcompare(a, b)
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a string in the format yyyyMMddHHmmss.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDate}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.timestamp
     * }
     *
     * c := Container(
     *     { timestamp: "20250312122930" }
     *   , { timestamp: "20250411122900" }
     *   , { timestamp: "20251015091805" }
     * )
     *
     * c.ToCbDate(CallbackValue)
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToCbDate(CallbackValue, UseCompareDateEx := false, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_CB_DATE)
        this.SetCallbackValue(CallbackValue)
        this.SetCompareDate(UseCompareDateEx)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized by the
     * {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDateStr}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * c := Container(
     *     { date: "2025-03-12 12:29:30" }
     *   , { date: "2025-04-11 12:29:00" }
     *   , { date: "2025-10-15 09:18:05" }
     * )
     *
     * c.ToCbDateStr(CallbackValue, "yyyy-MM-dd HH:mm:ss")
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToCbDateStr(CallbackValue, DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
        this.SetCallbackValue(CallbackValue)
        this.SetCompareDateStr(DateFormat, RegExOptions, Century ?? unset, UseCompareDateEx)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized
     * by the {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetDateParser}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * c := Container(
     *     { date: "2025-03-12 12:29:30" }
     *   , { date: "2025-04-11 12:29:00" }
     *   , { date: "2025-10-15 09:18:05" }
     * )
     *
     * dateParser := Container_DateParser("yyyy-MM-dd HH:mm:ss")
     * c.ToCbDateStrFromParser(CallbackValue, dateParser)
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {Container_DateParser} DateParserObj - The {@link Container_DateParser}.
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateStr} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToCbDateStrFromParser(CallbackValue, DateParser, Century?, UseCompareDateEx := false, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_CB_DATESTR)
        this.SetCallbackValue(CallbackValue)
        this.SetDateParser(DateParser, Century ?? unset, UseCompareDateEx)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a number.
     * - **CallbackCompare**: Not used.
     *
     * @example
     * CallbackValue(value) {
     *     return value.value
     * }
     *
     * c := Container(
     *     { value: 298581 }
     *   , { value: 195801 }
     *   , { value: 585929 }
     * )
     *
     * c.ToCbNumber(CallbackValue)
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToCbNumber(CallbackValue, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_CB_NUMBER)
        this.SetCallbackValue(CallbackValue)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a string.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.name
     * }
     *
     * c := Container(
     *     { name: "obj4" }
     *   , { name: "obj3" }
     *   , { name: "obj1" }
     * )
     *
     * c.ToCbString(CallbackValue)
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToCbString(CallbackValue, LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_CB_STRING)
        this.SetCallbackValue(CallbackValue)
        this.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a pointer to a null-terminated string.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * If you know your code will be used for a lot of sorting and finding operations, you can
     * improve performance by storing the name / key in a buffer.
     *
     * @example
     * class ImageSamples {
     *     __New(Name, ImageData) {
     *         this.NameBuffer := Buffer(StrPut(Name, "cp1200"))
     *         StrPut(Name, this.NameBuffer, "cp1200")
     *         this.ImageData := ImageData
     *     }
     *     Name => StrGet(this.NameBuffer, "cp1200")
     * }
     *
     * CallbackValue(value) {
     *     return value.NameBuffer.Ptr
     * }
     *
     * c := Container(
     *     ImageSamples("obj4", data4)
     *   , ImageSamples("obj3", data3)
     *   , ImageSamples("obj1", data1)
     * )
     *
     * c.ToCbStringPtr(CallbackValue)
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToCbStringPtr(CallbackValue, LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_CB_STRINGPTR)
        this.SetCallbackValue(CallbackValue)
        this.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return this
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDate}.
     *
     * @example
     * c := Container(
     *     "20250312122930"
     *   , "20250411122900"
     *   , "20251015091805"
     * )
     *
     * c.ToDate()
     * @
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToDate(UseCompareDateEx := false, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_DATE)
        this.SetCompareDate(UseCompareDateEx)
        return this
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareDateStr}.
     *
     * @example
     * c := Container(
     *     "2025-03-12 12:29:30"
     *   , "2025-04-11 12:29:00"
     *   , "2025-10-15 09:18:05"
     * )
     *
     * c.ToDateStr("yyyy-MM-dd HH:mm:ss")
     * @
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToDateStr(DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_DATESTR)
        this.SetCompareDateStr(DateFormat, RegExOptions, Century ?? unset, UseCompareDateEx)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized
     * by the {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetDateParser}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * c := Container(
     *     "2025-03-12 12:29:30"
     *   , "2025-04-11 12:29:00"
     *   , "2025-10-15 09:18:05"
     * )
     *
     * dateParser := Container_DateParser("yyyy-MM-dd HH:mm:ss")
     * c.ToDateStrFromParser(dateParser)
     * @
     *
     * @param {Container_DateParser} DateParserObj - The {@link Container_DateParser}.
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateStr} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToDateStrFromParser(DateParser, Century?, UseCompareDateEx := false, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_DATESTR)
        this.SetDateParser(DateParser, Century ?? unset, UseCompareDateEx)
        return this
    }
    /**
     * - **CallbackValue**: Provided by your code and returns a date string in any format recognized
     * by the {@link Container_DateParser} set to {@link Container#DateParser}.
     * - **CallbackCompare**: This calls {@link Container.Prototype.DatePreprocess}.
     *
     * @example
     * CallbackValue(value) {
     *     return value.date
     * }
     *
     * c := Container(
     *     { date: "2025-03-12 12:29:30" }
     *   , { date: "2025-04-11 12:29:00" }
     *   , { date: "2025-10-15 09:18:05" }
     * )
     * c.ToDateValue(CallbackValue, "yyyy-MM-dd HH:mm:ss")
     * @
     *
     * @param {*} CallbackValue - Defines the function used to associate a value in the container
     * with a value used for sorting. Sets the function to property {@link Container#CallbackValue}.
     *
     * @param {String} DateFormat - The format string that {@link Container_Date} uses to parse
     * date strings into usable date values.
     *
     * @param {String} [RegExOptions = ""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     *
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used. If the date strings have 4-digit years, this option is ignored.
     * Sets property {@link Container#CompareDateCentury}.
     *
     * Note that you must call {@link Container.Prototype.SetDateParser} or {@link Container.Prototype.SetCompareDateStr}
     * to change the value of property {@link Container#CompareDateCentury}; changing the value directly
     * will cause unexpected behavior.
     *
     * @param {Boolean} [UseCompareDateEx = false] - If true, sets {@link Container#CallbackCompare}
     * with {@link Container_CompareDateEx}, which will perform more slowly but is not subject
     * to the same limitation as {@link Container_CompareDate} because {@link Container_CompareDateEx}
     * does not use {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm DateDiff}.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm#Remarks DateDiff} has the following
     * limitation: "If DateTime contains an invalid timestamp or a year prior to 1601, a ValueError
     * is thrown."
     *
     * If false, {@link Container_CompareDateEx} is used which will perform more quickly but cannot
     * handle dates prior to year 1601.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToDateValue(CallbackValue, DateFormat, RegExOptions := '', Century?, UseCompareDateEx := false, PropertyName := '__Container_DateValue', Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.ToCbDateStr(CallbackValue, DateFormat, RegExOptions, Century ?? unset, UseCompareDateEx)
        this.DatePreprocess(, , PropertyName)
        return this
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: Provided by your code and implements custom logic to return the comparison
     * value.
     *
     * @example
     * CallbackCompare(value1, value2) {
     *     ; Implements some logic and returns a number
     *     ; indicating the relationship of the two values
     * }
     *
     * c := Container(
     *     { id: "CFikHajB" }
     *   , { id: "zhLAlxeK" }
     *   , { id: "RwaedOSw" }
     * )
     *
     * c.ToMisc(CallbackCompare)
     * @
     *
     * @param {*} CallbackCompare - The callback to use as a comparator for sorting operations. Sets
     * the property {@link Container#CallbackCompare}.
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
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToMisc(CallbackCompare, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_MISC)
        this.SetCallbackCompare(CallbackCompare)
        return this
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: Not used.
     *
     * @example
     * c := Container(
     *     298581
     *   , 195801
     *   , 585929
     * )
     *
     * c.ToNumber()
     * @
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToNumber(Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_NUMBER)
        return this
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * c := Container(
     *     "string4"
     *   , "string3"
     *   , "string1"
     * )
     *
     * c.ToString()
     * @
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToString(LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_STRING)
        this.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return this
    }
    /**
     * - **CallbackValue**: Not used.
     * - **CallbackCompare**: This calls {@link Container.Prototype.SetCompareStringEx}.
     *
     * @example
     * StrBuf(str) {
     *     buf := Buffer(StrPut(str, "cp1200"))
     *     StrPut(str, buf, "cp1200")
     *     return buf
     * }
     *
     * buf1 := StrBuf("string4")
     * buf2 := StrBuf("string3")
     * buf3 := StrBuf("string1")
     *
     * c := Container(
     *     buf1.Ptr
     *   , buf2.Ptr
     *   , buf3.Ptr
     * )
     *
     * c.ToStringPtr()
     * @
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
     * @param {Integer|NlsVersionInfoEx|Buffer} [NlsVersionInfo = 0] - Either a pointer to a
     * NLSVERSIONINFOEX structure, or an {@link NlsVersionInfoEx} object, or a buffer containing an
     * NLSVERSIONINFOEX structure. If `NlsVersionInfo` is an object, the object is set to
     * property {@link Container#CompareStringNlsVersionInfo}.
     *
     * @param {...*} [Values] - Zero or more values to instantiate the container with.
     *
     * @returns {Container}
     */
    ToStringPtr(LocaleName := LOCALE_NAME_USER_DEFAULT, Flags := 0, NlsVersionInfo := 0, Values*) {
        if Values.Length {
            this.Push(Values*)
        }
        this.SetSortType(CONTAINER_SORTTYPE_STRINGPTR)
        this.SetCompareStringEx(LocaleName, Flags, NlsVersionInfo)
        return this
    }
    /**
     * Requires a sorted container: no.
     *
     * Allows unset indices: no.
     *
     * Compares every value (except the first) with the preceding value to verify that each is in
     * order.
     *
     * @param {Boolean} [InvertDirection = false] - If true, the sort order is inverted. The default
     * is ascending order.
     *
     * @throws {Error} - "Values out of order."
     * @throws {ValueError} - "Invalid SortType."
     */
    ValidateSort(InvertDirection := false) {
        condition := InvertDirection ? (n) => n < 0 : (n) => n > 0
        switch this.SortType, 0 {
            case CONTAINER_SORTTYPE_CB_DATE
            , CONTAINER_SORTTYPE_CB_DATESTR
            , CONTAINER_SORTTYPE_CB_STRINGPTR:
                callbackValue := this.CallbackValue
                callbackCompare := this.CallbackCompare
                loop this.Length - 1 {
                    if condition(callbackCompare(callbackValue(this[A_Index]), callbackValue(this[A_Index + 1]))) {
                        v1 := callbackValue(this[A_Index])
                        v2 := callbackValue(this[A_Index + 1])
                        _Throw(A_Index)
                    }
                }
            case CONTAINER_SORTTYPE_CB_STRING:
                callbackValue := this.CallbackValue
                callbackCompare := this.CallbackCompare
                loop this.Length - 1 {
                    if condition(callbackCompare(StrPtr(callbackValue(this[A_Index])), StrPtr(callbackValue(this[A_Index + 1])))) {
                        v1 := callbackValue(this[A_Index])
                        v2 := callbackValue(this[A_Index + 1])
                        _Throw(A_Index)
                    }
                }
            case CONTAINER_SORTTYPE_CB_NUMBER:
                callbackValue := this.CallbackValue
                loop this.Length - 1 {
                    if condition(callbackValue(this[A_Index]) - callbackValue(this[A_Index + 1])) {
                        v1 := callbackValue(this[A_Index])
                        v2 := callbackValue(this[A_Index + 1])
                        _Throw(A_Index)
                    }
                }
            case CONTAINER_SORTTYPE_DATEVALUE:
                loop this.Length - 1 {
                    if condition(this[A_Index].__Container_DateValue - this[A_Index + 1].__Container_DateValue) {
                        v1 := this[A_Index].__Container_DateValue
                        v2 := this[A_Index + 1].__Container_DateValue
                        _Throw(A_Index)
                    }
                }
            case CONTAINER_SORTTYPE_DATE
            , CONTAINER_SORTTYPE_DATESTR
            , CONTAINER_SORTTYPE_MISC
            , CONTAINER_SORTTYPE_STRINGPTR:
                callbackCompare := this.CallbackCompare
                loop this.Length - 1 {
                    if condition(callbackCompare(this[A_Index], this[A_Index + 1])) {
                        v1 := this[A_Index]
                        v2 := this[A_Index + 1]
                        _Throw(A_Index)
                    }
                }
            case CONTAINER_SORTTYPE_STRING:
                callbackCompare := this.CallbackCompare
                loop this.Length - 1 {
                    if condition(callbackCompare(StrPtr(this[A_Index]), StrPtr(this[A_Index + 1]))) {
                        v1 := this[A_Index]
                        v2 := this[A_Index + 1]
                        _Throw(A_Index)
                    }
                }
            case CONTAINER_SORTTYPE_NUMBER:
                loop this.Length - 1 {
                    if condition(this[A_Index] - this[A_Index + 1]) {
                        v1 := this[A_Index]
                        v2 := this[A_Index + 1]
                        _Throw(A_Index)
                    }
                }
            default: throw ValueError('Invalid SortType.', -1, this.SortType)
        }

        _Throw(i) {
            throw Error('Values out of order.', -1, 'Index: ' i ' - ' (i + 1))
        }
    }

    /**
     * @memberof Container
     * @instance
     * @type {Container_DateParser}
     */
    DateParser {
        Get => this.__DateParser
        Set => this.SetDateParser(Value)
    }
}
