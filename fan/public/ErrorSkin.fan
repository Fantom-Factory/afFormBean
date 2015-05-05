
** Implement to define a renderer for form errors. 
** 
** To use your skin, define it as a service of type 'ErrorSkin':
** 
**   static Void defineServices(ServiceDefinitions defs) {
**       defs.add(ErrorSkin#, MyErrorSkin#)
**   }
** 
** The default error skin renders the following HTML:
** 
**   <div class='formBean-errors'>
**       <div class='formBean-banner'>#BANNER</div>
**       <ul>
**           <li> Error 1 </li>
**           <li> Error 2 </li>
**       </ul>
**   </div>
** 
** To change the banner message, set a message with the key 'errors.banner'.
const mixin ErrorSkin {
	
	** Renders form bean errors to HTML.
	abstract Str render(FormBean formBean)
}

