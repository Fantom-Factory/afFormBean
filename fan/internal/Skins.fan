using afIoc
using afBedSheet
using web

@NoDoc
abstract const class DefaultInputSkin : InputSkin {
	
	override Str render(SkinCtx skinCtx) {
		html	:= Str.defVal
		errCss	:= skinCtx.fieldInvalid ? " error" : Str.defVal
		hint	:= skinCtx.formField.hint
		html	+= """<div class="formBean-row inputRow ${skinCtx.name}${errCss}">"""
		html	+= """<label for="${skinCtx.name}">${skinCtx.label}</label>"""
		html	+= renderElement(skinCtx)
		if (hint != null)
			html += """<div class="formBean-hint">${hint}</div>"""				
		html	+= """</div>\n"""
		return html
	}
	
	abstract Str renderElement(SkinCtx skinCtx)
}

internal const class TextInputSkin : DefaultInputSkin {
	override Str renderElement(SkinCtx skinCtx) {
		"""<input type="${skinCtx.formField.type}" ${skinCtx.renderAttributes} value="${skinCtx.value}">"""
	}	
}

internal const class TextAreaSkin : DefaultInputSkin {
	override Str renderElement(SkinCtx skinCtx) {
		"""<textarea ${skinCtx.renderAttributes}>${skinCtx.value}</textarea>"""
	}	
}

internal const class CheckboxSkin : DefaultInputSkin {
	override Str renderElement(SkinCtx skinCtx) {
		formField	:= skinCtx.formField

		// null out attributes we don't want rendered
		formField.minLength	= null
		formField.maxLength	= null
		formField.min		= null
		formField.max		= null
		formField.step		= null
		formField.pattern	= null

		checked := (skinCtx.value == "true" || skinCtx.value == "on") ? " checked" : Str.defVal
		return """<input type="checkbox" ${skinCtx.renderAttributes}${checked}>"""
	}
}

internal const class SelectSkin : DefaultInputSkin {
	@Inject private const	ValueEncoders		valueEncoders
	@Inject private const	OptionsProviders	optionsProviders

	new make(|This| in) { in(this) }
	
	override Str renderElement(SkinCtx skinCtx) {
		formField	:= skinCtx.formField

		// null out attributes we don't want rendered
		formField.minLength	= null
		formField.maxLength	= null
		formField.min		= null
		formField.max		= null
		formField.step		= null
		formField.pattern	= null

		html	:= "<select ${skinCtx.renderAttributes}>"

		optionsProvider := formField.optionsProvider ?: optionsProviders.find(skinCtx.field.type)

		showBlank := formField.showBlank ?: optionsProvider.showBlank(formField)
		if (showBlank) {
			blankLabel := formField.blankLabel ?: optionsProvider.blankLabel(formField)
			html += """<option value="">${blankLabel?.toXml}</option>"""
		}
		
		optionsProvider.options(formField).each |value, label| {
			optLabel := formField.msg("option.${label}.label") ?: label
			optValue := skinCtx.toClient(value)
			optSelec := (optValue.equalsIgnoreCase(skinCtx.value)) ? " selected" : Str.defVal
			html += """<option value="${optValue}"${optSelec}>${optLabel}</option>"""
		}

		html	+= "</select>"
		return html
	}
}

internal const class DefaultErrorSkin : ErrorSkin {
	
	override Str render(FormBean formBean) {
		if (!formBean.hasErrors) return Str.defVal
		buf := StrBuf()
		out := WebOutStream(buf.out)

		banner := formBean.messages["errors.msg"]
		out.div("class='formBean-errors'")
		out.div("class='formBean-banner'").w(banner).divEnd
		out.ul
		
		// don't encode err msgs, let the user specify HTML
		formBean.errorMsgs.each { 
			out.li.w(it).liEnd			
		}
		formBean.formFields.vals.each {
			if (it.errMsg != null)
				out.li.w(it.errMsg).liEnd
		}
		out.ulEnd
		out.divEnd
		return buf.toStr
	}
}