using afConcurrent

internal const class Messages {
	private const AtomicMap messages := AtomicMap { keyType=Type#; valType=[Str:Str]# }
	
	new make(|This| in) { in(this) }
	
	Str:Str getMessages(Type beanType) {
		((Str:Str) messages.getOrAdd(beanType) |->Str:Str| {
			msgs 		:= Str:Str[:] { caseInsensitive = true }
			defaultMsgs := this.typeof.pod.files.find { it.name == "FormBean.properties" } .readProps
			try {
				// TODO: use Fantom's locale lookup... somehow
				formBeanMsgs :=    beanType.pod.files.find { it.name == "FormBean.properties"			}?.readProps ?: [:]
				beanTypeMsgs :=    beanType.pod.files.find { it.name == "${beanType.name}.properties"	}?.readProps ?: [:]
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
			} catch {
				// Guard against being run in a script - an Err is thrown when not backed by a pod file
				return Str:Str[:] { caseInsensitive = true }.addAll(defaultMsgs)
			}
		}).rw
	}
}
