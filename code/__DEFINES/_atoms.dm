#define BAD_INIT_QDEL_BEFORE (1<<0)
#define BAD_INIT_DIDNT_INIT (1<<1)
#define BAD_INIT_SLEPT (1<<2)
#define BAD_INIT_NO_HINT (1<<3)

#ifdef PROFILE_MAPLOAD_INIT_ATOM
#define PROFILE_INIT_ATOM_BEGIN(...) var/__profile_stat_time = TICK_USAGE
#define PROFILE_INIT_ATOM_END(atom) mapload_init_times[##atom.type] += TICK_USAGE_TO_MS(__profile_stat_time)
#else
#define PROFILE_INIT_ATOM_BEGIN(...)
#define PROFILE_INIT_ATOM_END(...)
#endif

// /obj/effect/abstract/particle_holder/var/particle_flags
// Flags that effect how a particle holder displays something

/// If we're inside something inside a mob, display off that mob too
#define PARTICLE_ATTACH_MOB (1<<0)
