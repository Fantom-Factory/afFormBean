using afIoc

internal const class FormBeanProvider : DependencyProvider {
	
	@Inject private const Registry registry
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
		injectionCtx.dependencyType.fits(FormBean#) && !injectionCtx.fieldFacets.findType(Inject#).isEmpty
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		type := ((Inject) injectionCtx.fieldFacets.findType(Inject#).first).type
		return registry.autobuild(FormBean#, [type])
	}
}