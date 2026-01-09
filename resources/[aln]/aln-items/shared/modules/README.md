Modules pattern (how you add later)

Each file registers a table into ALN_ITEM_MODULES["<module_name>"].
You can add future modules like items_camping.lua by:

creating the file in shared/modules/

adding it to fxmanifest.lua shared_scripts list

No giant rewrite, no monolith.