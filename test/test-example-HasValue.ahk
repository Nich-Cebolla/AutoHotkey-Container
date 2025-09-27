
#include ..\src\Container.ahk

test_HasValue() {
    c := Container(
        { Name: "obj4" }
      , { Name: "obj1" }
      , { Name: "obj3" }
      , { Name: "obj2" }
    )
    _Compare(c.HasValue("obj1", (value) => value.Name), 2)
    _Compare(c.HasValue("obj5", (value) => value.Name), 0)
    c := Container(
        { Name: "obj4" }
      ,
      ,
      , { Name: "obj2" }
    )
    _Compare(c.HasValueSparse("obj1", (value) => value.Name), 0)
    _Compare(c.HasValueSparse("obj2", (value) => value.Name), 4)

    _Compare(value, expected) {
        if value != expected {
            throw Error('Invalid return value.', , 'value: ' value '; expected: ' expected)
        }
    }
}
