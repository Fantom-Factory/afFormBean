
** Place on the field of a Fantom object / form bean if it should be rendered as HTML '<input>' tag.  
facet class HtmlInput {
	
	** The type of input to render. This value is used to select the skin used to render the input.
	const Str	type	:= "text"
	
	** The label to display next to the '<input>'.
	**  
	** If 'null' then the key 'field.${fieldName}.label' is used to look for a message. 
	const Str?	label

	** The value to render as a 'placeholder' attribute on the '<input>'.
	**  
	** If 'null' then the key 'field.${fieldName}.placeholder' is used to look for a message. 
	const Str?	placeholder
	
	** If non-null an extra '<div>' is rendered after the '<input>' to supply a helpful hint.
	** The hint is usually rendered with the 'formBean-hint' CSS class.
	** 
	** If 'null' then the key 'field.${fieldName}.hint' is used to look for a message. 
	const Str?	hint
	
	** The value to render as a CSS 'class' attribute on the '<input>'. 
	const Str?	css
	
	** Any other miscellaneous attributes that should be rendered on the '<input>'. 
	const Str?	attributes
	
	** The 'ValueEncoder' (type) used to convert the field value to and from a 'Str'.
	** 'ValueEncoders' are autobuilt and cached by IoC.
	** 
	** If 'null' then a default 'ValueEncoder' based on the field type is chosen from BedSheet's 'ValueEncoders' service. 
	const Type?	valueEncoder
	
	** The 'InputSkin' (type) used to render the field to HTML.
	** 'InputSkins' are autobuilt and cached by IoC.
	**  
	** If 'null' then a default 'InputSkin' is chosen based on the '@HtmlInput.type' attribute. 	
	const Type?	inputSkin


	
	// TODO: move to @Validation?
	
	** HTML5 validation. Set to 'true' to mark the input as required.
	const Bool	required

	** HTML5 validation. Sets the minimum length (inclusive) a string should be. 
	const Int?	minLength
	
	** HTML5 validation. Sets the maximum length (inclusive) a string should be.
	const Int?	maxLength
	
	** HTML5 validation. Sets the minimum value (inclusive) an 'Int' should have.
	const Int?	min
	
	** HTML5 validation. Sets the maximum value (inclusive) an 'Int' should have.
	const Int?	max
	
	** HTML5 validation. Sets a regular expression that the (stringified) value should match.
	** Starting '^' and ending '$' characters are implicit and not required.
	** 
	** Maps to the HTML5 'pattern' attribute.
	** 
	** Expressed as a Str because Regex's are not serialisable in Fantom 1.0.66.
	const Str?	pattern 
	
	** HTML5 validation.
	const Int?	step

	
	
	** Used by the '<select>' renderer. 
	** Set to 'true' to show a blank value at the start of the options list.
	** 
	** leave as null to use 'OptionsProvider.showBlank' value.
	const Bool?	showBlank
	
	** Used by the '<select>' renderer. 
	** This is the label to display in the blank option.
	** 
	** leave as null to use 'OptionsProvider.blankLabel' value.
	const Str?	blankLabel

	** Used by the '<select>' renderer. 
	** The 'OptionsProvider' to use to provide, um, options!
	** 'OptionsProvider' are autobuilt and cached by IoC.
	** 
	** leave as null to use a default.
	const Type?	optionsProvider
}
