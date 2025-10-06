
#include test-DatePreprocess.ahk
#include test-example-HasValue.ahk
#include test-example-SetCallbackValue.ahk
#include test-Find.ahk
#include test-FindInequalitySparse.ahk
#include test-InsertIfAbsent.ahk
#include test-misc-examples.ahk
#include test-misc.ahk
#include test-readme-examples.ahk
#include test-SetSortType-examples.ahk
#include test-Sort.ahk

if A_LineFile == A_ScriptFullPath {
    Container_RunTests(true)
}

Container_RunTests(tooltips := false) {
    if tooltips {
        om := CoordMode('Mouse', 'Screen')
        ot := CoordMode('ToolTip', 'Screen')
        ShowTooltip('Starting DatePreprocess')
        test_DatePreprocess()
        ShowTooltip('Starting HasValue')
        test_HasValue()
        ShowTooltip('Starting SetCallbackValue')
        test_SetCallbackValue()
        ShowTooltip('Starting Find')
        test_Find()
        ShowTooltip('Starting FindInequalitySparse.TestAll')
        test_FindInequalitySparse.TestAll()
        ShowTooltip('Starting InsertIfAbsent')
        test_InsertIfAbsent()
        ShowTooltip('Starting miscExamples')
        test_miscExamples()
        ShowTooltip('Starting misc')
        test_misc()
        ShowTooltip('Starting ReadmeExamples')
        test_ReadmeExamples()
        ShowTooltip('Starting SetSortTypeExamples')
        test_SetSortTypeExamples()
        ShowTooltip('Starting Sort')
        test_Sort()
        ShowTooltip('Done')
        CoordMode('Mouse', om)
        CoordMode('ToolTip', ot)
    } else {
        test_DatePreprocess()
        test_HasValue()
        test_SetCallbackValue()
        test_Find()
        test_FindInequalitySparse.TestAll()
        test_InsertIfAbsent()
        test_miscExamples()
        test_misc()
        test_ReadmeExamples()
        test_SetSortTypeExamples()
        test_Sort()
    }

    ShowTooltip(Str) {
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
}
