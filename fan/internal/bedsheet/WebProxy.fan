using afIoc::Inject
using afIoc::Scope
using afBeanUtils::TypeCoercer
using concurrent::Actor

internal const class WebProxy {
	
	@Inject private const	Scope		scope
			private const	Obj?		valueEncoders
			private const	ObjCache 	objCache
			private const	TypeCoercer	typeCoercer	:= CachingTypeCoercer()

	new make(|This| f) {
		f(this)
		// use valueEncoders if it exists - no sweat if not
		valueEncoders	= scope.serviceById("afBedSheet::ValueEncoders", false)
		objCache		= scope.build(ObjCache#) 
	}

	** Only called from FormBean.validateHttpRequest()
	MimeType? reqContentType() {
		httpReq := httpReq
		if (httpReq != null)
			return httpReq->headers->contentType
		contType := webReq(true)->headers->get("Content-Type")
		return contType == null ? null : MimeType(contType)
	}
	
	** Only called from FormBean.validateHttpRequest()
	[Str:Str]? reqForm() {
		httpReq := httpReq
		if (httpReq != null)
			return httpReq->body->form
		return webReq(true)->form
	}
	
	** Only called from FormBean.validateHttpRequest()
	Void parseMultiPartForm(|Str partName, InStream in, Str:Str headers| callback) {
		httpReq := httpReq
		if (httpReq != null) {
			httpReq->parseMultiPartForm(callback)
			return
		}
		webReq(true)->parseMultiPartForm(callback)
	}
	
	** Only called during create / update Bean
	Obj? toValue(Type valType, Str clientValue) {
		if (valueEncoders != null)
			return valueEncoders->toValue(valType, clientValue)
		return typeCoercer.coerce(clientValue, valType)
	}
	
	** Only called from SkinCtx.toClient() / rendering form beans
	Str toClient(Type valType, Obj? value) {
		if (valueEncoders != null)
			return valueEncoders->toClient(valType, value)
		// don't bother with a TypeCoercer, just toStr it.
		return value?.toStr ?: Str.defVal
	}
	
	** Called when creating / reinspecting FormBeans - see HtmlInputInspector
	** See FormField.populate()
	Obj? getObj(Type? type) {
		objCache.get(type)
	}

	** Decode a HTTP quoted string according to RFC 2616 Section 2.2.
	** The given string must be wrapped in quotes.  See `toQuotedStr`.
	** 
	** Stolen from web::WebUtil.fromQuotedStr
	Str fromQuotedStr(Str s) {
		if (s.size < 2 || s[0] != '"' || s[-1] != '"')
			throw ArgErr("Not quoted str: $s")
		return s[1..-2].replace("\\\"", "\"")
	}

	Str? csrfToken() {
		webReq := webReq(false)
		if (webReq == null)
			return null
		// csrfTokenFn should cache the token for us
		return webReq->stash->get("afSleepSafe.csrfTokenFn")?->call?->toStr
	}

	private Obj? httpReq() {
		// no need to cache this - FormBeans are typically created per HttpRequest, and this method called once per HttpRequest!
		// active scope to get the current request scope
		scope.registry.activeScope.serviceById("afBedSheet::HttpRequest", false)
	}
	
	private Obj? webReq(Bool checked) {
		webReq := Actor.locals["web.req"]
		if (checked && webReq == null)
			throw Err("No web request active in thread")
		return webReq
	}
}
