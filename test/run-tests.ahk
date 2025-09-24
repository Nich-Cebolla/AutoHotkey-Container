
#include test-FindInequalitySparse.ahk
#include test-Sort.ahk
#include test-Find.ahk
#include test-Misc.ahk


test()

test() {
    loop CONTAINER_SORTTYPE_STRINGPTR {
        test_FindInequalitySparse.SetSortType(A_Index)
        if result := test_FindInequalitySparse() {
            throw Error('FindInequalitySparse encountered a problem.', -1, 'Problem count: ' result)
        }
    }
    test_Sort()
    test_Find()
    test_Misc()
}
