
** Implement to define a renderer for a specific input type. 
** 
** Sometimes the default rendered HTML does not meet your needs, or is not enough. 
** In these cases you can define your own skin and render whatever HTML you like!
** 
** Skins may be either be set directly on a form field or contributed to the 'InputSkins' service.
** Skins are selected based on the field's '@HtmlInput.type' attribute.
** 
**   @Contribute { serviceType=InputSkins# }
**   static Void contributeInputSkins(Configuration config) {
**       config["tinytext"] = TinyTextSkin()
**   }
** 
** Default skins are provided for most of the HTML5 input types (text, email, select, etc...) and need to be overriden:
** 
**   @Contribute { serviceType=InputSkins# }
**   static Void contributeInputSkins(Configuration config) {
**       config.overrideValue("text", "text", MyTextSkin())
**   }
** 
const mixin InputSkin {
	
	** Render the input to HTML.
	abstract Str render(SkinCtx skinCtx)
}
