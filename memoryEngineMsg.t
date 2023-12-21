#charset "us-ascii"
//
// memoryEngineMsg.t
//
//	Action messages.
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify playerActionMessages
	// Debugging
	cantDebugMemoryNotActor = 'The first argument must be an actor. '
	cantDebugNoActorMemories = '{You/He dobj} {has} no memories. '
	cantDebugNoMemoryEngine = 'Memory engine not enabled for
		{you/her dobj}. '

	noMemoryBadArg = 'Unknown object to bad object type. '
	noMemory(obj) { return('No memory for object <q><<obj.name>></q>. '); }
;
