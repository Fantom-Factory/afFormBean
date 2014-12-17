
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
