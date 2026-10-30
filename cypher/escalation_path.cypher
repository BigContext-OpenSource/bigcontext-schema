// Everyone the subject escalates to, along the escalation path.
MATCH (s:Element {id: $subject})-[:ESCALATES_TO*1..10]->(x:Element) RETURN DISTINCT x.id AS next
