
internal const class SemiDefaultInspector : FieldInspector {
	
	override FormField? inspect(FormBean formBean, Field field) {
		formBean.formFields[field]?.with {
			// a 'required' checkbox means it *has* to be checked - usually not what we want by default
			if (required == null && field.type.isNullable.not && field.type != Bool#)
				required = true

			if (type == null && field.type == Bool#)
				type = "checkbox"

			if (type == null && field.type.fits(Enum#))
				type = "select"
			
			if (type == null && field.name.lower.contains("email"))
				type = "email"

			if (type == null && field.name.lower.contains("password"))
				type = "password"

			if (type == null && (field.name == "url" || field.name == "uri" || field.name.endsWith("Url") || field.name.endsWith("Uri")))
				type = "url"

			if (type == null && field.type.fits(Date#))
				type = "date"

			if (type == null && field.type.fits(DateTime#))
				type = "datetime-local"

			if (type == null && (field.type.fits(File#) || field.type.fits(Buf#) || field.type.fits(InStream#)))
				type = "file"
		}		
	}
}
