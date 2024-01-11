#charset "us-ascii"
//
// memoryEngineDisambig.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify MemoryEngine
	canonicalizeID(id) {
		switch(dataType(id)) {
			case TypeNil:
				return(nil);
			case TypeSString:
				return(id);
			case TypeObject:
				if(id._uid)
					return(id._uid);
				else
					return(guid(id));
			default:
				return(nil);
		}
	}
;
