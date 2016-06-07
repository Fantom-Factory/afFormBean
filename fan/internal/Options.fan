
internal const class EnumOptionsProvider : OptionsProvider {

	override Str:Obj options(FormField formField, Obj? bean) {
		vals := (Enum[]) formField.field.type.field("vals").get
		return Str:Obj[:] { ordered=true }.addList(vals) |Enum enm->Str| { enm.name.toDisplayName }
	}
}
