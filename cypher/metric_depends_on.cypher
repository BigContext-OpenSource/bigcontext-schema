// Everything the metric depends on through its formula, all the way down.
MATCH (s:Element {id: $subject})-[:DEPENDS_ON]->(x:Element) RETURN DISTINCT x.id AS element
