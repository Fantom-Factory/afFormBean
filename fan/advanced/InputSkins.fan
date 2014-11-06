using afBeanUtils

@NoDoc	// Don't overwhelm the masses!
const class InputSkins {
	
	private const Str:InputSkin	skins
	
	new make(Str:InputSkin	skins, |This| in) {
		this.skins = skins
		in(this)
	}

	Str render(SkinCtx skinCtx) {
		skin := skins[skinCtx.input.type] ?: throw ArgNotFoundErr("FormBean Skin not found: ${skinCtx.input.type}", skins.keys)
		return skin.render(skinCtx)
	}

	InputSkin find(Str type) {
		skins[type]
	}
}



