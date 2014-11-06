using afPlastic
using afIoc
using afBedSheet
using afEfanXtra

@NoDoc
const class FormBeanModule {
	
	static Void defineServices(ServiceDefinitions defs) {
		defs.add(InputSkins#)
		defs.add(OptionsProviders#)
	}
	
	@Contribute { serviceType=InputSkins# }
	static Void contributeInputSkins(Configuration config) {
		textInputSkin		:= TextInputSkin()
		config["text"] 		= textInputSkin
		config["date"] 		= textInputSkin
		config["datetime"]	= textInputSkin
		config["email"]		= textInputSkin
		config["hidden"] 	= textInputSkin
		config["month"]		= textInputSkin
		config["number"] 	= textInputSkin
		config["password"] 	= textInputSkin
		config["range"] 	= textInputSkin
		config["search"] 	= textInputSkin
		config["tel"] 		= textInputSkin
		config["time"] 		= textInputSkin
		config["url"] 		= textInputSkin
		config["week"] 		= textInputSkin
		config["checkbox"]	= CheckboxSkin()
		config["textarea"]	= TextAreaSkin()
		config["select"]	= config.autobuild(SelectSkin#)
//		config["button"]	= 
//		config["color"]		= 
//		config["file"]		= 
//		config["image"]		= 
//		config["radio"]		= 
//		config["reset"]		= 
//		config["submit"]	= 
	}
	
	@Contribute { serviceType=OptionsProviders# }
	static Void contributeOptionsProviders(Configuration config) {
		config[Enum#] = EnumOptionsProvider(true, "")
	}

	@Contribute { serviceType=ValueEncoders# }
	static Void contributeValueEncoders(Configuration config) {
		config[Bool#] = BoolEncoder()
	}

	@Contribute { serviceType=DependencyProviders# }
	static Void contributeDependencyProviders(Configuration config) {
		config.set("afFormBean.formBeanProvider", config.autobuild(FormBeanProvider#)).before("afIoc.serviceProvider")
	}

	@Contribute { serviceType=ComponentCompiler# }
	static Void contributeComponentCompilerCallbacks(Configuration config) {
		config["afFormBean"] = |Type comType, PlasticClassModel model| {
			comType.fields.each |field| {
				if (field.type.fits(FormBean#)) {
					inject	:= (Inject) Slot#.method("facet").callOn(field, [Inject#])	// Stoopid F4
					getCode :=	
								"""formBean := _efan_comCtxMgr.peek.getVariable(${field.name.toCode})
								   if (formBean == null) {
								   	formBean = _afFormBean_registry.autobuild(afFormBean::FormBean#, [${inject.type.qname}#])
								   	_efan_comCtxMgr.peek.setVariable(${field.name.toCode}, formBean)
								   }
								   return formBean"""					
					model.overrideField(field, getCode, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
					model.addField(Registry#, "_afFormBean_registry").addFacet(Inject#)
				}
			}
		}		
	}
}
