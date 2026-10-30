// Everything the subject is built or sourced from, all the way back.
MATCH (s:Element {id: $subject})-[:DERIVED_FROM]->(x:Element) RETURN DISTINCT x.id AS source
