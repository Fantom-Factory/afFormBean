using afBeanUtils

@NoDoc	// Don't overwhelm the masses!
const class InputSkins {
	
	private const Str:InputSkin	skins
	
	new make(Str:InputSkin skins, |This| in) {
		this.skins = skins
		in(this)
	}

	InputSkin? find(Str type, Bool checked := true) {
		skins[type] ?: (checked ? throw ArgNotFoundErr("InputSkin not found: ${type}", skins.keys) : null)
	}
}



