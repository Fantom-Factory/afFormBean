
const mixin OptionsProvider {
	abstract Bool showBlank()
	abstract Str? blankLabel()
	abstract Str:Obj options(Field field)
}
