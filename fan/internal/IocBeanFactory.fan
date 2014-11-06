using afBeanUtils
using afIoc

internal class IocBeanFactory : BeanFactory {
	
	private Registry registry
	
	new make(Registry registry, Type type) : super(type) { 
		this.registry = registry
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
			
		return registry.autobuild(type, ctorArgs, fieldVals)
	}
	
	private Obj? setFieldVals(Obj? obj) {
		fieldVals.each |val, field| { field.set(obj, val) }
		return obj
	}
}
