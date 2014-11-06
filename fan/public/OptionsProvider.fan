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

const mixin OptionsProvider {
	abstract Bool showBlank()
	abstract Str? blankLabel()
	abstract Str:Obj options(Field field)
}

@NoDoc
const class EnumOptionsProvider : OptionsProvider {
	override const Bool showBlank
	override const Str? blankLabel

	new make(Bool showBlank, Str? blankLabel) {
		this.showBlank	= showBlank
		this.blankLabel	= blankLabel
	}
	
	override Str:Obj options(Field field) {
		vals := (Enum[]) field.type.field("vals").get
		return Str:Obj[:] { ordered=true }.addList(vals) |Enum enm->Str| { enm.name.toDisplayName }
	}
}
