
facet class HtmlInput {
	const Str	type	:= "text"
	const Str?	label
	const Str?	placeholder
	const Str?	hint
	const Str?	css
	
	** Any other miscellaneous attributes that should be rendered on the '<input>'. 
	const Str?	attributes
	
	const Type?	valueEncoder
	const Type?	inputSkin

	
	// TODO: move to @Validation?
	const Bool	required
	const Int?	minLength
	const Int?	maxLength
	const Int?	min
	const Int?	max
	const Str?	regex	// Regex's aren't serialisable in Fantom 1.0.66
	const Int?	step

	// for select
	const Bool?	showBlank
	const Str?	blankLabel
	const Type?	optionsProvider
}
