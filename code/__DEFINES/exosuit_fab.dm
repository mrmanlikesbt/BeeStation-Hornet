/// Module is compatible with Security Cyborg model
#define BORG_MODEL_SECURITY (1<<0)
/// Module is compatible with Miner Cyborg model
#define BORG_MODEL_MINER (1<<1)
/// Module is compatible with Janitor Cyborg model
#define BORG_MODEL_JANITOR (1<<2)
/// Module is compatible with Medical Cyborg model
#define BORG_MODEL_MEDICAL (1<<3)
/// Module is compatible with Engineering Cyborg model
#define BORG_MODEL_ENGINEERING (1<<4)
/// Module is used for service Cyborgs specialization
#define BORG_MODEL_SPECIALITY (1<<5)

/// Module is compatible with Ripley Exosuit models
#define EXOSUIT_MODULE_RIPLEY (1<<0)
/// Module is compatible with Odyseeus Exosuit models
#define EXOSUIT_MODULE_ODYSSEUS (1<<1)
/// Module is compatible with Gygax Exosuit models
#define EXOSUIT_MODULE_GYGAX (1<<2)
/// Module is compatible with Durand Exosuit models
#define EXOSUIT_MODULE_DURAND (1<<3)
/// Module is compatible with H.O.N.K Exosuit models
#define EXOSUIT_MODULE_HONK (1<<4)
/// Module is compatible with Phazon Exosuit models
#define EXOSUIT_MODULE_PHAZON (1<<5)

/// Module is compatible with "Combat" Exosuit models - Gygax, H.O.N.K, Durand and Phazon
#define EXOSUIT_MODULE_COMBAT EXOSUIT_MODULE_GYGAX | EXOSUIT_MODULE_HONK | EXOSUIT_MODULE_DURAND | EXOSUIT_MODULE_PHAZON
/// Module is compatible with "Medical" Exosuit modelsm - Odysseus
#define EXOSUIT_MODULE_MEDICAL EXOSUIT_MODULE_ODYSSEUS
