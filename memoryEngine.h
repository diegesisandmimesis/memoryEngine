//
// memoryEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_MEMORY_ENGINE

#undef gRevealed
#define gRevealed(id) (memoryEngineManager.getRevealed(gActor, id))

#undef gReveal
#define gReveal(id) (memoryEngineManager.setRevealed(gActor, id))

#define gKnowsAbout(id) (memoryEngineManager.getKnown(gActor, id))
#define gLearnAbout(id) (memoryEngineManager.setKnown(gActor, id))

#define gHasSeen(id) (memoryEngineManager.getSeen(gActor, id))
#define gSee(id) (memoryEngineManager.setSeen(gActor, id))

#define MEMORY_ENGINE_H
