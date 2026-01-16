# aln-admin (ALN3)

ACE-gated admin/ops resource.

ACE:
- Required ACE: `aln.admin`
- Example:
  add_ace group.admin aln.admin allow

Commands:
- aln_admin_ping
- aln_admin_status <playerSrc>
- aln_admin_setslot <playerSrc> <slot>
- aln_admin_give <playerSrc> <itemKey> [count]
- aln_admin_money <playerSrc> <cash|bank|dirty> <amount>  (negative debits)
- aln_admin_service <playerSrc> <police|ems|fire|taxi>
- aln_admin_dc <playerSrc> <actionId>
