
/*
    Original repository:
    Github: https://github.com/Nich-Cebolla/AutoHotkey-DateObj/blob/main/DateObj.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class Container_DateObj {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__Year := SubStr(A_Now, 1, 4)
        proto.__Month := '01'
        proto.__Day := '01'
        proto.__Hour := '00'
        proto.__Minute := '00'
        proto.__Second := '00'
        proto.Options := proto.Parser := ''
        proto.DefaultCentury := SubStr(A_Now, 1, 3)
        this.MonthDays := [
            31          ; 1
            ; standard, leap
          , [ 28, 29 ]  ; 2
          , 31          ; 3
          , 30          ; 4
          , 31          ; 5
          , 30          ; 6
          , 31          ; 7
          , 31          ; 8
          , 30          ; 9
          , 31          ; 10
          , 30          ; 11
          , 31          ; 12
        ]
        global Container_DateObj_SECONDS_IN_YEAR := 31536000
        , Container_DateObj_SECONDS_IN_LEAPYEAR := 31622400
    }

    /**
     * @description - Creates a {@link Container_DateObj} instance from a date string and date format string. The
     * parser is created in the process, and is available from the property `Container_DateObjInstance.Parser`.
     * @param {String} DateStr - The date string to parse.
     * @param {String} DateFormat - The format of the date string. The format follows the same rules as
     * described on the AHK `FormatTime` page: {@link https://www.autohotkey.com/docs/v2/lib/FormatTime.htm}.
     * - The format string can include any of the following units: 'y', 'M', 'd', 'H', 'h', 'm', 's', 't'.
     * See the link for details.
     * - Only numeric day units are recognized by this function. This function will not match with
     * days like 'Mon', 'Tuesday', etc.
     * - In addition to the units, RegEx is viable within the format string. To permit compatibility
     * between the unit characters and RegEx, please adhere to these guidelines:
     *   - If the format string contains one or more literal "y", "M", "d", "H", "h", "m", "s" or "t"
     * characters, you must escape the date format units using this escape: \t{...}
     * @example
     *  DateStr := '2024-01-28 19:15'
     *  DateFormat := 'yyyy-MM-dd HH:mm'
     *  Date := Container_DateObj(DateStr, DateFormat)
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute) ; 2024-01-28 19:15
     * @
     * @example
     *  DateStr := 'Voicemail From <1-555-555-5555> at 2024-01-28 07:15:20'
     *  DateFormat := 'at \t{yyyy-MM-dd HH:mm:ss}'
     *  Date := Container_DateObj(DateStr, DateFormat)
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute ':' Date.Second) ; 2024-01-28 07:15:20
     * @
     *
     *   - You can include multiple sets of \t escaped format units.
     * @example
     *  DateStr := 'Voicemail From <1-555-555-5555> Received January 28, 2024 at 12:15:20 AM'
     *  DateFormat := 'Received \t{MMMM dd, yyyy} at \t{hh:mm:ss tt}'
     *  Date := Container_DateObj(DateStr, DateFormat, 'i)') ; Use case insensitive matching when matching a month by name.
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute ':' Date.Second) ; 2024-01-28 00:15:20
     * @
     *
     *   - You can use the "?" quantifier.
     * @example
     *  DateStr1 := 'Voicemail From <1-555-555-5555> Received January 28, 2024 at 12:15 AM'
     *  DateStr2 := 'Voicemail From <1-555-555-5555> Received January 28, 2024 at 12:15:12 AM'
     *  DateFormat := 'Received \t{MMMM dd, yyyy} at \t{hh:mm:?ss? tt}'
     *  Date1 := Container_DateObj(DateStr1, DateFormat, 'i)') ; Use case insensitive matching when matching a month by name.
     *  Date2 := Container_DateObj(DateStr2, DateFormat, 'i)')
     *  MsgBox(Date1.Year '-' Date1.Month '-' Date1.Day ' ' Date1.Hour ':' Date1.Minute ':' Date1.Second) ; 2024-01-28 00:15:00
     *  Date2 := Container_DateObj(DateStr2, DateFormat)
     *  MsgBox(Date2.Year '-' Date2.Month '-' Date2.Day ' ' Date2.Hour ':' Date2.Minute ':' Date2.Second) ; 2024-01-28 00:15:12
     * @
     *
     *   - The match object is set to the property `Container_DateObjInstance.Match`. Include any extra subcapture
     * groups that you are interested in.
     * @example
     *  DateStr := 'The child was born May 2, 1990, the year of the horse'
     *  DateFormat := '\t{MMMM d, yyyy}, the year of the (?<animal>\w+)'
     *  Date := Container_DateObj(DateStr, DateFormat, 'i)') ; Use case insensitive matching when matching a month by name.
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute ':' Date.Second) ; 1990-05-02 00:00:00
     *  MsgBox(Date.Match['animal']) ; horse
     * @
     *
     * @param {String} [RegExOptions=""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     * @param {Boolean} [SubcaptureGroup=true] - When true, each \t escaped format group is captured
     * in an unnamed subcapture group. When false, the function does not include any additional
     * subcapture groups.
     * @param {Boolean} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used.
     * @param {Boolean} [Validate=false] - When true, the values of each property are validated
     * before the function completes. The values are validated numerically, and if any value exceeds
     * the maximum value for that property, an error is thrown. For example, if the month is greater
     * than 12 or the hour is greater than 24, an error is thrown.
     * @returns {Container_DateObj} - The {@link Container_DateObj} object.
     */
    static Call(DateStr, DateFormat, RegExOptions := '', SubcaptureGroup := true, Century?, Validate := false) {
        return Container_DateParser(DateFormat, RegExOptions, SubcaptureGroup)(DateStr, Century ?? unset, Validate)
    }

    /**
     * @description - Creates a {@link Container_DateObj} object from a timestamp string.
     * @param {String} [Timestamp] - The timestamp string from which to create the {@link Container_DateObj}
     * object. `Timestamp` should at least be 4 characters long containing the year. The rest is
     * optional. If unset, `A_Now` is used.
     * @returns {Container_DateObj} - The {@link Container_DateObj} object.
     */
    static FromTimestamp(Timestamp?) {
        if !IsSet(Timestamp) {
            Timestamp := A_Now
        }
        Date := {}
        ObjSetBase(Date, this.Prototype)
        Date.Set(Timestamp)
        return Date
    }

    /**
     * @description - Get the number of days in a month.
     * @param {Integer} Month - The month to get the number of days for.
     * @param {Integer} [Year] - The year to get the number of days for.
     * If not set, the current year is used.
     * @returns {Integer} - The number of days in the month.
     */
    static GetDayCount(Month, Year?) {
        if Month = 2 {
            n := this.IsLeapYear(Year ?? SubStr(A_Now, 1, 4)) + 1
            return this.MonthDays[2][n]
        } else {
            return this.MonthDays[Month]
        }
    }

    /**
     * @description - Returns the month index. Indices are 1-based. (January is 1).
     * @param {String} MonthStr - Three or more of the first characters of the month's name.
     * @param {Boolean} [TwoDigits = false] - When true, the return value is padded to always be 2 digits.
     * @returns {String} - The 1-based index.
     */
    static GetMonthIndex(MonthStr, TwoDigits := false) {
        if TwoDigits {
            switch SubStr(MonthStr, 1, 3), 0 {
                case 'jan': return '01'
                case 'feb': return '02'
                case 'mar': return '03'
                case 'apr': return '04'
                case 'may': return '05'
                case 'jun': return '06'
                case 'jul': return '07'
                case 'aug': return '08'
                case 'sep': return '09'
                case 'oct': return '10'
                case 'nov': return '11'
                case 'dec': return '12'
                default: _Throw()
            }
        } else {
            switch SubStr(MonthStr, 1, 3), 0 {
                case 'jan': return '1'
                case 'feb': return '2'
                case 'mar': return '3'
                case 'apr': return '4'
                case 'may': return '5'
                case 'jun': return '6'
                case 'jul': return '7'
                case 'aug': return '8'
                case 'sep': return '9'
                case 'oct': return '10'
                case 'nov': return '11'
                case 'dec': return '12'
                default: _Throw()
            }
        }
        _Throw() {
            throw ValueError('Unexpected value for ``MonthStr``.', -1, MonthStr)
        }
    }

    static GetSeconds(StartTimestamp, EndTimestamp) {
        start := Container_DateObj.FromTimestamp(StartTimestamp)
        end := Container_DateObj.FromTimestamp(EndTimestamp)
        if end.Year < start.Year || (start.Year = end.Year && end.YearSeconds < start.YearSeconds) {
            throw ValueError('``StartTimestamp`` must specify a time value earlier than ``EndTimestamp``.', -1)
        }
        if start.Year = end.Year {
            return end.YearSeconds - start.YearSeconds
        }
        ; Count leap years in (start.Year, end.Year)
        leapYears := this.LeapCountBetween(start.Year, end.Year)
        return start.SecondsRemainingInYear                                     ; remainder of start year
          + end.YearSeconds                                     ; elapsed in end year
          + (end.Year - start.Year - 1 - leapYears) * Container_DateObj_SECONDS_IN_YEAR   ; 365-day years
          + leapYears * Container_DateObj_SECONDS_IN_LEAPYEAR             ; 366-day years
    }

    static IsLeapYear(Year) => (!Mod(Year, 4) && (Mod(Year, 100) || !Mod(Year, 400))) ? 1 : 0

    /**
     * Returns the count of integers between `Year` and 0, excluding `Year`, that satisfy the
     * Gregorian leap rule.
     * @param {Integer} Year - The year.
     * @returns {Integer}
     */
    static LeapCountBefore(Year) {
        k := Year - 1
        return Floor(k / 4) - Floor(k / 100) + Floor(k / 400)
    }

    /**
     * Returns the count of integers between `StartYear` and `EndYear`, excluding both `StartYear`
     * and `EndYear`, that satisfy the Gregorian leap rule.
     * @param {Integer} Year - The year.
     */
    static LeapCountBetween(StartYear, EndYear) => Abs(this.LeapCountBefore(EndYear) - this.LeapCountBefore(StartYear + 1))

    /**
     * @description - Sets the default values that the date objects will use for the timestamp when
     * the value is absent.
     * @param {String|Integer} Value - The default value.
     * @param {String} Name - The name of the property. Specifically, one of the following: Year,
     * Month, Day, Hour, Minute, Second, Options.
     */
    static SetDefault(Value, Name) {
        if Name = 'Options' {
            this.Prototype.Options := Value
        } else if Name = 'Year' {
            this.Prototype.SetYear(Value)
        } else {
            this.Prototype.SetValue(Value, Name)
        }
    }
    /**
     * Sets the default century that is used when the {@link Container_DateObj#Year} property is updated with
     * a one- or two-digit year value. Though this property is referred to as "default century",
     * you can specify the decade in the default century value if you expect to work with
     * year values that are single digit. For example, if your code sets the default century to "199"
     * and then sets `Date.Year := 1`, the year value will be set as "1991".
     *
     * The default default century is the current year and decade, i.e. `SubStr(A_Now, 1, 3)`.
     *
     * If the default century includes the decade, if your code sets {@link Container_DateObj#Year} with a
     * two-digit value, the decade from the input value is used. For example, if your code sets
     * the default century to "199" and then sets `Date.Year := 04`, the year value will be set as
     * "1904".
     *
     * @param {String|Integer} Century - The new default century value as either a 2- or 3-character
     * value.
     */
    static SetDefaultCentury(Century) {
        this.Prototype.DefaultCentury := Century
    }

    /**
     * @description - Adds the time to this object's timestamp, modifying this object's time value.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm}
     * @param {Integer} Time - The amount of time to add, as an integer or floating-point number.
     * Specify a negative number to perform subtraction.
     * @param {String} TimeUnits - The meaning of the `Time` parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {String} - The new timestamp.
     */
    Add(Time, TimeUnits) => this.Set(DateAdd(this.Timestamp, Time, TimeUnits))

    /**
     * @description - Creates a new {@link Container_DateObj} by adding the time value to this object's
     * timestamp with {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm DateAdd}. Does
     * not modify this object's time value.
     * @param {Integer} Time - The amount of time to add, as an integer or floating-point number.
     * Specify a negative number to perform subtraction.
     * @param {String} TimeUnits - The meaning of the `Time` parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {Container_DateObj} - The new {@link Container_DateObj} object.
     */
    AddToNew(Time, TimeUnits) => Container_DateObj.FromTimestamp(DateAdd(this.Timestamp, Time, TimeUnits))

    /**
     * @description - Adds the time value to this object's timestamp with
     * {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm DateAdd} and returns the new
     * timestamp. Does not modify this object's time value.
     * @param {Integer} Time - The amount of time to add, as an integer or floating-point number.
     * Specify a negative number to perform subtraction.
     * @param {String} TimeUnits - The meaning of the `Time` parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {String} - The return value from {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm DateAdd}
     */
    AddToTimestamp(Time, TimeUnits) => DateAdd(this.Timestamp, Time, TimeUnits)

    /**
     * Calls `Container_DateObj.FromTimestamp(this.Timestamp)`, returning a new {@link Container_DateObj} with the same
     * time value.
     * @returns {Container_DateObj}
     */
    Clone() => Container_DateObj.FromTimestamp(this.Timestamp)

    /**
     * @description - Get the difference between two dates.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm}
     * @param {String} Unit - Units to measure the difference in. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @param {String} [Timestamp] - The timestamp to compare to. If not set, the current time is used.
     * @returns {Integer} - The difference between the two dates.
     */
    Diff(Unit, Timestamp?) => DateDiff(this.Timestamp, Timestamp ?? A_Now, Unit)

    Get(FormatStr?) => FormatTime(this.Timestamp ' ' this.Options, FormatStr ?? unset)

    /**
     * @description - Get the number of days in a month.
     * @param {Integer} Month - The month to get the number of days for.
     * @returns {Integer} - The number of days in the month.
     */
    GetDayCount(Month) => Container_DateObj.GetDayCount(Month, this.Year)

    /**
     * @description - Get the timestamp from the date object. You can pass default values to
     * any of the parameters. Also see {@link Container_DateObj.SetDefault}.
     * @param {String} [DefaultYear] - The default year to use if the year is not set.
     * @param {String} [DefaultMonth] - The default month to use if the month is not set.
     * @param {String} [DefaultDay] - The default day to use if the day is not set.
     * @param {String} [DefaultHour] - The default hour to use if the hour is not set.
     * @param {String} [DefaultMinute] - The default minute to use if the minute is not set.
     * @param {String} [DefaultSecond] - The default second to use if the second is not set.
     * @returns {String} - The timestamp.
     */
    GetTimestamp(DefaultYear?, DefaultMonth?, DefaultDay?, DefaultHour?, DefaultMinute?, DefaultSecond?) {
        return (
            (this.HasOwnProp('__Year') ? this.Year : DefaultYear ?? this.Year)
            (this.HasOwnProp('__Month') ? this.Month : DefaultMonth ?? this.Month)
            (this.HasOwnProp('__Day') ? this.Day : DefaultDay ?? this.Day)
            (this.HasOwnProp('__Hour') ? this.Hour : DefaultHour ?? this.Hour)
            (this.HasOwnProp('__Minute') ? this.Minute : DefaultMinute ?? this.Minute)
            (this.HasOwnProp('__Second') ? this.Second : DefaultSecond ?? this.Second)
        )
    }

    /**
     * @description - Adds options that get used when accessing any of the time format properties.
     * @param {String} Options - The options to use.
     * @see https://www.autohotkey.com/docs/v2/lib/FormatTime.htm#Additional_Options
     */
    Opt(Options) => this.Options := Options

    /**
     * Adjusts this object's time value using an input timestamp. The input timestamp does not need
     * to be the full 14 characters representing yyyyMMddHHmmss, but the meaning of the characters
     * are interpreted in that order. For example, passing "2004" to {@link Container_DateObj.Prototype.Set}
     * will only update the year to 2004. Passing "200403" will update the year to 2004 and the month
     * to 03. Passing "20040320" will update the year to 2004, the month to 03, and the day to 20.
     * @param {String|Integer} Timestamp - The new time value.
     * @returns {String} - This object's new timestamp.
     * @throws {ValueError} - "`Timestamp` must be at least 4 characters in length."
     */
    Set(Timestamp) {
        if StrLen(Timestamp) >= 4 {
            this.__Year := SubStr(Timestamp, 1, 4)
        } else {
            throw ValueError('``Timestamp`` must at least be 4 characters in length.', -1, Timestamp)
        }
        if StrLen(Timestamp) >= 6 {
            this.__Month := SubStr(Timestamp, 5, 2)
        }
        if StrLen(Timestamp) >= 8 {
            this.__Day := SubStr(Timestamp, 7, 2)
        }
        if StrLen(Timestamp) >= 10 {
            this.__Hour := SubStr(Timestamp, 9, 2)
        }
        if StrLen(Timestamp) >= 12 {
            this.__Minute := SubStr(Timestamp, 11, 2)
        }
        if StrLen(Timestamp) >= 14 {
            this.__Second := SubStr(Timestamp, 13, 2)
        }
        return this.Timestamp
    }
    /**
     * Updates the year value.
     * @param {String|Integer} Year - The year value
     * @returns {String} - The new timestamp
     * @throws {ValueError} - "The input `Year` is one digit, but the default century value is
     * less than three digits, so the correct year cannot be constructed."
     * @throws {ValueError} - "The input `Year` is two digits, but the default century value is
     * less than two digits, so the correct year cannot be constructed."
     * @throws {ValueError} - "Unexpected `Year`.". This occurs if the length of `Year` is not
     * 1, 2, or 4.
     */
    SetYear(Year) {
        switch StrLen(Year) {
            case 1:
                if StrLen(this.DefaultCentury) >= 3 {
                    this.DefineProp('__Year', { Value: this.DefaultCentury Year })
                } else {
                    ; If you get this error, see static method `Container_DateObj.SetDefaultCentury`.
                    throw ValueError('The input ``Year`` is one digit, but the default century'
                    ' value is less than three digits, so the correct year cannot be constructed.'
                    , -1, Year)
                }
            case 2:
                if StrLen(this.DefaultCentury) >= 2 {
                    this.DefineProp('__Year', { Value: SubStr(this.DefaultCentury, 1, 2) Year })
                } else {
                    ; If you get this error, see static method `Container_DateObj.SetDefaultCentury`.
                    throw ValueError('The input ``Year`` is two digits, but the default century'
                    ' value is less than two digits, so the correct year cannot be constructed.'
                    , -1, Year)
                }
            case 4:
                this.DefineProp('__Year', { Value: Year })
            default: throw ValueError('Unexpected ``Year``.', -1, Year)
        }
        return this.Timestamp
    }
    /**
     * Updates a time value, padding the value with a "0" if the input `Value` is 1 character.
     * @param {String|Integer} Value - The new value.
     * @param {String} Unit - The meaning of `Value`.
     * @returns {String} - The new timestamp.
     */
    SetValue(Value, Unit) {
        this.DefineProp('__' Unit, { Value: StrLen(Value) == 1 ? '0' Value : Value })
        return this.Timestamp
    }

    /**
     * @description - Enables the ability to get a numeric value by adding 'N' to the front of a
     * property name.
     * @example
     *  Date := Container_DateObj('2024-01-28 19:15', 'yyyy-MM-dd HH:mm')
     *  MsgBox(Type(Date.Minute)) ; String
     *  MsgBox(Type(Date.NMinute)) ; Integer
     *
     *  ; AHK handles conversions most of the time anyway.
     *  z := 10
     *  MsgBox(Date.NMinute + z) ; 25
     *  MsgBox(Date.Minute + z) ; 25
     *
     *  ; Map object keys do not convert.
     *  m := Map(15, 'val')
     *  MsgBox(m[Date.NMinute]) ; 'val'
     *  MsgBox(m[Date.Minute]) ; Error: Item has no value.
     * @
     */
    __Get(Name, *) {
        if SubStr(Name, 1, 1) = 'N' && this.HasOwnProp(SubStr(Name, 2)) {
            return Number(this.%SubStr(Name, 2)%||0)
        }
        throw PropertyError('Unknown property.', -1, Name)
    }

    /**
     * The number of seconds from midnight, including the object's current second.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    DaySeconds => this.Hour * 3600 + this.Minute * 60 + this.Second
    /**
     * Returns 1 if the object's year is a leap year, 0 otherwise.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    IsLeapYear => Container_DateObj.IsLeapYear(this.Year)
    /**
     * The number of seconds since January 01, 00:00:00 of the object's millenia. For example, if the
     * object's time value is 20240530182020, then {@link Container_DateObj.Prototype.MilleniaSeconds} will
     * return the number of seconds from January 01, 2000, 00:00:00.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    MilleniaSeconds => Container_DateObj.GetSeconds(SubStr(this.Year, 1, 1) '000' SubStr(this.Timestamp, 5), this.Timestamp)
    /**
     * The total seconds in this object's year. If it is a leap year, returns 31536000. Else,
     * returns 31449600.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    SecondsInYear => this.IsLeapYear ? Container_DateObj_SECONDS_IN_LEAPYEAR : Container_DateObj_SECONDS_IN_YEAR
    /**
     * The seconds remaining until January 01 of the year following the object's current year.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    SecondsRemainingInYear => this.SecondsInYear - this.YearSeconds
    /**
     * The timestamp of the date object.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Timestamp => this.GetTimestamp()
    /**
     * The number of seconds since January 01, 00:00:00 of year 1 in the proleptic Gregorian calendar.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    TotalSeconds => Container_DateObj.GetSeconds('00010101000000', this.Timestamp)
    /**
     * The number of days since January 01 of the object's year, including the object's current day.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    YearDays {
        Get {
            d := 0
            monthDays := Container_DateObj.MonthDays
            loop this.Month - 1 {
                if A_Index == 2 {
                    d += Mod(this.Year, 4) ? 28 : 29
                } else {
                    d += monthDays[A_Index]
                }
            }
            return d + this.Day
        }
    }
    /**
     * The number of seconds since January 01, 00:00:00 of the object's year, including the object's
     * current second.
     * @memberof Container_DateObj
     * @instance
     * @type {Integer}
     */
    YearSeconds {
        Get {
            s := 0
            loop this.Month - 1 {
                s += this.GetDayCount(A_Index) * 86400
            }
            return s + (this.Day - 1) * 86400 + this.DaySeconds
        }
    }

    /**
     * {@link https://www.autohotkey.com/docs/v2/lib/FormatTime.htm#Standalone_Formats}
     */

    /**
     * Long date representation for the current user's locale, such as Friday, April 23, 2004.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    LongDate => FormatTime(this.Timestamp ' ' this.Options, 'LongDate')
    /**
     * Short date representation for the current user's locale, such as 02/29/04.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    ShortDate => FormatTime(this.Timestamp ' ' this.Options, 'ShortDate')
    /**
     * Time representation for the current user's locale, such as 5:26 PM.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Time => FormatTime(this.Timestamp ' ' this.Options, 'Time')
    /**
     * "Leave Format blank to produce the time followed by the long date. For example, in some
     * locales it might appear as 4:55 PM Saturday, November 27, 2004"
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    ToLocale => FormatTime(this.Timestamp)
    /**
     * Day of the week (1 – 7). Sunday is 1.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    WDay => FormatTime(this.Timestamp ' ' this.Options, 'WDay')
    /**
     * Day of the year without leading zeros (1 – 366).
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    YDay => FormatTime(this.Timestamp ' ' this.Options, 'YDay')
    /**
     * Day of the year with leading zeros (001 – 366).
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    YDay0 => FormatTime(this.Timestamp ' ' this.Options, 'YDay0')
    /**
     * Year and month format for the current user's locale, such as February, 2004.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    YearMonth => FormatTime(this.Timestamp ' ' this.Options, 'YearMonth')
    /**
     * The ISO 8601 full year and week number.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    YWeek => FormatTime(this.Timestamp ' ' this.Options, 'YWeek')

    /**
     * The year value.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Year {
        Get => this.__Year
        Set => this.SetYear(Value)
    }
    /**
     * The month value.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Month {
        Get => this.__Month
        Set => this.SetValue(Value, 'Month')
    }
    /**
     * The day value.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Day {
        Get => this.__Day
        Set => this.SetValue(Value, 'Day')
    }
    /**
     * The hour value.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Hour {
        Get => this.__Hour
        Set => this.SetValue(Value, 'Hour')
    }
    /**
     * The minute value.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Minute {
        Get => this.__Minute
        Set => this.SetValue(Value, 'Minute')
    }
    /**
     * The second value.
     * @memberof Container_DateObj
     * @instance
     * @type {String}
     */
    Second {
        Get => this.__Second
        Set => this.SetValue(Value, 'Second')
    }
}

class Container_DateParser {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.12hour := false
    }

    /**
     * @description - Contains three built-in patterns to parse date strings. These are the literal patterns:
     * @example
     *  p1 := '(?<Year>\d{4}).(?<Month>\d{1,2}).(?<Day>\d{1,2})(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?'
     *  p2 := '(?<Month>\d{1,2}).(?<Day>\d{1,2}).(?<Year>(?:\d{4}|\d{2}))(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?'
     *  p3 := '(?<Hour>\d{1,2}):(?<Minute>\d{1,2})(?::(?<Second>\d{1,2}))?'
     * @
     *
     * The patterns represent strings like these. This is not an exhaustive list:
     * "yyyy-M-d H:m:s" - the time units are optional, seconds optional within the time units
     * "M/d/yyyy H:m:s" - the time units are optional, seconds optional within the time units
     * "M/d/yy H:m:s" - the time units are optional, seconds optional within the time units
     * "h:m:s" - time by itself, the seconds optional
     *
     * @param {String} DateStr - The date string to parse.
     * @returns {Container_DateObj} - The {@link Container_DateObj} object.
     */
    static Parse(DateStr) {
        if RegExMatch(DateStr, '(?<Year>\d{4}).(?<Month>\d{1,2}).(?<Day>\d{1,2})(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?', &match)
        || RegExMatch(DateStr, '(?<Month>\d{1,2}).(?<Day>\d{1,2}).(?<Year>(?:\d{4}|\d{2}))(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?', &match) {
            ObjSetBase(Date := {
                Year: match.Len['Year'] == 2 ? SubStr(A_Now, 1, 2) match['Year'] : match['Year']
              , Month: (match.Len['Month'] == 1 ? '0' : '') match['Month']
              , Day: (match.Len['Day'] == 1 ? '0' : '') match['Day']
              , Hour: match.Len['Hour'] ? (match.Len['Hour'] == 1 ? '0' : '') match['Hour'] : unset
              , Minute: match.Len['Minute'] ? (match.Len['Minute'] == 1 ? '0' : '') match['Minute'] : unset
              , Second: match.Len['Second'] ? (match.Len['Second'] == 1 ? '0' : '') match['Second'] : unset
            }, Container_DateObj.Prototype)
        } else if RegExMatch(DateStr, '(?<Hour>\d{1,2}):(?<Minute>\d{1,2})(?::(?<Second>\d{1,2}))?', &match) {
            ObjSetBase(Date := {
                Hour: (match.Len['Hour'] == 1 ? '0' : '') match['Hour']
              , Minute: (match.Len['Minute'] == 1 ? '0' : '') match['Minute']
              , Second: match['Second'] ? (match.Len['Second'] == 1 ? '0' : '') match['Second'] : unset
            }, Container_DateObj.Prototype)
        }
        Date.Match := match
        return Date
    }

    /**
     * @description - Creates a `Container_DateParser` object that can be reused to create {@link Container_DateObj} objects.
     * @param {String} DateFormat - The format of the date string. See the {@link Container_DateObj.Call}
     * description for details.
     * @param {String} [RegExOptions=""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     * @param {Boolean} [SubcaptureGroup=true] - When true, each \t escaped format group is captured
     * in an unnamed subcapture group. When false, the function does not include any additional
     * subcapture groups.
     * @returns {Container_DateParser} - The `Container_DateParser` object.
     */
    __New(DateFormat, RegExOptions := '', SubcaptureGroup := true) {
        rc := Chr(0xFFFD) ; replacement character
        replacement := []
        replacement.Capacity := 20
        flag_period := false
        pos := 1
        i := 0
        while RegExMatch(DateFormat, '\\t\{([^}]+)\}', &matchgroup, pos) {
            copy := matchgroup[1]
            pos := matchgroup.Pos + matchgroup.Len
            _Proc(&copy)
            if SubcaptureGroup {
                DateFormat := StrReplace(DateFormat, matchgroup[0], '(' copy ')', , , 1)
            } else {
                DateFormat := StrReplace(DateFormat, matchgroup[0], '(?:' copy ')', , , 1)
            }
        }
        if !i {
            _Proc(&DateFormat)
        }
        if this.12hour && !flag_period {
            throw Error('The date format string indicates 12-hour time format, but does not include an AM/PM indicator', -1)
        }
        for r in replacement {
            DateFormat := StrReplace(DateFormat, r.temp, r.pattern, , , 1)
        }
        this.RegExOptions := RegExOptions
        this.Pattern := DateFormat

        _Proc(&p) {
            if RegExMatch(p, '(y+)(\??)', &match) {
                replacement.Push({ pattern: '(?<Year>\d{' (match.Len[1] == 1 ? '1,2' : match.Len[1]) '})' match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
            }
            if RegExMatch(p, '(M+)(\??)', &match) {
                if match.Len[1] == 1 {
                    pattern := '(?<Month>\d{1,2})'
                } else if match.Len[1] == 2 {
                    pattern := '(?<Month>\d{2})'
                } else if match.Len[1] == 3 {
                    pattern := '(?<Month>(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec))'
                } else if match.Len[1] == 4 {
                    pattern := '(?<Month>(?:january|february|march|april|may|june|july|august|september|october|november|december))'
                }
                replacement.Push({ pattern: pattern match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
            }
            if RegExMatch(p, '(h+)(\??)', &match) {
                replacement.Push({ pattern: '(?<Hour>\d{' (match.Len[1] == 1 ? '1,2' : '2') '})' match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
                this.12hour := true
            }
            if RegExMatch(p, '(t+)(\??)', &match) {
                if match.Len[1] == 1 {
                    pattern := '(?<Period>[ap])'
                } else {
                    pattern := '(?<Period>[ap]m)'
                }
                replacement.Push({ pattern: pattern match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
                flag_period := true
            }
            for ch, name in Map('d', 'Day', 'H', 'Hour', 'm', 'Minute', 's', 'Second') {
                if RegExMatch(p, '(' ch '+)(\??)', &match) {
                    replacement.Push({ pattern: '(?<' name '>\d{' (match.Len[1] == 1 ? '1,2' : '2') '})' match[2], temp: rc (++i) rc })
                    p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
                }
            }
        }
    }

    /**
     * @description - Parses the input date string and returns a {@link Container_DateObj} object.
     * @param {String} DateStr - The date string to parse.
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used.
     * @param {Boolean} [Validate=false] - When true, the values of each property are validated
     * before the function completes. The values are validated numerically, and if any value exceeds
     * the maximum value for that property, an error is thrown. For example, if the month is greater
     * than 13 or the hour is greater than 24, an error is thrown.
     * @returns {Container_DateObj} - The {@link Container_DateObj} object.
     */
    Call(DateStr, Century?, Validate := false) {
        local Match
        if !RegExMatch(DateStr, this.RegExOptions this.Pattern, &match) {
            return ''
        }
        ObjSetBase(Date := {}, Container_DateObj.Prototype)
        Date.DefineProp('Parser', { Value: this })
        Date.DefineProp('Match', { Value: match })
        for unit, str in match {
            switch unit {
                case 'Year':
                    if match.Len['Year'] {
                        switch match.Len['Year'] {
                            case 1: Date.DefineProp('__Year', { Value: (Century ?? SubStr(A_Now, 1, 3)) match['Year'] })
                            case 2: Date.DefineProp('__Year', { Value: (Century ?? SubStr(A_Now, 1, 2)) match['Year'] })
                            case 4: Date.DefineProp('__Year', { Value: match['Year'] })
                        }
                    }
                case 'Month':
                    if match.Len['Month'] {
                        if IsNumber(match['Month']) {
                            if match.Len['Month'] == 1 {
                                Date.DefineProp('__Month', { Value: '0' match['Month'] })
                            } else {
                                Date.DefineProp('__Month', { Value: match['Month'] })
                            }
                        } else {
                            Date.DefineProp('__Month', { Value: Container_DateObj.GetMonthIndex(match['Month'], true) })
                        }
                    }
                case 'Hour':
                    if match.Len['Hour'] {
                        if this.12hour {
                            n := Number(match['Hour'])
                            switch SubStr(match['Period'], 1, 1), 0 {
                                case 'a':
                                    if n == 12 {
                                        Date.DefineProp('__Hour', { Value: '00' })
                                    } else if Match.Len['Hour'] == 1 {
                                        Date.DefineProp('__Hour', { Value: '0' match['Hour'] })
                                    } else {
                                        Date.DefineProp('__Hour', { Value: match['Hour'] })
                                    }
                                case 'p':
                                    if n == 12 {
                                        Date.DefineProp('__Hour', { Value: '12' })
                                    } else {
                                        Date.DefineProp('__Hour', { Value: String(n + 12) })
                                    }
                            }
                        } else {
                            if match.Len['Hour'] == 1 {
                                Date.DefineProp('__Hour', { Value: '0' match['Hour'] })
                            } else if match.Len['Hour'] == 2 {
                                Date.DefineProp('__Hour', { Value: match['Hour'] })
                            }
                        }
                    }
                case 'Minute', 'Second', 'Day':
                    if match.Len[unit] {
                        if match.Len[unit] == 1 {
                            Date.DefineProp('__' unit, { Value: '0' match[unit] })
                        } else if match.Len[unit] == 2 {
                            Date.DefineProp('__' unit, { Value: match[unit] })
                        }
                    }
            }
        }
        if Validate {
            if Date.NMonth > 12
                _ThrowInvalidResultError('Month: ' Date.Month)
            ; If we don't know the year and the month is February, use 29 as the value by default
            if Date.Month == '02' && !Date.Year {
                if Date.NDay > 29
                    _ThrowInvalidResultError('Day: ' Date.Day)
            } else if Date.NDay > Container_DateObj.GetDayCount(Date.NMonth, Date.NYear)
                _ThrowInvalidResultError('Day: ' Date.Day)
            if Date.NHour > 24
                _ThrowInvalidResultError('Hour: ' Date.Hour)
            if Date.NMinute > 60
                _ThrowInvalidResultError('Minute: ' Date.Minute)
            if Date.NSecond > 60
                _ThrowInvalidResultError('Second: ' Date.Second)
        }
        return Date

        _ThrowInvalidResultError(Value) {
            throw ValueError('The result produced an invalid date.', -2, Value)
        }
    }
}
