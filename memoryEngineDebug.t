#charset "us-ascii"
//
// memoryEngineDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

#ifdef __DEBUG_MEMORY_ENGINE

class MemoryAction: Action
	actionTime = 0
	objInScope(obj) { return(true); }
;
class MemoryTAction: MemoryAction, TAction;
class MemoryTIAction: MemoryAction, TIAction;

DefineTActionSub(DebugMemoryObject, MemoryTAction);
VerbRule(DebugMemoryObject) 'debug' 'memory' singleDobj: DebugMemoryObjectAction
	verbPhrase = 'memory debug/debugging (what)'
;

DefineTIActionSub(DebugMemoryActor, MemoryTIAction);
VerbRule(DebugMemoryActor) 'debug' 'actor' 'memory' singleDobj singleIobj:
	DebugMemoryActorAction
	verbPhrase = 'memory debug/debugging (whom) (about what)'
;

modify Thing
	dobjFor(DebugMemoryObject) { action() { gActor._debugMemory(self); } }
	dobjFor(DebugMemoryActor) { verify() {} }
	iobjFor(DebugMemoryActor) { verify() {} }
;

modify Actor
	dobjFor(DebugMemoryActor) {
		action() { _debugMemory(gIobj); }
	}
;

modify Actor
	_debugMemory(obj) {
		local m;

		if((obj == nil) || !obj.ofKind(Thing)) {
			"Unknown object or bad object type. ";
			return;
		}

		"<<obj.name>>\n ";
		if((m = getSeen(obj)) == nil) {
			"\tnever seen\n ";
		} else {
			"\t";
			if(m == true)
				"seen";
			else if(m.ofKind(Memory))
				m._debugMemory();
			else
				"unknown memory type";
			"\n ";
		}
	}
;

modify Memory
	_debugMemory() {
		"last seen on turn <<toString(turn)>>,
			location = <<(room ? room.roomName : 'nowhere')>>";
	}
;

#endif // __DEBUG_MEMORY_ENGINE
