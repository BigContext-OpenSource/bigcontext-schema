// Everyone and every post the subject reports to, all the way up.
MATCH (s:Element {id: $subject})-[:REPORTS_TO]->(x:Element) RETURN DISTINCT x.id AS above
