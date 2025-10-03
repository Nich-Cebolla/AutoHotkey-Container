

#Include ..\src\Container.ahk
#include Container_Test.ahk
#SingleInstance force
; This is optional and only serves a cosmetic purpose. You can use this script without it.
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
#Include *i <Align>

; to use the gui
; test_FindInequalitySparse.Gui()

; to run the test without the gui. if it returns 0 that means all iterations were successful.
; Result := test_FindInequalitySparse()

; Call `test_FindInequalitySparse.SetSortType` before running the test to specify the sort type.
; The default is CONTAINER_SORTTYPE_NUMBER.

class test_FindInequalitySparse {

    ; These are used by the gui. You can modify them without issue. The last font name in the array
    ; would be the one that gets used first.
    static Options := {
        FontOpt: 'S11 Q5'
      , FontStandard: ['Aptos', 'Roboto']
      , FontMono: ['Mono', 'Roboto Mono']
    }

    static Debug := true
    , DebugCallback := ''

    static TestAll() {
        loop CONTAINER_SORTTYPE_END {
            this.SetSortType(A_Index)
            if result := this() {
                throw Error('FindInequalitySparse encountered a problem.', -1, 'Problem count: ' result)
            }
        }
    }
    /**
     * @description - Initiates the test. The test is designed to validate
     * {@link Container.Prototype.FindInequalitySparse}.
     *
     * This test processes about 4000 iterations, most of them are fringe cases with very small input
     * ranges and/or the `Value` to find is at the edge or just beyond the extreme values in the
     * range.
     *
     * For each call to {@link Container.Prototype.FindInequalitySparse}, an object is appended to
     * either `test_FindInequalitySparse.Result` or `test_FindInequalitySparse.Problem`, each an
     * array, depending on if the values returned by {@link Container.Prototype.FindInequalitySparse}
     * match the expected values.
     *
     * When {@link test_FindInequalitySparse} completes, it will return the number of items contained in
     * `test_FindInequalitySparse.Problem`. 0 means no problems.
     *
     * To test using the Gui, call {@link test_FindInequalitySparse.Gui}
     *
     * To test with additional debugging features, set `test_FindInequalitySparse.Debug := true`.
     * When true, and if a problem is encountered, test_FindInequalitySparse will:
     *
     * - Create the result object and append it to `test_FindInequalitySparse.Problem` (it does this even
     * when `Debug` is false).
     * - Set `test_FindInequalitySparse.DebugPause := true`
     * - Call the function assigned to `DebugCallback` if there is one. Defining one is not necessary.
     * - If the function returns nonzero, or if there is no function, return `-1` to the function
     * that called {@link test_FindInequalitySparse}, and leaves `DebugPause == true`. The next time
     * {@link test_FindInequalitySparse} is called, it repeats the
     * {@link Container.Prototype.FindInequalitySparse} call with the same parameters as the previous
     * call. I did this because it was easier to debug problems when I had all the information ready
     * before I stepped through the function. The second {@link Container.Prototype.FindInequalitySparse}
     * call does not produce another result object.
     * - If the function returns zero or an empty string, sets `test_FindInequalitySparse.DebugPause := 0`
     * and resumes processing.
     */
    static Call() {
        if (!this.Paused && !this.DebugPause) || this.Finished {
            this.__Initialize()
        }
        local TA, GT, ET, B, FI
        if !this.Functions.Length {
            loop {
                try {
                    this.Functions.Push(Process_%A_Index%)
                } catch {
                    break
                }
            }
        }
        this.Paused := 0
        Proc := this.GuiActive ? Process_Main_Gui : Process_Main
        Result := Process_Loop()
        if this.Stop {
            this.Stop := this.Paused := 0
        } else if !this.Paused && !this.DebugPause {
            ; this.__ShowTooltip('Done')
            this.Finished := 1
            this.Result.Capacity := this.Result.Length
            Result := this.Problem.Capacity := this.Problem.Length
        }
        return Result

        Process_Loop() {
            input := this.input
            while input.array <= this.TestArray.Length {
                TA := this.TestArray[input.array]
                while input.gt <= this.GreaterThan.Length {
                    GT := this.GreaterThan[input.gt]
                    while input.et <= this.EqualTo.Length {
                        ET := this.EqualTo[input.et]
                        while input.bounds <= this.Bounds.Length {
                            B := this.Bounds[input.bounds]
                            while input.find <= this.FindIndices.Length {
                                FI := this.FindIndices[input.find]
                                if FI < B.Start || FI > B.End {
                                    input.find++
                                    continue
                                }
                                while input.fn <= this.Functions.Length {
                                    if this.Paused || this.Stop {
                                        return
                                    }
                                    this.Functions[input.fn](TA, GT,  ET, B, FI)
                                    if this.DebugPause {
                                        return -1
                                    }
                                    input.count++
                                    input.fn++
                                }
                                input.fn := 1
                                input.find++
                            }
                            input.find := 1
                            input.bounds++
                        }
                        input.bounds := 1
                        input.et++
                    }
                    input.et := 1
                    input.gt++
                }
                input.gt := 1
                input.array++
            }
            return test_FindInequalitySparse.Problem.Length
        }

        /**
         * @description - A wrapper for calling the functions and storing the results.
         */
        Process_Main(TA, GT,  ET, B, FI, ExpectedIndex, ExpectedValue, LineNumber) {
            Result := _GetResult(TA, GT,  ET, B, FI, &FoundValue)
            if this.DebugPause {
                this.DebugPause := 0
            } else {
                if Result !== ExpectedIndex || (FoundValue??0) !== ExpectedValue {
                    this.Problem.Push(_GetResultObj(TA, GT,  ET, B, FI, FoundValue??0, Result, ExpectedIndex, ExpectedValue, LineNumber, true))
                    _ProcessDebug()
                } else {
                    this.Result.Push(_GetResultObj(TA, GT,  ET, B, FI, FoundValue??0, Result, ExpectedIndex, ExpectedValue, LineNumber, false))
                }
            }
        }

        Process_Main_Gui(TA, GT,  ET, B, FI, ExpectedIndex, ExpectedValue, LineNumber) {
            Result := _GetResult(TA, GT,  ET, B, FI, &FoundValue)
            if this.DebugPause {
                this.DebugPause := 0
            } else {
                if Result !== ExpectedIndex || (FoundValue??0) !== ExpectedValue {
                    this.Problem.Push(_GetResultObj(TA, GT,  ET, B, FI, FoundValue??0, Result, ExpectedIndex, ExpectedValue, LineNumber, true))
                    this.G['TxtTotal_Problem'].Text := this.Problem.Length
                    if this.Debug {
                        this.__UpdateDisplay(this.Problem[-1])
                        this.DebugPause := 1
                    }
                } else {
                    this.Result.Push(_GetResultObj(TA, GT,  ET, B, FI, FoundValue??0, Result, ExpectedIndex, ExpectedValue, LineNumber, false))
                    if this.GuiActive {
                        this.G['TxtTotal_Result'].Text := this.Result.Length
                    }
                }
            }
        }

        _ProcessDebug() {
            if !this.Debug {
                return
            }
            this.DebugPause := 1
            Callback := this.DebugCallback
            if Callback && !Callback() {
                this.DebugPause := 0
            }
        }

        _GetResult(TA, GT,  ET, B, FI, &FoundValue) {
            return TA.FindInequalitySparse(GetValue(FI), &FoundValue, _GetCondition(GT, ET), B.Start, B.End)
        }

        _GetResultObj(TA, GT,  ET, B, FI, FoundValue, Result, ExpectedIndex, ExpectedValue, LineNumber, CopyArray := false) => {
            input: this.input.Clone()
          , FoundIndex: Result
          , ExpectedIndex: ExpectedIndex
          , Arr: CopyArray ? _CopyArray() : ''
          , FindValue: GetValue(FI)
          , FindIndex: FI
          , FoundValue: FoundValue
          , ExpectedValue: ExpectedValue
          , LineNumber: LineNumber
        }

        _GetCondition(GT, ET) => GT ? ET ? '>=' : '>' : ET ? '<=' : '<'

        GetValue(Index) => this.TestArrayOriginal[this.input.array][Index]

        /**
         * @description - Searches for the value at the indicated index, and the value is present
         * at the index.
         */
        Process_1(TA, GT,  ET, B, FI) {
            input := this.input
            k := FI - 2
            loop 3 {
                if ++k < 1 || k > this.Len {
                    continue
                }
                TA[k] := GetValue(k)
            }
            if ET {
                ; The loop skips cases where FI > B.End  || FI < B.Start. Consequently,
                ; when ET is true, the function will always find the value in this block.
                Proc(TA, GT,  ET, B, FI, FI, GetValue(FI), A_LineNumber)
            } else {
                ; If ET is false, the function fails to find the value when FI - 1 < B.Start || FI + 1 > B.End
                ; depending on the direction fo the array and whether GT is true.
                if GT {
                    if input.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI + 1, GetValue(FI + 1), A_LineNumber)
                        }
                    } else { ; descending values
                        if FI - 1 < B.Start {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    }
                } else {
                    if input.array == 1 { ; adcending values.
                        if FI - 1 < B.Start {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    } else { ; descending values.
                        if FI + 1 > B.End {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI + 1, GetValue(FI + 1), A_LineNumber)
                        }
                    }
                }
            }
        }

        /**
         * @description - Searches for the value at the indicated index, and the value is present
         * both at the indicated index, and on adjacent indices. The next index over also is ensured
         * to have its own value to simplify the test.
         * The two indices adjacent to FI have the same value as FI, like this:
         * - ..., FI-3, FI-2, FI, FI, FI, FI+2, FI+3, ...
         */
        Process_2(TA, GT,  ET, B, FI) {
            input := this.input
            if FI + 1 <= this.Len {
                TA[FI + 1] := GetValue(FI)
            }
            if FI - 1 >= 1 {
                TA[FI - 1] := GetValue(FI)
            }
            if FI + 2 <= this.Len {
                TA[FI + 2] := GetValue(FI + 2)
            }
            if FI - 2 >= 1 {
                TA[FI - 2] := GetValue(FI - 2)
            }

            ; For the function to be correctly implemented, it must return the *first* found
            ; index of the value. input defined the function to determine sort order and
            ; search direction internally; this block of tests validates this has been implemented
            ; correctly.

            ; The "first" found value in this block will either be +/-1 or +/-2 from FI, unless
            ; the value is at the edge of the array. In those cases, the correct index may
            ; be FI.

            ; Greater than =========================================================
            if GT {
                ; Equal to ---------------------------------------------------------
                if ET {
                    ; When ET is true, we are looking at indices +/- 1 from FI.
                    if input.array == 1 { ; ascending values.
                    ; When GT and ascending, the search direction is left-to-right.
                    ; So the correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                                ; The ExpectedValue stays GetValue(FI)
                                ; because that's what we put in there for this test.
                            Proc(TA, GT,  ET, B, FI, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI - 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; When GT and descending, the search direction is right-to-left.
                    ; So the correct index is FI + 1 when ET.
                        if FI + 1 > B.End {
                            Proc(TA, GT,  ET, B, FI, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI + 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                ; When !ET, the correct index is +/-2 from FI.
                    if input.array == 1 { ; adcending values.
                        ; Search direction is left-to-right, so next greatest value is at index FI + 2.
                        if FI + 2 > B.End {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is right-to-left.
                        if FI - 2 < B.Start {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI - 2, GetValue(FI - 2), A_LineNumber)
                        }
                    }
                }
                ; ------------------------------------------------------------------
            ; ======================================================================
            ; Less than ============================================================
            } else {
                ; Equal to ---------------------------------------------------------
                if ET {
                    ; When !GT and ascending, the search direction is right-to-left, so the correct
                    ; index will be FI + 1 when ET.
                    if input.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Proc(TA, GT,  ET, B, FI, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI + 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; Search direction is left-to-right, so correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                            Proc(TA, GT,  ET, B, FI, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI - 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                    if input.array == 1 { ; adcending values.
                    ; !GT and ascending, so the search direction is right-to-left.
                    ; The next smallest value is at index FI - 2.
                        if FI - 2 < B.Start {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI - 2, GetValue(FI - 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is left-to-rigth.
                        if FI + 2 > B.End {
                            Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                        } else {
                            Proc(TA, GT,  ET, B, FI, FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    }
                }
            }
        }

        /**
         * @description - Searches for the value at the indicated index, and the value absent
         * from the array.
         * - ..., FI-3, FI-2, FI-1, unset, FI+1, FI+2, FI+3, ...
         * In this block, regardless of ET, the correct index will be +/- 1 from FI. No index
         * should be returned if that index is < B.Start or > B.End depending on the direction
         * of ascent.
         */
        Process_3(TA, GT,  ET, B, FI) {
            input := this.input
            TA.Delete(FI)
            if FI - 1 >= 1 {
                TA[FI - 1] := GetValue(FI - 1)
            }
            if FI + 1 <= TA.Length {
                TA[FI + 1] := GetValue(FI + 1)
            }
            if GT {
                if input.array == 1 {
                    if FI + 1 > B.End {
                        Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                    } else {
                        Proc(TA, GT,  ET, B, FI, FI + 1, GetValue(FI + 1), A_LineNumber)
                    }
                } else {
                    if FI - 1 < B.Start {
                        Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                    } else {
                        Proc(TA, GT,  ET, B, FI, FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                }
            } else {
                if input.array == 1 {
                    if FI - 1 < B.Start {
                        Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                    } else {
                        Proc(TA, GT,  ET, B, FI, FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                } else {
                    if FI + 1 > B.End {
                        Proc(TA, GT,  ET, B, FI, 0, 0, A_LineNumber)
                    } else {
                        Proc(TA, GT,  ET, B, FI, FI + 1, GetValue(FI + 1), A_LineNumber)
                    }
                }
            }
        }

        _CopyArray() {
            k := FI - 11
            Result := { Arr: Copy := Container(), Start: 0, End: 0 }
            Copy.Capacity := 20
            loop 20 {
                if ++k < 1 {
                    continue
                }
                if k > this.Len {
                    Result.End := k - 1
                    break
                }
                if !Result.Start {
                    Result.Start := k
                }
                if TA.Has(k) {
                    Copy.Push(TA[k])
                } else {
                    Copy.Push(0)
                }
            }
            if !Result.End {
                Result.End := k
            }
            return Result
        }
    }

    static SetSortType(SortType) {
        this.TestArrayOriginal := [ Container_Test(SortType, this.Len, true), '']
        this.TestArrayOriginal[2] := this.TestArrayOriginal[1].Reverse()
        this.TestArray := [ this.TestArrayOriginal[1].Clone(), this.TestArrayOriginal[2].Clone() ]
        this.__Initialize()
    }

    /**
     * @description - Launches the test window.
     */
    static Gui() {
        if this.HasOwnProp('G') {
            try {
                this.G.Show()
            } catch {
                this.__CreateGui()
            }
        } else {
            this.__CreateGui()
        }
        this.__Initialize()
        this.GuiActive := 1
    }

    /**
     * @description - If using this as part of a larger validation procedure, you may want to free
     * the resources after validation here is complete. Call `Dispose` to do so.
     */
    static Dispose() {
        for G in ['G', 'EG', 'MG'] {
            if this.HasOwnProp(G) {
                try {
                    this.%G%.Destroy()
                }
                this.DeleteProp(G)
            }
        }
        for Prop in this.OwnProps() {
            if !this.HasMethod(Prop) {
                if this.%Prop% is Array {
                    this.%Prop%.Capacity := 0
                } else if IsObject(this.%Prop%) {
                    ObjSetCapacity(this.%Prop%, 0)
                }
            }
            this.DeleteProp(Prop)
        }
        this.DefineProp('Call', { Call: _Throw })
        _Throw(*) {
            throw Error('This object has been disposed.', -1)
        }
    }

    static __CreateGui() {
        Opt := this.Options
        G := this.G := Gui('-DPIScale +Resize')
        this.__SetFonts(G, Opt.FontStandard)
        G.SetFont(Opt.FontOpt)
        Text := this.BtnCtrlNames[1]
        G.Add('Button', 'Section vBtn' Text, Text).OnEvent('Click', HClickButton%Text%)
        k := 1
        loop this.BtnCtrlNames.Length - 1 {
            Text := this.BtnCtrlNames[++k]
            G.Add('Button', 'vBtn' Text ' ys', Text).OnEvent('Click', HClickButton%Text%)
        }
        G.Add('Button', 'xs Section vBtnPrevious_Result', 'Previous Result').OnEvent('Click', HClickButtonPrevious)
        G.Add('Button', 'xs Section vBtnPrevious_Problem', 'Previous Problem').OnEvent('Click', HClickButtonPrevious)
        G['BtnPrevious_Problem'].GetPos(, , &cw)
        G['BtnPrevious_Result'].Move(, , cw)
        _CreateScroller('Result')
        _CreateScroller('Problem')
        G['BtnPrevious_Problem'].GetPos(, &cy, , &ch)
        G.Add('Edit', Format('x{} y{} w400 r21 Section +Wrap vResult', G.MarginX, cy + ch + G.MarginY))
        G.Add('Edit', 'ys w300 hp vArray')
        G.OnEvent('Close', (*) => this.GuiActive := 0)

        G.Show()
        if IsSet(Align) {
            Align.GroupWidth_S([G['BtnNext_Result'], G['BtnNext_Problem']])
        }
        G['BtnNext_Result'].GetPos(&cx, &cy, &cw)
        G.Add('Text', Format('x{} y{} Section vTxtDuration', cx + cw + G.MarginX, cy), 'Duration:')
        G.Add('Text', 'xs w100 vTxtDurationValue', '0')

        for Ctrl in G {
            if Ctrl.Type == 'Edit' {
                this.__SetFonts(Ctrl, Opt.FontMono)
            }
        }

        G['Btn' this.BtnCtrlNames[-1]].GetPos(&x, &y, &w)
        G.Add('Text', 'x' (x + w + G.MarginX) ' y' y ' Section vTxtSortType', 'Sort type:')
        G.Add('Edit', 'ys w75 vEdtSortType', 1)
        G.Add('Button', 'ys vBtnSetSortType', 'Set Sort type').OnEvent('Click', (btn, *) => test_FindInequalitySparse.SetSortType(btn.Gui['EdtSortType'].Text))
        G['BtnSetSortType'].GetPos(&x, , &w)
        G.Show('w' (x + w + G.MarginX))

        return

        _CreateScroller(Name) {
            G['BtnPrevious_' Name].GetPos(&cx, &cy, &cw, &ch)
            G.Add('Edit', Format('x{} y{} w50 Section vEditJump_{}', cx + cw + G.MarginX, cy, Name), 1).OnEvent('Change', HChangeEditJump)
            G.Add('Text', 'ys vTxtOf_' Name, ' of ')
            G.Add('Text', 'ys w40 vTxtTotal_' Name, '0')
            G.Add('Button', 'ys vBtnJump_' Name, 'Jump').OnEvent('Click', HClickButtonJump)
            G.Add('Button', 'ys vBtnNext_' Name, 'Next ' Name).OnEvent('Click', HClickButtonNext)
            if IsSet(Align) {
                Align.CenterV(G['TxtOf_' Name], G['BtnPrevious_' Name])
                Align.CenterV(G['TxtTotal_' Name], G['BtnPrevious_' Name])
                Align.CenterV(G['EditJump_' Name], G['BtnPrevious_' Name])
            }
        }

        _GetName(Ctrl) => StrSplit(Ctrl.Name, '_')[2]

        HChangeEditJump(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
            if ReplaceCount {
                this.__ShowTooltip('Numbers only!')
            }
        }

        HClickButtonClear(*) {
            this.Stop := this.Paused := this.Finished := 0
            G['Result'].Text := G['Array'].Text := ''
            G['TxtTotal_Result'].Text := G['TxtTotal_Problem'].Text := '0'
            G['EditJump_Result'].Text := G['EditJump_Problem'].Text := '1'
            this.__Initialize()
        }

        HClickButtonExit(*) {
            ExitApp()
        }

        HClickButtonJump(Ctrl, *) {
            if this.__SetIndex(_GetName(Ctrl), G['EditJump_' _GetName(Ctrl)].Text) {
                this.__ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.__UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonListLines(*) {
            ListLines()
        }

        HClickButtonNext(Ctrl, *) {
            if this.__IncIndex(_GetName(Ctrl), 1) {
                this.__ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.__UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonPause(*) {
            this.Paused := 1
            this.__ShowTooltip('Paused.')
        }

        HClickButtonPrevious(Ctrl, *) {
            if this.__IncIndex(_GetName(Ctrl), -1) {
                this.__ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.__UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonReload(*) {
            Reload()
        }

        HClickButtonStart(*) {
            if this.Finished {
                HClickButtonClear()
            }
            this.StartTime := A_TickCount
            this()
            this.EndTime := A_TickCount
            G['TxtDurationValue'].Text := Round((this.EndTime - this.StartTime) / 1000, 4)
        }

        HClickButtonStop(*) {
            this.Stop := 1
            this.__ShowTooltip('Stopping.')
        }

        HClickCheckboxDebug(Ctrl, *) {
            if Ctrl.Value {
                this.__ShowTooltip('Debug on!')
                this.Debug := true
            } else {
                this.Debug := false
                this.__ShowTooltip('Debug off!')
            }
        }
    }

    static __IncIndex(Name, n) {
        if !this.%Name%.Length {
            return 1
        }
        this.__SetIndex(Name, this.%Name%Index + n)
        this.G['EditJump_' Name].Text := this.%Name%Index
    }

    static __Initialize() {
        this.input := { find: 1, gt: 1, et: 1, bounds: 1, array: 1, fn: 1, count: 0 }
        this.Result := []
        this.Problem := []
        this.Result.Capacity := this.Problem.Capacity := 4000
        this.Paused := 1
        this.Finished := 0
        return
    }

    static __SetFonts(GuiOrCtrl, FontList) {
        for Font in FontList {
            GuiOrCtrl.SetFont(, Font)
        }
    }

    static __SetIndex(Name, Value) {
        if !this.%Name%.Length {
            return 1
        }
        Value := Number(Value)
        if (Diff := Value - this.%Name%.Length) > 0 {
            this.__%Name%Index := Diff
        } else if Value < 0 {
            this.__%Name%Index := this.%Name%.Length + Value + 1
        } else if Value == 0 {
            this.__%Name%Index := this.%Name%.Length
        } else if Value {
            this.__%Name%Index := Value
        }
    }

    static __ShowTooltip(Str) {
        static N := [1,2,3,4,5,6,7]
        Z := N.Pop()
        OM := CoordMode('Mouse', 'Screen')
        OT := CoordMode('Tooltip', 'Screen')
        MouseGetPos(&x, &y)
        Tooltip(Str, x, y, Z)
        SetTimer(_End.Bind(Z), -2000)
        CoordMode('Mouse', OM)
        CoordMode('Tooltip', OT)

        _End(Z) {
            ToolTip(,,,Z)
            N.Push(Z)
        }
    }

    static __UpdateArrayCtrl(ArrCopyObj) {
        if ArrCopyObj {
            k := ArrCopyObj.Start - 1
            while ++k <= ArrCopyObj.End - 1 {
                Str .= Format('{:5}', k) ' : ' ArrCopyObj.Arr[A_Index] '`r`n'
            }
            this.G['Array'].Text := Trim(Str, '`r`n')
        } else {
            this.G['Array'].Text := ''
        }
    }

    static __UpdateDisplay(ResultObj) {
        input := ResultObj.input
        Results := [
            ['Find index', ResultObj.FindIndex]
          , ['Expected index', ResultObj.ExpectedIndex]
          , ['Found index', ResultObj.FoundIndex]
          , ['Find value', ResultObj.FindValue]
          , ['Expected value' , ResultObj.ExpectedValue]
          , ['Found value', ResultObj.FoundValue]
          , ['IndexStart', this.Bounds[input.bounds].Start]
          , ['IndexEnd', this.Bounds[input.bounds].End]
          , ['GreaterThan', (this.GreaterThan[input.gt] ? 'true' : 'false')]
          , ['EqualTo', (this.EqualTo[input.et] ? 'true' : 'false')]
          , ['Direction', (input.array == 1 ? 1 : -1)]
          , ['Iteration', input.count]
          , ['Function index', input.fn]
          , ['Line number', ResultObj.LineNumber]
        ]
        GreatestKeyLen := 0
        for Pair in Results {
            if StrLen(Pair[1]) > GreatestKeyLen {
                GreatestKeyLen := StrLen(Pair[1])
            }
        }
        if CallbackValue := this.TestArray[1].CallbackValue {
            for Pair in Results {
                Str .= Format('{:' GreatestKeyLen '}', Pair[1]) ' : ' CallbackValue(Pair[2]) '`r`n'
            }
        } else {
            for Pair in Results {
                Str .= Format('{:' GreatestKeyLen '}', Pair[1]) ' : ' Pair[2] '`r`n'
            }
        }
        Str .= '`r`nDescription: ' . this.TestDescriptions[input.fn]
        this.G['Result'].Text := Str
        this.__UpdateArrayCtrl(ResultObj.Arr)
    }

    static __New() {
        FindIndices := this.FindIndices := [1, 2, 3, 4, 5, 9, 10, 11, 250, 499, 500, 501, 989, 990
        , 991, 994, 995, 996, 998, 999, 1000]
        StartIndices := [1, 100, 500, 900, 999]
        ; Offsets get added to the start indices to get the end indices.
        Offsets := [1, 2, 4, 5, 99, 100, 499, 500, 997, 998, 999]
        this.Len := 1000
        ; `Bounds` contains the actual start and end indices, each as an object with `{ Start, End }`
        ; properties.
        this.Bounds := []
        this.Bounds.Capacity := FindIndices.Length * Offsets.Length
        i := k := 0
        loop StartIndices.Length {
            i++
            loop Offsets.Length {
                if StartIndices[i] + Offsets[++k] <= 1000 {
                    this.Bounds.Push({ Start: StartIndices[i], End: StartIndices[i] + Offsets[k] })
                }
            }
            k := 0
        }
        this.Bounds.Capacity := this.Bounds.Length
        ; First test array ascends, second test array descends.
        this.TestArrayOriginalNumber := [[], []]
        _ProcessTestArray(-500, 1, this.TestArrayOriginalNumber[1])
        _ProcessTestArray(500, -1, this.TestArrayOriginalNumber[2])
        this.SetSortType(CONTAINER_SORTTYPE_NUMBER)
        this.Functions := []

        return

        _ProcessTestArray(StartValue, Direction, TestArr) {
            k := 1
            v := StartValue + Direction * -1
            TestArr.Length := this.Len
            loop this.Len {
                v += Direction
                if Random() <= 0.85 {
                    TestArr[A_Index] := v
                }
            }
        }
    }

    static __ResultIndex := 0
    static ResultIndex {
        Get => this.__ResultIndex
        Set => this.__SetIndex('Result', Value)
    }

    static __ProblemIndex := 0
    static ProblemIndex {
        Get => this.__ProblemIndex
        Set => this.__SetIndex('Problem', Value)
    }

    ; various flags
    static Paused := 0
    , Stop := 0
    , Finished := 0
    , GuiActive := 0
    , DebugPause := false

    static BtnCtrlNames := ['Start', 'Pause', 'Stop', 'Exit', 'Reload', 'Clear', 'ListLines']
    , GreaterThan := [false, true]
    , EqualTo := [false, true]

    static TestDescriptions := [
        'Searches for the value at the indicated index, and the value is present at the index.'
      , 'Searches for the value at the indicated index, and the value is present both at the indicated index, and on adjacent indices.'
      , 'Searches for the value at the indicated index, and the value absent from the array.'
    ]
}
