#charset "us-ascii"
//
// memoryEngineDebug.t
//
//	Implements a few debugging actions.
//
//	>MA [actor]		shows all the memories for the given actor
//	>MA [actor] actor	shows actor's memories about other actors
//	>MA [actor] object	shows actor's memories about objects
//	>MA [actor] room	shows actor's memories about rooms
//	>MA [actor] [object]	shows the actor's memory for the object
//	>MO [object]		shows the player's memory for the object
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

DefineSystemAction(DebugMemoryEngine)
	execSystemAction() {
		local m0, m1, n;

		n = 0;
		m0 = 0;
		m1 = 0;
		forEachInstance(MemoryEngine, function(o) {
			n += 1;
			if(o._memory == nil) return;
			o._memory.forEachAssoc(function(k, v) {
				m0 += 1;
				if(o.isListed(k)) m1 += 1;
			});
		});
		"\nMemory engines = <<toString(n)>>\n ";
		"\nTotal memories = <<toString(m0)>>\n ";
		"\nListed memories = <<toString(m1)>>\n ";
	}
;
VerbRule(DebugMemoryEngine) 'me': DebugMemoryEngineAction
	verbPhrase = 'memory engine debug/debugging'
;

DefineTActionSub(DebugMemoryObject, MemoryTAction);
VerbRule(DebugMemoryObject) 'mo' singleDobj: DebugMemoryObjectAction
	verbPhrase = 'memory debug/debugging (what)'
;

DefineTActionSub(DebugMemoryActor, MemoryTAction);
VerbRule(DebugMemoryActor) 'ma' singleDobj: DebugMemoryActorAction
	verbPhrase = 'memory debug/debugging (who)'
;

DefineTIActionSub(DebugMemoryActorObject, MemoryTIAction);
VerbRule(DebugMemoryActorObject) 'ma' singleDobj singleIobj:
	DebugMemoryActorObjectAction
	verbPhrase = 'memory debug/debugging (whom) (about what)'
;

DefineTActionSub(DebugMemoryActorRooms, MemoryTAction);
VerbRule(DebugMemoryActorRooms) 'ma' singleDobj ('room'|'rooms'):
	DebugMemoryActorRoomsAction
	verbPhrase = 'memory debug/debugging (who)'
;

DefineTActionSub(DebugMemoryActorActors, MemoryTAction);
VerbRule(DebugMemoryActorActors) 'ma' singleDobj ('actor'|'actors'):
	DebugMemoryActorActorsAction
	verbPhrase = 'memory debug/debugging (who)'
;

DefineTActionSub(DebugMemoryActorObjects, MemoryTAction);
VerbRule(DebugMemoryActorObjects) 'ma' singleDobj ('object'|'objects'):
	DebugMemoryActorObjectsAction
	verbPhrase = 'memory debug/debugging (who)'
;


modify Thing
	dobjFor(DebugMemoryObject) { action() { gActor._debugMemory(self); } }
	dobjFor(DebugMemoryActor) {
		verify() { illogical(&cantDebugMemoryNotActor); }
	}
	dobjFor(DebugMemoryActorObject) { verify() {} }
	iobjFor(DebugMemoryActorObject) { verify() {} }
;

modify Actor
	dobjFor(DebugMemoryActor) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugActorMemory(); }
	}
	dobjFor(DebugMemoryActorObject) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugMemory(gIobj); }
	}
	dobjFor(DebugMemoryActorRooms) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugActorMemoryClass(Room); }
	}
	dobjFor(DebugMemoryActorActors) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugActorMemoryClass(Actor); }
	}
	dobjFor(DebugMemoryActorObjects) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugActorMemoryClass(Thing, [ Room, Actor ]); }
	}
;

modify Actor
	_debugActorMemory() { memoryEngine._debugMemories(); }
	_debugActorMemoryClass(cls, excl?) {
		memoryEngine._debugMemoryClass(cls, excl);
	}
	_debugMemory(id) {
		local m;

		if((id == nil) || !id.ofKind(Thing)) {
			reportFailure(&noMemoryBadArg);
			return;
		}
		if((m = getMemory(id)) == nil) {
			reportFailure(&noMemory, id);
			return;
		}

		m._debugMemory();
	}
;

modify MemoryEngine
	_debugMemories() {
		if(_memory == nil) {
			reportFailure(&cantDebugNoActorMemories);
			return;
		}
		_memory.forEachAssoc(function(k, v) {
			if(isListed(k) != true)
				return;
			"\n<.p> ";
			"\nobject:  <<k.name>>\n ";
			v._debugMemory('\t');
		});
	}
	_check(obj, lst) {
		local i;

		if((obj == nil) || (lst == nil)) return(nil);
		if(lst.ofKind(Collection)) {
			for(i = 1; i <= lst.length; i++) {
				if(obj.ofKind(lst[i])) return(true);
			}
			return(nil);
		} else {
			return(obj.ofKind(lst));
		}
	}
	_debugMemoryClass(cls, excl?) {
		if(_memory == nil) {
			reportFailure(&cantDebugNoActorMemories);
			return;
		}
		"\n<.p> ";
		_memory.forEachAssoc(function(k, v) {
			if(isListed(k) != true)
				return;
			if(!_check(k, cls)) return;
			if(excl && _check(k, excl)) return;
			"\n<.p> ";
			"\nobject:  <<k.name>>\n ";
			v._debugMemory('\t');
		});
	}
;

modify Memory
	_output(str, prefix?) { "\n<<(prefix ? prefix : '')>><<str>>\n "; }
	_outputProp(prop, prefix?) {
		local v;

		v = (self).(prop);
		if((v == nil) || (v == 0)) return;

		_output('<<toString(prop)>> = <<toString(v)>>', prefix);
	}
	_debugMemory(prefix?) {
		_outputProp(&described, prefix);
		_outputProp(&known, prefix);
		_outputProp(&revealed, prefix);
		_outputProp(&seen, prefix);
#ifndef MEMORY_ENGINE_NO_SENSES
		_outputProp(&heard, prefix);
		_outputProp(&smelled, prefix);
		_outputProp(&touched, prefix);
		_outputProp(&tasted, prefix);
#endif // MEMORY_ENGINE_NO_SENSES
	}
;

#ifndef MEMORY_ENGINE_SIMPLE

modify Memory
	_debugMemory(prefix?) {
		inherited(prefix);

		_outputProp(&createTime, prefix);
		_outputProp(&writeTime, prefix);
		_outputProp(&writeCount, prefix);
		_outputProp(&readTime, prefix);
		_outputProp(&readCount, prefix);
		_outputProp(&age, prefix);
	}
;

#endif // MEMORY_ENGINE_SIMPLE

#endif // __DEBUG_MEMORY_ENGINE
