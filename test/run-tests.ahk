
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


test()

test() {
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
