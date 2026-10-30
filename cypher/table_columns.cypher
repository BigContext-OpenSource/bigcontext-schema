// The columns of the table, each with its kind.
MATCH (s:Element {id: $subject})-[r]->(c:Element) WHERE type(r) IN ['HAS_COLUMN', 'KEY_COLUMN', 'TIME_COLUMN'] RETURN DISTINCT c.id AS column, type(r) AS kind
