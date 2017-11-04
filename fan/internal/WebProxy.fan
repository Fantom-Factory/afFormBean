using afIoc::Inject
using afIoc::Scope
using concurrent::AtomicRef

internal const class WebProxy {
	
	@Inject private const	Scope		scope
			private const	AtomicRef	valueEncodersRef	:= AtomicRef()
			private const	AtomicRef 	objCacheRef			:= AtomicRef()
	
	new make(|This| f) { f(this) }

	MimeType? reqContentType() {
		httpRequest->headers->contentType
	}
	
	[Str:Str]? reqForm() {
		httpRequest->body->form
	}
	
	Void parseMultiPartForm(|Str partName, InStream in, Str:Str headers| callback) {
		httpRequest->parseMultiPartForm(callback)
	}
	
	Obj? toValue(Type valType, Str clientValue) {
		valueEncoders->toValue(valType, clientValue)
	}
	
	Str toClient(Type valType, Obj? value) {
		valueEncoders->toClient(valType, value)
	}
	
	Obj? getObj(Type? type) {
		objCache->get(type)
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

	
	private Obj httpRequest() {
		// no need to cache this - FormBeans are typically created per HttpRequest, and this method called once per HttpRequest!
		scope.serviceById("afBedSheet::HttpRequest")
	}
	
	private Obj valueEncoders() {
		if (objCacheRef.val == null)
			objCacheRef.val = scope.serviceById("afBedSheet::ValueEncoders")
		return objCacheRef.val		
	}

	private Obj objCache() {
		if (objCacheRef.val == null)
			objCacheRef.val = scope.serviceById("afBedSheet::ObjCache")
		return objCacheRef.val
	}
}
