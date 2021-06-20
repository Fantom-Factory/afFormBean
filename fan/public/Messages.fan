using afConcurrent::AtomicMap

** (Service) - 
** Creates a map of messages by merging together property files. 
** Property files are looked for in the following locations:
** 
**  - 'FormBean.props' in pod 'afFormBean'
**  - 'FormBean.props' in pod '<pod>'
**  - '<bean>.props' in pod '<pod>'
** 
** Messages override those defined previously.
** 
** Note that message maps are cached on the given bean type, so hit of collating '.props' files is 
** only taken once per bean type. 
** 
** 'Messages' also takes contributions of string Maps:
** 
** pre>
** syntax: fantom
** @Contribute { serviceType=Messages# }
** Void contributeMessages(Configuration config) {
**     config.add([
**         "loginDetails.username.label"  : "Username:",
**         "loginDetails.password.label"  : "Password:"
**     ])
** }
** <pre
const mixin Messages {

	** Returns messages for the given bean.
	@Operator
	abstract Str:Str getMessages(Type beanType)
	
	** Clears the message cache.
	abstract Void clear()
}

internal const class MessagesImpl : Messages {
	private const AtomicMap messages 
	private const Str:Str 	defaultMsgs
	private const Str:Str	contributedMsgs

	new make([Str:Str][] msgs) {
		contributedMsgs := Str:Str[:] { caseInsensitive=true }
		msgs.each { contributedMsgs.setAll(it) }

		this.contributedMsgs = contributedMsgs
		this.defaultMsgs	 = this.typeof.pod.files.find { matches(it, "FormBean") } .readProps
		this.messages		 = AtomicMap { keyType=Type#; valType=[Str:Str]# }
	}
	
	@Operator
	override Str:Str getMessages(Type beanType) {
		((Str:Str) messages.getOrAdd(beanType) |->Str:Str| {
			msgs 		:= Str:Str[:] { caseInsensitive = true }
			try {
				// TODO use Fantom's locale lookup... somehow, see http://fantom.org/doc/sys/Env#locale
				// can only get single props, not the whole file, so add locale to getMessage
				// or just look for more files using the same rules (better)
				// pass in Locale locale := Locale.cur()
				formBeanMsgs := beanType.pod.files.find { matches(it, "FormBean")	}?.readProps ?: [:]
				beanTypeMsgs := beanType.pod.files.find { matches(it, beanType.name)}?.readProps ?: [:]
				tempMsgs	 := Str:Str[:] { caseInsensitive=true }
					.setAll(defaultMsgs)
					.setAll(contributedMsgs)
					.setAll(formBeanMsgs)
					.setAll(beanTypeMsgs)
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
	
	override Void clear() {
		messages.clear
	}
	
	private Bool matches(File file, Str baseName) {
		file.basename.equalsIgnoreCase(baseName) && file.ext != null && (file.ext.equalsIgnoreCase("props") || file.ext.equalsIgnoreCase("properties"))
	}
}
