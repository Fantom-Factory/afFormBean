using afIoc
using afBedSheet

internal const class HtmlInputInspector : FieldInspector {
	
	@Inject private const	ObjCache	_objCache
	@Inject private const	|->Scope|	_scope

	new make(|This|in) { in(this) }
	
	override FormField? inspect(FormBean formBean, Field field) {
		if (field.hasFacet(HtmlInput#).not)
			// guard against someone else creating a bean before us
			return formBean.formFields[field]

		input := (HtmlInput?) field.facet(HtmlInput#, false)

		// populate formField objects with any non-null values, minus any default values
		// 'null' is a useful indicator of where a default will be applied, 
		// meaning we can infer when to use semi-default values such as 'required' for non-nullable fields
		return ((FormField) _scope().build(FormField#, null, [
			FormField#field	 	: field,
			FormField#formBean	: formBean
		])) {
			it.valueEncoder		= fromObjCache(input.valueEncoder	 ?: fieldMsg(it, "valueEncoder"))
			it.inputSkin		= fromObjCache(input.inputSkin 		 ?: fieldMsg(it, "inputSkin"))
			it.optionsProvider	= fromObjCache(input.optionsProvider ?: fieldMsg(it, "optionsProvider"))
			it.type				= input.type		?: fieldMsg(it, "type"			)
			it.label			= input.label		?: fieldMsg(it, "label"			)
			it.placeholder		= input.placeholder	?: fieldMsg(it, "placeholder"	)
			it.hint				= input.hint		?: fieldMsg(it, "hint"			)
			it.css				= input.css			?: fieldMsg(it, "css"			)
			it.attributes		= input.attributes	?: fieldMsg(it, "attributes"	)
			it.viewOnly			= input.viewOnly	?: fieldMsg(it, "viewOnly"		)?.toBool
			it.required			= input.required	?: fieldMsg(it, "required"		)?.toBool
			it.minLength		= input.minLength	?: fieldMsg(it, "minLength"		)?.toInt
			it.maxLength		= input.maxLength	?: fieldMsg(it, "maxLength"		)?.toInt
			it.min				= input.min			?: fieldMsg(it, "min"			)?.toInt
			it.max				= input.max			?: fieldMsg(it, "max"			)?.toInt
			it.pattern			= input.pattern		?: fieldMsg(it, "pattern"		)?.toRegex
			it.step				= input.step		?: fieldMsg(it, "step"			)?.toInt
			it.showBlank		= input.showBlank	?: fieldMsg(it, "showBlank"		)?.toBool
			it.blankLabel		= input.blankLabel	?: fieldMsg(it, "blankLabel"	)
		}
	}
	
	Str? fieldMsg(FormField formField, Str key) {
		formField.formBean.fieldMsg(formField, key)
	}
	
	private Obj? fromObjCache(Obj? what) {
		if (what is Str)
			what = Type.find(what)
		if (what is Type)
			return _objCache[what]
		return null
	}
}
