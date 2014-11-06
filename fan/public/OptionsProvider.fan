
** Implement to provide options to be rendered in '<select>' tags. 'OptionsProviders' are used by the default skin for '<select>' tags.
** 
** The 'FormBean' libraries caters for 'Enum' values but sometimes you want the user to choose from a list supplied from a database, or config file.
** In these scenarios you can supply your own 'OptionsProvider'.
** 
** Options providers may be either be set directly on a form field or contributed to the 'OptionsProviders' service.
** Options providers are selected based on the field's type.
** 
**   @Contribute { serviceType=OptionsProviders# }
**   static Void contributeOptionsProviders(Configuration config) {
**       config[MyValue#] = MyValueOptionsProvider()
**   }
** 
const mixin OptionsProvider {
	
	** Return 'true' if the '<select>' should show a blank value at the start of the options list.
	abstract Bool showBlank()
	
	** The label to display in the blank option, should 'showBlank' return 'true'. 
	abstract Str? blankLabel()
	
	** A map of option values to display, keyed on the display label. 
	** The returned map should be ordered.
	abstract Str:Obj options(Field field)
}
