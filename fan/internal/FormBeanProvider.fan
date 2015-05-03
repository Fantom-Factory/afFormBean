using afIoc

internal const class FormBeanProvider : DependencyProvider {
	
	@Inject private const Registry registry
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
//		return injectionCtx.dependencyType.fits(FormBean#) && !injectionCtx.fieldFacets.findType(Inject#).isEmpty
		
		if (injectionCtx.dependencyType.fits(FormBean#))
			if (!injectionCtx.fieldFacets.findType(Inject#).isEmpty)
				return true
		return false
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		type := ((Inject) injectionCtx.fieldFacets.findType(Inject#).first).type
		return registry.autobuild(FormBean#, [type])
	}
}