using afIoc

internal const class FormBeanProvider : DependencyProvider {
	
	@Inject private const |->Scope| scope
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(Scope currentScope, InjectionCtx ctx) {
		if (!ctx.isFieldInjection)
			return false

		if (!ctx.field.hasFacet(Inject#))
			return false

		if (!ctx.field.type.fits(FormBean#))
			return false

		return true
	}

	override Obj? provide(Scope currentScope, InjectionCtx ctx) {
		inject := (Inject) ctx.field.facet(Inject#)
		return scope().build(FormBean#, [inject.type])
	}
}
