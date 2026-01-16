ALN = ALN or {}
ALN.Locations = ALN.Locations or {}

ALN.Locations.Schema = {
  required = { 'label', 'coords', 'kind' },
  kinds = {
    service = true,
    shop = true,
    housing = true,
    parking = true,
    gang = true,
    payphone = true,
    poi = true,
  }
}
