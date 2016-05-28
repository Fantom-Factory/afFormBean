
** Implement to provide options to be rendered in '<select>' tags. 'OptionsProviders' are used by the default skin for '<select>' tags.
** 
** The 'FormBean' libraries caters for 'Enum' values but sometimes you want the user to choose from a list supplied from a database, or config file.
** In these scenarios you can supply your own 'OptionsProvider'.
** 
** Options providers may be either be set directly on a form field or contributed to the 'OptionsProviders' service.
** Options providers are selected based on the field's type.
** 
**   syntax: fantom
** 
**   @Contribute { serviceType=OptionsProviders# }
**   static Void contributeOptionsProviders(Configuration config) {
**       config[MyValue#] = MyValueOptionsProvider()
**   }
** 
const mixin OptionsProvider {
	
	** Return 'true' if the '<select>' should show a blank value at the start of the options list.
	** 
	** Default behaviour is to return '!formField.required'.
	virtual Bool showBlank(FormField formField) {
		(formField.required ?: false).not
	}
	
	** The label to display in the blank option, should 'showBlank' return 'true'. 
	** 
	** Default behaviour is to return an empty string.
	virtual Str? blankLabel(FormField formField) { "" }
	
	** A map of option values to display, keyed on the display label. 
	** The returned map should be ordered.
	** 
	** 'bean' is the bean instance being rendered.
	abstract Str:Obj options(FormField formField, Obj bean)
}
