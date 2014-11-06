using afIoc
using afBedSheet

@NoDoc
abstract const class DefaultInputSkin : InputSkin {
	
	override Str render(SkinCtx skinCtx) {
		html	:= Str.defVal
		errCss	:= skinCtx.fieldInvalid ? " error" : Str.defVal
		hint	:= skinCtx.input.hint ?: skinCtx.msg("field.${skinCtx.name}.hint")
		html	+= """<div class="formBean-row inputRow ${skinCtx.name}${errCss}">"""
		html	+= """<label for="${skinCtx.name}">${skinCtx.label}</label>"""
		html	+= renderElement(skinCtx)
		if (hint != null)
			html += """<div class="formBean-hint">${hint}</div>"""				
		html	+= """</div>\n"""
		return html
	}
	
	Str attributes(SkinCtx skinCtx) {
		input	:= skinCtx.input
		pholder	:= skinCtx.input.placeholder ?: skinCtx.msg("field.${skinCtx.name}.placeholder")
		attrs	:= "id=\"${skinCtx.name}\" name=\"${skinCtx.name}\""
		if (input.css != null)
			attrs += " class=\"${input.css}\""
		if (pholder != null)
			attrs += " placeholder=\"${pholder}\""
		if (input.minLength != null)
			attrs += " minlength=\"${input.minLength}\" pattern=\".{${input.minLength},}\""
		if (input.maxLength != null)
			attrs += " maxlength=\"${input.maxLength}\""
		if (input.min != null)
			attrs += " min=\"${input.min}\""
		if (input.max != null)
			attrs += " max=\"${input.max}\""
		if (input.step != null)
			attrs += " step=\"${input.step}\""
		if (input.regex != null)
			attrs += " pattern=\"${input.regex.toXml}\""
		if (input.required)
			attrs += " required"
		
		// TODO: merge or override these attributes with what's just been processed
		// - don't blindly render the same attribute twice
		// - use Pegger to parse
		if (input.attributes != null)
			attrs += " ${input.attributes}"
		return attrs
	}
	
	abstract Str renderElement(SkinCtx skinCtx)
}

internal const class TextInputSkin : DefaultInputSkin {
	override Str renderElement(SkinCtx skinCtx) {
		"""<input type="${skinCtx.input.type}" ${attributes(skinCtx)} value="${skinCtx.value}">"""
	}	
}

internal const class TextAreaSkin : DefaultInputSkin {
	override Str renderElement(SkinCtx skinCtx) {
		"""<textarea ${attributes(skinCtx)}>${skinCtx.value}</textarea>"""
	}	
}

internal const class CheckboxSkin : DefaultInputSkin {
	override Str renderElement(SkinCtx skinCtx) {
		checked := (skinCtx.value == "true" || skinCtx.value == "on") ? " checked" : Str.defVal
		return """<input type="checkbox" ${attributes(skinCtx)}${checked}>"""
	}
}

internal const class SelectSkin : DefaultInputSkin {
	@Inject private const	ValueEncoders		valueEncoders
	@Inject private const	OptionsProviders	optionsProviders

	new make(|This| in) { in(this) }
	
	override Str renderElement(SkinCtx skinCtx) {
		html	:= "<select ${attributes(skinCtx)}>"

		optionsProvider := skinCtx.formField.optionsProvider ?: optionsProviders.find(skinCtx.field.type)

		showBlank := skinCtx.input.showBlank ?: optionsProvider.showBlank  
		if (showBlank) {
			blankLabel := skinCtx.input.blankLabel ?: optionsProvider.blankLabel  
			html += """<option value="">${blankLabel?.toXml}</option>"""
		}
		
		optionsProvider.options(skinCtx.field).each |value, label| {
			optLabel := skinCtx.msg("option.${label}.label") ?: label
			optValue := skinCtx.toClient(value)
			optSelec := (optValue.equalsIgnoreCase(skinCtx.value)) ? " selected" : Str.defVal
			html += """<option value="${optValue}"${optSelec}>${optLabel}</option>"""
		}

		html	+= "</select>"
		return html
	}
}
