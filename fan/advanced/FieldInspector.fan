
@NoDoc
const mixin FieldInspector {
	
	** Any existing 'FormField' may be retrieved with:
	** 
	**   syntax: fantom
	**   formBean.formFields[field]  // may be null
	** 
	abstract FormField? inspect(FormBean formBean, Field field)

}
