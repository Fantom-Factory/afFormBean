using afIoc::Inject
using afIoc::Scope
using concurrent::AtomicRef
//using afBedSheet::HttpRequest
//using afBedSheet::ObjCache
//using afBedSheet::ValueEncoder
//using afBedSheet::ValueEncoders

internal const class WebProxy {
	
	@Inject private const	Scope		scope
			private const	AtomicRef	valueEncodersRef	:= AtomicRef()
			private const	AtomicRef 	objCacheRef			:= AtomicRef()
	
	new make(|This| f) { f(this) }

	MimeType? reqContentType() {
		httpRequest := httpRequest
		headers		:= httpRequest.typeof.method("headers").callOn(httpRequest, null)
		contentType	:= headers.typeof.method("contentType").callOn(headers, null)
		return contentType
	}
	
	[Str:Str]? reqForm() {
		httpRequest := httpRequest
		body		:= httpRequest.typeof.method("body").callOn(httpRequest, null)
		form		:= body		  .typeof.method("form").callOn(body, null)
		return form
	}
	
	Void parseMultiPartForm(|Str partName, InStream in, Str:Str headers| callback) {
		httpRequest := httpRequest
		httpRequest.typeof.method("parseMultiPartForm").callOn(httpRequest, [callback])
	}
	
	Obj? toValue(Type valType, Str clientValue) {
		valueEncoders	:= valueEncoders
		toValue			:= valueEncoders.typeof.method("toValue").callOn(valueEncoders, [valType, clientValue])
		return toValue
	}
	
	Str toClient(Type valType, Obj? value) {
		valueEncoders	:= valueEncoders
		toClient		:= valueEncoders.typeof.method("toClient").callOn(valueEncoders, [valType, value])
		return toClient
	}
	
	Obj? getObj(Type? type) {
		objCache	:= objCache
		get			:= objCache.typeof.method("get").callOn(valueEncoders, [type])
		return get
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
