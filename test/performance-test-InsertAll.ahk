
#SingleInstance force
#include Container_Test.ahk

/**
 * This test compares four styles of "InsertAll" methods:
 * 1. Sorts the values before processing then uses the return index value from "Insert" to
 *    reduce the range with each item.
 * 2. Sorts the values before processing, caches the index returned from inserting the first
 *    value, then jumps up a number of values and caches the index from inserting that value, then works
 *    its way down using the two indices as bounds, lowering the upper bound each time until until no
 *    values remain, then jumping up the same number of values ahead of the earlier jump, continuing this
 *    process until all values have been inserted.
 * 3. Calls "Insert" for each item with no extra work.
 * 4. After each "Insert", the next value is compared to the current value and that relationship is
 *    used to apply the returned index as either the upper or lower bound for the next insert.
 *
 * Results:
 *
 * 1. Always the slowest.
 * 2. Occasionally the fastest but I did not observe a pattern.
 * 3. 3 and 4 are about the same and are usually the fastest overall.
 *
 * Conclusion: Simply looping the values and calling "Insert" is the best choice.
 */


if A_LineFile == A_ScriptFullPath {

    CoordMode('Tooltip', 'Screen')
    CoordMode('Mouse', 'Screen')
    result := test()
    A_Clipboard := result.GetResultString()
    MouseGetPos(&x, &y)
    ToolTip('Done', x, y)
    SetTimer((*) => ExitApp(), -2000)
}

class test extends Container {
    static __New() {
        this.DeleteProp('__New')
    }
    __New(len := 100000, step := 32, validate := false, SkipDateStr := true) {
        CoordMode('Tooltip', 'Screen')
        CoordMode('Mouse', 'Screen')
        ProcessSetPriority ('H')

        loop CONTAINER_SORTTYPE_END {
            if SkipDateStr
            && (A_Index == CONTAINER_SORTTYPE_CB_DATESTR
            || A_Index == CONTAINER_SORTTYPE_DATESTR
            || A_Index == CONTAINER_SORTTYPE_DATEVALUE
            || A_Index == CONTAINER_SORTTYPE_MISC) {
                continue
            }
            MouseGetPos(&x, &y)
            ToolTip('Starting ' A_Index, x, y)
            SetTimer(ToolTip, -2000)

            this.Push({})
            r := this[-1]
            _c1 := Container_Test(A_Index, len, true)
            _c2 := Container_Test(A_Index, len / 10, false)

            ; Sort
            ; c1 := _c1.Clone()
            ; c2 := _c2.Clone()
            ; Critical(-1)

            ; r.sort := PerformanceTimer(A_Index)
            ; c2 := c2.QuickSort()
            ; i := 1
            ; for value in c2 {
            ;     if index := c1.FindInequality(Value, , '>', i) {
            ;         c1.InsertAt(index, Value)
            ;         i := index
            ;     } else if c1.Compare(Value, 1) < 0 {
            ;         c1.InsertAt(1, Value)
            ;         i := 1
            ;     } else {
            ;         c1.Push(Value)
            ;         i := c1.Length
            ;     }
            ; }
            ; r.sort.end := A_TickCount

            ; Critical(0)
            ; Sleep(-1)
            ; if c1.Length !== len + c2.Length {
            ;     throw Error('Invalid number of items in the receiving container.', , c1.Length)
            ; }
            ; if validate {
            ;     c1.ValidateSort()
            ;     if IsObject(c2[1]) {
            ;         i := 1
            ;         for value in c1 {
            ;             if ObjPtr(value) = ObjPtr(c2[i]) {
            ;                 if ++i > c2.Length {
            ;                     break
            ;                 }
            ;             }
            ;         }
            ;         if i !== c2.Length + 1 {
            ;             throw Error('Not every item was placed into the container.')
            ;         }
            ;     }
            ; }

            ; Sort and step
            c1 := _c1.Clone()
            c2 := _c2.Clone()
            Critical(-1)

            r.step := PerformanceTimer(A_Index)
            c2 := c2.QuickSort()
            if left := c1.FindInequality(c2[1], , '>') {
                c1.InsertAt(left, c2[1])
            } else if c1.Compare(c2[1], 1) < 0 {
                c1.InsertAt(1, c2[1])
                left := 1
            } else {
                c1.Push(c2[1])
                left := c1.Length
            }
            i := 1 + step
            _step := step - 1
            _add := step * 2 - 1
            loopCount := Floor((c2.Length - 1) / step)
            loop loopCount  {
                placeholder := right := c1.FindInequality(c2[i], , '>', left, c1.Length)
                c1.InsertAt(right, c2[i])
                loop _step {
                    right := c1.FindInequality(c2[--i], , '>', left, right)
                    c1.InsertAt(right, c2[i])
                }
                i += _add
                left := placeholder - 1
            }
            k := i - step
            right := c1.Length
            i := c2.Length
            loop i - k {
                right := c1.FindInequality(c2[i], , '>', left, right)
                c1.InsertAt(right, c2[i])
                i--
            }
            r.step.end := A_TickCount
            Critical(0)
            Sleep(-1)

            if c1.Length !== len + c2.Length {
                throw Error('Invalid number of items in the receiving container.', , c1.Length)
            }
            if validate {
                c1.ValidateSort()
                if IsObject(c2[1]) {
                    i := 1
                    for value in c1 {
                        if ObjPtr(value) = ObjPtr(c2[i]) {
                            if ++i > c2.Length {
                                break
                            }
                        }
                    }
                    if i !== c2.Length + 1 {
                        throw Error('Not every item was placed into the container.')
                    }
                }
            }

            ; Insert only
            c1 := _c1.Clone()
            c2 := _c2.Clone()
            Critical(-1)
            r.nosort := PerformanceTimer(A_Index)
            for value in c2 {
                c1.Insert(value)
            }
            r.nosort.end := A_TickCount
            Critical(0)
            Sleep(-1)
            if c1.Length !== len + c2.Length {
                throw Error('Invalid number of items in the receiving container.', , c1.Length)
            }
            if validate {
                c1.ValidateSort()
                if IsObject(c2[1]) {
                    i := 1
                    c2 := c2.QuickSort()
                    for value in c1 {
                        if ObjPtr(value) = ObjPtr(c2[i]) {
                            if ++i > c2.Length {
                                break
                            }
                        }
                    }
                    if i !== c2.Length + 1 {
                        throw Error('Not every item was placed into the container.')
                    }
                }
            }

            ; flex
            c1 := _c1.Clone()
            c2 := _c2.Clone()
            Critical(-1)
            r.flex := PerformanceTimer(A_Index)
            left := 1
            right := len
            i := 0
            loop c2.Length - 1 {
                if index := c1.FindInequality(c2[++i], , '>', left, right) {
                    c1.InsertAt(index, c2[i])
                    if x := c1.Compare(c2[i + 1], index) {
                        if x > 0 {
                            left := index
                            right := c1.Length
                        } else {
                            right := index
                            left := 1
                        }
                    } else {
                        c1.InsertAt(index, c2[++i])
                        left := 1
                        right := c1.Length
                    }
                } else if c1.Compare(c2[i], 1) < 0 {
                    c1.InsertAt(1, c2[i])
                    left := 1
                    right := c1.Length
                } else {
                    c1.Push(c2[i])
                    left := 1
                    right := c1.Length
                }
            }
            if index := c1.FindInequality(c2[-1], , '>', left, right) {
                c1.InsertAt(index, c2[-1])
            } else if c1.Compare(c2[-1], 1) < 0 {
                c1.InsertAt(1, c2[-1])
            } else {
                c1.Push(c2[-1])
            }
            r.flex.end := A_TickCount
            Critical(0)
            Sleep(-1)
            if c1.Length !== len + c2.Length {
                throw Error('Invalid number of items in the receiving container.', , c1.Length)
            }
            if validate {
                c1.ValidateSort()
                if IsObject(c2[1]) {
                    i := 1
                    c2 := c2.QuickSort()
                    for value in c1 {
                        if ObjPtr(value) = ObjPtr(c2[i]) {
                            if ++i > c2.Length {
                                break
                            }
                        }
                    }
                    if i !== c2.Length + 1 {
                        throw Error('Not every item was placed into the container.')
                    }
                }
            }
        }
    }
    GetResultString() {
        s := ''
        for item in result {
            for category, r in item.OwnProps() {
                s .= r.index ': sort type: ' r.sortTypeName '; category: ' category ' - start: ' r.start '; end: ' r.end '; ms: ' r.ms '; sec: ' r.sec '`n'
            }
            s .= '`n'
        }
        return s
    }
}

class PerformanceTimer {
    __New(index) {
        this.index := index
        this.start := A_TickCount
    }
    SetEnd(end) {
        this.end := end
    }
    ms => this.end - this.start
    sec => this.ms / 1000
    min => this.sec / 60
    hour => this.min / 60
    day => this.hour / 24

    sortTypeName => Container_IndexToSymbol(this.index).name
}
