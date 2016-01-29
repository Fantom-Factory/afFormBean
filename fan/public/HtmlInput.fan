
** Place on the field of a Fantom object / form bean if it should be rendered as HTML '<input>' tag.  
facet class HtmlInput {
	
	** The type of input to render. This value is used to select the skin used to render the input.
	** 
	** If 'null' then the msg key '<bean>.<field>.type' is used to look for a value. 
	** Defaults to 'text' if not found.
	const Str?	type
	
	** The label to display next to the '<input>'.
	**  
	** If 'null' then the msg key '<bean>.<field>.label' is used to look for a value. 
	** Defaults to a human readable version of the field name if not found. 
	const Str?	label

	** The value to render as a 'placeholder' attribute on the '<input>'.
	**  
	** If 'null' then the msg key '<bean>.<field>.placeholder' is used to look for a value. 
	const Str?	placeholder

	** If non-null an extra '<div>' is rendered after the '<input>' to supply a helpful hint.
	** The hint is usually rendered with the 'formBean-hint' CSS class.
	** 
	** If 'null' then the msg key '<bean>.<field>.hint' is used to look for a value. 
	const Str?	hint
	
	** The value to render as a CSS 'class' attribute on the '<input>'. 
	** 
	** If 'null' then the msg key '<bean>.<field>.css' is used to look for a value. 
	const Str?	css
	
	** Any other miscellaneous attributes that should be rendered on the '<input>'. 
	** Example:
	** 
	**   attributes = "autocomplete='off'"
	** 
	** If 'null' then the msg key '<bean>.<field>.attributes' is used to look for a value. 
	const Str?	attributes
	
	** The 'ValueEncoder' (type) used to convert the field value to and from a 'Str'.
	** 'ValueEncoders' are autobuilt and cached by IoC.
	** 
	** If 'null' then the msg key '<bean>.<field>.valueEncoder' is used to look for a value. 
	** Defaults to using BedSheet's 'ValueEncoders' service if not found. 
	const Type?	valueEncoder
	
	** The 'InputSkin' (type) used to render the field to HTML.
	** 'InputSkins' are autobuilt and cached by IoC.
	**  
	** If 'null' then the msg key '<bean>.<field>.inputSkin' is used to look for a value. 
	** Defaults a lookup using '@HtmlInput.type' if not found. 	
	const Type?	inputSkin

	** If 'true' then the field is rendered into the HTML form as normal, but no attempt is made 
	** to validate the form value or decode it to a Fantom value. 
	** 
	** Useful for rendering static, read only, HTML associated with the field.
	**  
	** If 'null' then the msg key '<bean>.<field>.viewOnly' is used to look for a value. 
	const Bool? viewOnly



	// ---- HTML5 Validation Options --------------------------------------------------------------
	
	** HTML5 validation. Set to 'true' to mark the input as required.
	** 
	** If 'null' then the msg key '<bean>.<field>.required' is used to look for a value. 
	** If still not found then the input is deemed required if the field is non-nullable.
	const Bool?	required

	** HTML5 validation. Sets the minimum length (inclusive) a string should be. 
	** 
	** If 'null' then the msg key '<bean>.<field>.minLength' is used to look for a value. 
	const Int?	minLength
	
	** HTML5 validation. Sets the maximum length (inclusive) a string should be.
	** 
	** If 'null' then the msg key '<bean>.<field>.maxLength' is used to look for a value. 
	const Int?	maxLength

	** HTML5 validation. Sets the minimum value (inclusive) an 'Int' should have.
	** 
	** If 'null' then the msg key '<bean>.<field>.min' is used to look for a value. 
	const Int?	min
	
	** HTML5 validation. Sets the maximum value (inclusive) an 'Int' should have.
	** 
	** If 'null' then the msg key '<bean>.<field>.max' is used to look for a value. 
	const Int?	max
	
	** HTML5 validation. Sets a regular expression that the (stringified) value should match.
	** Starting '^' and ending '$' characters are implicit and not required.
	** 
	** If 'null' then the msg key '<bean>.<field>.pattern' is used to look for a value. 
	const Regex?	pattern 
	
	** HTML5 validation. Defines number intervals for a numeric input.
	** 
	** If 'null' then the msg key '<bean>.<field>.step' is used to look for a value. 
	const Int?	step

	
	
	// ---- Select Options ------------------------------------------------------------------------
	
	** Used by the '<select>' renderer. 
	** Set to 'true' to show a blank value at the start of the options list.
	** 
	** If 'null' then the msg key '<bean>.<field>.showBlank' is used to look for a value. 
	** 
	** leave as null to use 'OptionsProvider.showBlank' value.
	const Bool?	showBlank
	
	** Used by the '<select>' renderer. 
	** This is the label to display in the blank option.
	** 
	** If 'null' then the msg key '<bean>.<field>.blankLabel' is used to look for a value. 
	** 
	** leave as null to use 'OptionsProvider.blankLabel' value.
	const Str?	blankLabel

	** Used by the '<select>' renderer. 
	** The 'OptionsProvider' to use to provide, um, options!
	** 'OptionsProvider' instances are autobuilt and cached by IoC.
	** 
	** If 'null' then the msg key '<bean>.<field>.optionsProvider' is used to look for a value. 
	** 
	** leave as null to use a default.
	const Type?	optionsProvider
}
