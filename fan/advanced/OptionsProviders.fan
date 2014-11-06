using afBeanUtils

@NoDoc
const mixin OptionsProviders {
	abstract OptionsProvider find(Type type)
}

internal const class OptionsProvidersImpl : OptionsProviders {
	private const TypeLookup providers
	
	new make(Type:OptionsProvider providers, |This| in) {
		this.providers = CachingTypeLookup(providers)
		in(this)
	}
	
	override OptionsProvider find(Type type) {
		providers.findParent(type)
	}
}
