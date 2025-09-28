

class ContainerConstructor {
    /**
     * @param {Container} ContainerObj - A {@link Container} object that will be used as a template
     * for future {@link Container} objects constructed by this {@link ContainerConstructor}. This
     * allows you to set up one {@link Container} instance with the intended properties, and then
     * reuse the same setup any number of times without needing to redefine the same options.
     *
     * @param {Boolean} [InheritFromTemplate = false] - If true, `ContainerObj` is set to property
     * {@link ContainerConstructor#Template} directly. Whenever your code calls
     * {@link ContainerConstuctor.Prototype.Call}, the new {@link Container} instance will inherit
     * from {@link ContainerConstructor#Template}. This means that changes to the template will be
     * reflected in all {@link Container} objects which inherit from that template. It also complicates
     * the process of changing the sort type of the container. The benefit of inheriting from the
     * template is simply to reduce memory usage from copying values. If your code will never need
     * to change the container's sort type then it should be safe to allow new instances to inherit
     * from the template.
     *
     * If true, your code should not use the object passed to `ContainerObj` because any changes to
     * it will be reflected in all of the objects that inherit from it.
     *
     * If false, a new {@link Container} object is created and set to property
     * {@link ContainerConstructor#Template}. The own properties of `ContainerObj` are copied onto
     * the template. Whenever your code calls {@link ContainerConstuctor.Prototype.Call}, a new
     * {@link Container} object is created and the properties from {@link ContainerConstructor#Template}
     * are copied onto the new instance. All {@link Container} objects are separate; changes to one
     * will not impact any of the others. However, keep in mind that if `ContainerObj` has an own
     * property with an object value, then all copies will have the same object value for that
     * property (not a clone). So changes to that object will be reflected on all {@link Container}
     * objects created from that template.
     *
     * @example
     *  c := Container()
     *  c.Prop := { prop: "val" }
     *  constructor := ContainerConstructor(c)
     *  c2 := constructor()
     *  OutputDebug(c2.Prop.prop "`n") ; val
     *  OutputDebug(c.Prop.prop "`n") ; val
     *  c2.Prop.prop := "not val"
     *  OutputDebug(c2.Prop.prop "`n") ; not val
     *  OutputDebug(c.Prop.prop "`n") ; not val
     * @
     */
    __New(ContainerObj, InheritFromTemplate := false) {
        if InheritFromTemplate {
            this.Template := ContainerObj
        } else {
            template := this.Template := Container()
            for prop in ContainerObj.OwnProps() {
                template.DefineProp(prop, ContainerObj.GetOwnPropDesc(prop))
            }
        }
        this.InheritFromTemplate := InheritFromTemplate
    }
    Call(Values?) {
        if IsSet(Values) {
            c := Container(Values*)
        } else {
            c := Container()
        }
        if this.InheritFromTemplate {
            ObjSetBase(c, this.Template)
        } else {
            template := this.Template
            for prop in template.OwnProps() {
                c.DefineProp(prop, template.GetOwnPropDesc(prop))
            }
        }
        return c
    }
}
