using afConcurrent

internal const class Messages {
	private const AtomicMap messages	:= AtomicMap { keyType=Type#; valType=[Str:Str]# }
	private const Str:Str 	defaultMsgs
	
	new make(|This| in) {
		in(this)
		defaultMsgs = this.typeof.pod.files.find { matches(it, "FormBean") } .readProps		
	}
	
	@Operator
	Str:Str getMessages(Type beanType) {
		((Str:Str) messages.getOrAdd(beanType) |->Str:Str| {
			msgs 		:= Str:Str[:] { caseInsensitive = true }
			try {
				// TODO use Fantom's locale lookup... somehow, see http://fantom.org/doc/sys/Env#locale
				// can only get single props, not the whole file, so add locale to getMessage
				// or just look for more files using the same rules (better)
				// pass in Locale locale := Locale.cur()
				formBeanMsgs :=    beanType.pod.files.find { matches(it, "FormBean")	}?.readProps ?: [:]
				beanTypeMsgs :=    beanType.pod.files.find { matches(it, beanType.name)	}?.readProps ?: [:]
				tempMsgs	 := Str:Str[:] { caseInsensitive=true }.setAll(defaultMsgs).setAll(formBeanMsgs).setAll(beanTypeMsgs)
				beanName 	 := beanType.name.lower + "."

				tempMsgs.each |Str v, Str k| {
					if (k.lower.startsWith(beanName)) {
						msgs[k[beanName.size..-1]] = v
						return
					}

					// don't overwrite a keys set via beanName above
					if (!msgs.containsKey(k))
						msgs[k] = v
				}
				return msgs

			} catch (Err err) {
				// Guard against being run in a script - an Err is thrown when not backed by a pod file
				if (err.msg.startsWith("Not backed by pod file"))
					return Str:Str[:] { caseInsensitive = true }.addAll(defaultMsgs)
				throw err
			}
		}).rw
	}
	
	private Bool matches(File file, Str baseName) {
		file.basename.equalsIgnoreCase(baseName) && (file.ext.equalsIgnoreCase("props") || file.ext.equalsIgnoreCase("properties"))
	}
}
