# forvex.json registry card

Every nibblet app repo carries a `forvex.json` at the root (not `app.json`—Expo uses that name). Agents update it when stage, version, URL, or marketing status changes. Never put secrets here.

**Schema:** [`schemas/forvex.schema.json`](../schemas/forvex.schema.json) (JSON Schema 2020-12). The schema's `description` field lists all properties.

**Required fields:** `name`, `repo`, `display_name`, `tier`, `stage`, `platform`, `hosting`, `updated`. If `stage` is `Parked`, `review_by` is also required.

**Enums:** tier `A`/`B`/`C`/`P`/`X`; stage `Idea`/`Prototype`/`Beta`/`Live`/`Maintenance`/`Parked`/`Sunset`.
