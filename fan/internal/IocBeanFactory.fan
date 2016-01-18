using afBeanUtils
using afIoc

internal class IocBeanFactory : BeanFactory {
	
	private |->Scope|	scope
	
	new make(Type type, |This|in) : super(type) { 
		in(this)
	}

	override Obj doCreate(Method? ctor := null) {
		// try our luck at a default value...
		if (ctor == null && ctorArgs.isEmpty) {
			defVal := BeanFactory.makeFromDefaultValue(type)
			if (defVal != null)
				return setFieldVals(defVal)
		}

		if (ctor != null)
			return super.doCreate(ctor)
			
		return scope().build(type, ctorArgs, fieldVals)
	}
	
	private Obj? setFieldVals(Obj? obj) {
		fieldVals.each |val, field| { field.set(obj, val) }
		return obj
	}
}
