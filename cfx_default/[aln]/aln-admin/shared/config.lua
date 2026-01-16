Config = Config or {}

Config.Admin = {
  Debug = true,

  -- ACE required to use commands. Example:
  -- add_ace group.admin aln.admin allow
  RequiredAce = 'aln.admin',

  -- Optional: allow console (src=0) always
  AllowConsole = true,
}
