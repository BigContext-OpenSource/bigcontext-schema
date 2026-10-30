// The tables the subject joins to directly.
MATCH (s:Element {id: $subject})-[:JOINS_TO]->(x:Element) RETURN DISTINCT x.id AS table
